import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/device/platform_name.dart';
import '../../../../core/session/game_session.dart';
import '../../domain/game_mode.dart';
import '../../domain/game_settings.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import 'host_setup_state.dart';

class HostSetupCubit extends Cubit<HostSetupState> {
  HostSetupCubit({
    required LobbyRepository repository,
    required GameSession session,
  }) : _repository = repository,
       _session = session,
       super(const HostSetupState());

  final LobbyRepository _repository;
  final GameSession _session;

  void modeChanged(GameMode mode) => emit(state.copyWith(mode: mode));

  void geofenceChanged(LatLng center) =>
      emit(state.copyWith(geofenceCenter: center));

  void geofenceRadiusChanged(int radiusM) =>
      emit(state.copyWith(geofenceRadiusM: radiusM));

  void disperseMinutesChanged(int v) =>
      emit(state.copyWith(disperseMinutes: v));

  void softPunishmentMinutesChanged(int v) =>
      emit(state.copyWith(softPunishmentMinutes: v));

  void hardPunishmentMinutesChanged(int v) =>
      emit(state.copyWith(hardPunishmentMinutes: v));

  void compassUpdateIntervalMinutesChanged(int v) =>
      emit(state.copyWith(compassUpdateIntervalMinutes: v));

  void compassViewSecondsChanged(int v) =>
      emit(state.copyWith(compassViewSeconds: v));

  void voteTimeoutMinutesChanged(int v) =>
      emit(state.copyWith(voteTimeoutMinutes: v));

  void frameCooldownMinutesChanged(int v) =>
      emit(state.copyWith(frameCooldownMinutes: v));

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void selfieChanged(Uint8List? bytes) =>
      emit(state.copyWith(selfieBytes: bytes));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: HostSetupStatus.submitting, error: null));

    try {
      final crypto = await GameCrypto.generate();
      final nameCiphertext = await crypto.encryptString(state.name.trim());
      final nameHmac = await crypto.nameHmac(state.name);

      final settings = GameSettings(
        mode: state.mode,
        geofenceLat: state.geofenceCenter!.latitude,
        geofenceLng: state.geofenceCenter!.longitude,
        geofenceRadiusM: state.geofenceRadiusM,
        disperseMinutes: state.disperseMinutes,
        softPunishmentMinutes: state.softPunishmentMinutes,
        hardPunishmentMinutes: state.hardPunishmentMinutes,
        compassUpdateIntervalMinutes: state.compassUpdateIntervalMinutes,
        compassViewSeconds: state.compassViewSeconds,
        voteTimeoutMinutes: state.voteTimeoutMinutes,
        frameCooldownMinutes: state.frameCooldownMinutes,
      );

      final (gameId, joinToken) = await _repository.createGame(
        settings: settings,
        nameCiphertext: nameCiphertext,
        nameHmac: nameHmac,
        platform: currentPlatformName(),
      );
      final playerId = await _repository.myHostPlayerId(gameId);

      final encryptedSelfie = await crypto.encryptBytes(state.selfieBytes!);
      await _repository.uploadSelfie(
        gameId: gameId,
        playerId: playerId,
        encryptedSelfie: encryptedSelfie,
      );

      _session.begin(gameId: gameId, playerId: playerId, crypto: crypto);

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
