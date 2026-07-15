import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/device/platform_name.dart';
import '../../../../core/push/push_service.dart';
import '../../../../core/session/game_session.dart';
import '../../../../core/text/name_sanitizer.dart';
import '../../domain/game_settings.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import 'host_setup_state.dart';

class HostSetupCubit extends Cubit<HostSetupState> {
  HostSetupCubit({
    required LobbyRepository repository,
    required GameSession session,
    required PushService pushService,
  }) : _repository = repository,
       _session = session,
       _pushService = pushService,
       super(const HostSetupState());

  final LobbyRepository _repository;
  final GameSession _session;
  final PushService _pushService;

  void geofenceChanged(LatLng center) =>
      emit(state.copyWith(geofenceCenter: center));

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void selfieChanged(Uint8List? bytes) =>
      emit(state.copyWith(selfieBytes: bytes));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: HostSetupStatus.submitting, error: null));

    try {
      final crypto = await GameCrypto.generate();
      final sanitizedName = sanitizeDisplayName(state.name);
      final nameCiphertext = await crypto.encryptString(sanitizedName);
      final nameHmac = await crypto.nameHmac(sanitizedName);

      // Everything but the GPS-derived center takes GameSettings' own
      // defaults — mode/radius/timing are edited later, in the lobby (#62).
      final settings = GameSettings(
        geofenceLat: state.geofenceCenter!.latitude,
        geofenceLng: state.geofenceCenter!.longitude,
      );

      final (gameId, joinToken) = await _repository.createGame(
        settings: settings,
        nameCiphertext: nameCiphertext,
        nameHmac: nameHmac,
        platform: currentPlatformName(),
        pushToken: await _pushService.getToken(),
      );
      final playerId = await _repository.myHostPlayerId(gameId);

      final encryptedSelfie = await crypto.encryptBytes(state.selfieBytes!);
      await _repository.uploadSelfie(
        gameId: gameId,
        playerId: playerId,
        encryptedSelfie: encryptedSelfie,
      );

      await _session.begin(gameId: gameId, playerId: playerId, crypto: crypto);

      emit(
        state.copyWith(
          status: HostSetupStatus.success,
          gameId: gameId,
          joinTokenForQr: joinToken,
          gameKeyForQr: await crypto.keyBytes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HostSetupStatus.failure,
          error: LobbyError.fromException(e),
        ),
      );
    }
  }
}
