import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/crypto/game_crypto.dart';
import 'package:framed/core/realtime/game_event.dart';
import 'package:framed/features/game/domain/game_repository.dart';
import 'package:framed/features/game/presentation/ingame/ingame_bloc.dart';
import 'package:framed/features/game/presentation/ingame/ingame_state.dart';

class _FakeGameRepository implements GameRepository {
  Uint8List? selfieBytes;
  Object? failure;

  /// When true, each call parks on its own completer (in call order)
  /// instead of resolving immediately — lets a test control which of two
  /// concurrent downloads "finishes" first.
  bool controlled = false;
  final completers = <Completer<Uint8List>>[];

  @override
  Future<Uint8List> downloadSelfie(String path) {
    if (failure != null) throw failure!;
    if (controlled) {
      final completer = Completer<Uint8List>();
      completers.add(completer);
      return completer.future;
    }
    return Future.value(selfieBytes);
  }
}

void main() {
  group('IngameBloc', () {
    late GameCrypto crypto;
    late _FakeGameRepository repository;
    late StreamController<GameEvent> events;
    late DateTime endsAt;

    setUp(() async {
      crypto = await GameCrypto.generate();
      repository = _FakeGameRepository();
      events = StreamController<GameEvent>();
      endsAt = DateTime.utc(2026, 1, 1, 12);
    });

    tearDown(() => events.close());

    test('starts dispersing at the given endsAt', () {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        initialEndsAt: endsAt,
      );

      expect(bloc.state, IngameState.dispersing(endsAt: endsAt));
    });

    test('dispersing -> playing on target_assigned', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        initialEndsAt: endsAt,
      );
      final selfieBytes = Uint8List.fromList([1, 2, 3, 4]);
      repository.selfieBytes = await crypto.encryptBytes(selfieBytes);

      events.add(
        GameEvent.targetAssigned(
          targetId: 'target-1',
          nameCiphertext: await crypto.encryptString('Alice'),
          selfiePath: 'game-1/target-1',
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state;
      expect(state, isA<IngamePlaying>());
      final target = (state as IngamePlaying).target;
      expect(target.playerId, 'target-1');
      expect(target.name, 'Alice');
      expect(target.selfieBytes, selfieBytes);
    });

    test(
      'a selfie that fails to load surfaces targetLoadFailed, not a crash',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          initialEndsAt: endsAt,
        );
        repository.failure = Exception('storage unavailable');

        events.add(
          GameEvent.targetAssigned(
            targetId: 'target-1',
            nameCiphertext: await crypto.encryptString('Alice'),
            selfiePath: 'game-1/target-1',
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state, const IngameState.targetLoadFailed());
      },
    );

    test(
      'a newer target_assigned wins even if its download finishes first',
      () async {
        final bloc = IngameBloc(
          events: events.stream,
          crypto: crypto,
          repository: repository,
          initialEndsAt: endsAt,
        );
        repository.controlled = true;

        events.add(
          GameEvent.targetAssigned(
            targetId: 'first',
            nameCiphertext: await crypto.encryptString('First'),
            selfiePath: 'game-1/first',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        events.add(
          GameEvent.targetAssigned(
            targetId: 'second',
            nameCiphertext: await crypto.encryptString('Second'),
            selfiePath: 'game-1/second',
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(repository.completers, hasLength(2));
        // The newer (second) download resolves first; the stale (first)
        // one lands after — it must not overwrite the newer state.
        repository.completers[1].complete(
          await crypto.encryptBytes(Uint8List.fromList([2, 2])),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        repository.completers[0].complete(
          await crypto.encryptBytes(Uint8List.fromList([1, 1])),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));

        final state = bloc.state;
        expect(state, isA<IngamePlaying>());
        expect((state as IngamePlaying).target.playerId, 'second');
      },
    );

    test('unrelated events are ignored', () async {
      final bloc = IngameBloc(
        events: events.stream,
        crypto: crypto,
        repository: repository,
        initialEndsAt: endsAt,
      );

      events.add(const GameEvent.playerLeft(playerId: 'someone-else'));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, IngameState.dispersing(endsAt: endsAt));
    });
  });
}
