import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/session/game_session.dart';
import 'package:framed/features/lobby/domain/game_mode.dart';
import 'package:framed/features/lobby/domain/game_settings.dart';
import 'package:framed/features/lobby/domain/lobby_error.dart';
import 'package:framed/features/lobby/domain/lobby_repository.dart';
import 'package:framed/features/lobby/domain/lobby_snapshot.dart';
import 'package:framed/features/lobby/presentation/host_setup/host_setup_cubit.dart';
import 'package:framed/features/lobby/presentation/host_setup/host_setup_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:postgrest/postgrest.dart';

class _FakeLobbyRepository implements LobbyRepository {
  GameSettings? capturedSettings;
  String? capturedNameCiphertext;
  String? capturedNameHmac;
  String? capturedPlatform;
  Uint8List? capturedSelfie;
  Object? failure;

  static const gameId = 'game-1';
  static const joinToken = 'token-1';
  static const hostPlayerId = 'player-host';

  @override
  Future<(String, String)> createGame({
    required GameSettings settings,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) async {
    if (failure != null) throw failure!;
    capturedSettings = settings;
    capturedNameCiphertext = nameCiphertext;
    capturedNameHmac = nameHmac;
    capturedPlatform = platform;
    return (gameId, joinToken);
  }

  @override
  Future<String> myHostPlayerId(String gameId) async => hostPlayerId;

  @override
  Future<void> uploadSelfie({
    required String gameId,
    required String playerId,
    required Uint8List encryptedSelfie,
  }) async {
    capturedSelfie = encryptedSelfie;
  }

  @override
  Future<(String, String)> joinGame({
    required String joinToken,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) => throw UnimplementedError();

  @override
  Future<void> updateSettings({
    required String gameId,
    required Map<String, dynamic> settings,
  }) => throw UnimplementedError();

  @override
  Future<void> leaveLobby(String gameId) => throw UnimplementedError();

  @override
  Future<LobbySnapshot> fetchLobby(String gameId) => throw UnimplementedError();

  @override
  Future<void> startGame(String gameId) => throw UnimplementedError();
}

void main() {
  group('HostSetupCubit', () {
    late _FakeLobbyRepository repository;
    late GameSession session;
    late HostSetupCubit cubit;

    setUp(() {
      repository = _FakeLobbyRepository();
      session = GameSession();
      cubit = HostSetupCubit(repository: repository, session: session);
    });

    test('canSubmit is false until name, selfie, and geofence are all set', () {
      expect(cubit.state.canSubmit, isFalse);

      cubit.nameChanged('Alice');
      expect(cubit.state.canSubmit, isFalse);

      cubit.selfieChanged(Uint8List.fromList([1, 2, 3]));
      expect(cubit.state.canSubmit, isFalse);

      cubit.geofenceChanged(const LatLng(52.0, 5.0));
      expect(cubit.state.canSubmit, isTrue);
    });

    test('submit() is a no-op while the form is incomplete', () async {
      await cubit.submit();

      expect(cubit.state.status, HostSetupStatus.editing);
      expect(session.isActive, isFalse);
    });

    test(
      'happy path: creates the game, uploads the selfie, starts the session',
      () async {
        cubit
          ..nameChanged('  Alice ')
          ..selfieChanged(Uint8List.fromList(List.generate(50, (i) => i)))
          ..geofenceChanged(const LatLng(52.09, 5.12))
          ..modeChanged(GameMode.lastManStanding)
          ..geofenceRadiusChanged(500);

        await cubit.submit();

        expect(cubit.state.status, HostSetupStatus.success);
        expect(cubit.state.gameId, _FakeLobbyRepository.gameId);
        expect(cubit.state.joinTokenForQr, _FakeLobbyRepository.joinToken);

        // Settings reached the repository with the right shape.
        expect(repository.capturedSettings!.mode, GameMode.lastManStanding);
        expect(repository.capturedSettings!.geofenceRadiusM, 500);
        expect(repository.capturedSettings!.geofenceLat, 52.09);
        expect(repository.capturedPlatform, isNotEmpty);

        // The session now holds the same crypto that encrypted the name/selfie —
        // decrypting what the repository received returns the original input.
        final crypto = session.crypto;
        expect(
          await crypto.decryptString(repository.capturedNameCiphertext!),
          'Alice',
        );
        expect(await crypto.nameHmac('alice'), repository.capturedNameHmac);
        final decryptedSelfie = await crypto.decryptBytes(
          repository.capturedSelfie!,
        );
        expect(decryptedSelfie, List.generate(50, (i) => i));

        expect(session.isActive, isTrue);
        expect(session.gameId, _FakeLobbyRepository.gameId);
        expect(session.playerId, _FakeLobbyRepository.hostPlayerId);
      },
    );

    test(
      'sad path: a bad_settings error surfaces as LobbyError.badSettings',
      () async {
        repository.failure = const PostgrestException(message: 'bad_settings');
        cubit
          ..nameChanged('Alice')
          ..selfieChanged(Uint8List.fromList([1, 2, 3]))
          ..geofenceChanged(const LatLng(52.0, 5.0));

        await cubit.submit();

        expect(cubit.state.status, HostSetupStatus.failure);
        expect(cubit.state.error, LobbyError.badSettings);
        expect(session.isActive, isFalse);
      },
    );

    test(
      'sad path: an unrecognized error surfaces as LobbyError.unknown',
      () async {
        repository.failure = Exception('network is down');
        cubit
          ..nameChanged('Alice')
          ..selfieChanged(Uint8List.fromList([1, 2, 3]))
          ..geofenceChanged(const LatLng(52.0, 5.0));

        await cubit.submit();

        expect(cubit.state.status, HostSetupStatus.failure);
        expect(cubit.state.error, LobbyError.unknown);
      },
    );
  });
}
