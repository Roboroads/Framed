import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/crypto/game_crypto.dart';
import '../../../../core/device/platform_name.dart';
import '../../../../core/session/game_session.dart';
import '../../domain/lobby_error.dart';
import '../../domain/lobby_repository.dart';
import 'join_state.dart';

class JoinCubit extends Cubit<JoinState> {
  JoinCubit({
    required LobbyRepository repository,
    required GameSession session,
    required this.joinToken,
    required this.gameKeyBytes,
  }) : _repository = repository,
       _session = session,
       super(const JoinState());

  final LobbyRepository _repository;
  final GameSession _session;
  final String joinToken;
  final Uint8List gameKeyBytes;

  // Set once join_game succeeds, so a retry after a failed selfie upload
  // re-sends the selfie instead of calling join_game again — a second call
  // would fail with name_taken against the seat we already hold.
  GameCrypto? _crypto;
  String? _gameId;
  String? _playerId;

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void selfieChanged(Uint8List? bytes) =>
      emit(state.copyWith(selfieBytes: bytes));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: JoinStatus.submitting, error: null));

    try {
      final crypto = _crypto ??= await GameCrypto.fromKeyBytes(gameKeyBytes);

      String gameId;
      String playerId;
      if (_gameId != null && _playerId != null) {
        gameId = _gameId!;
        playerId = _playerId!;
      } else {
        final nameCiphertext = await crypto.encryptString(state.name.trim());
        final nameHmac = await crypto.nameHmac(state.name);
        (gameId, playerId) = await _repository.joinGame(
          joinToken: joinToken,
          nameCiphertext: nameCiphertext,
          nameHmac: nameHmac,
          platform: currentPlatformName(),
        );
        _gameId = gameId;
        _playerId = playerId;
      }

      final encryptedSelfie = await crypto.encryptBytes(state.selfieBytes!);
      await _repository.uploadSelfie(
        gameId: gameId,
        playerId: playerId,
        encryptedSelfie: encryptedSelfie,
      );

      _session.begin(gameId: gameId, playerId: playerId, crypto: crypto);

      emit(state.copyWith(status: JoinStatus.success));
    } catch (e) {
      // Debug-only: LobbyError.fromException collapses anything it doesn't
      // recognize into LobbyError.unknown, which is enough for the UI but
      // not for diagnosing why a call actually failed.
      assert(() {
        // ignore: avoid_print
        print('JOIN_ERROR_DEBUG: $e');
        return true;
      }());
      emit(
        state.copyWith(
          status: JoinStatus.failure,
          error: LobbyError.fromException(e),
        ),
      );
    }
  }
}
