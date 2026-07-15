import '../../features/game/domain/game_repository.dart';
import '../crypto/game_crypto.dart';
import '../realtime/game_event.dart';
import 'game_session.dart';
import 'resume_outcome.dart';
import 'session_store.dart';

/// Cold-start half of reconnect (#54) — the lobby-rejoin half just reuses
/// the normal join flow (join_game is idempotent for a retry by the same
/// auth_uid, see 13-lobby.sql). This is what runs once, on app start,
/// before the home screen renders: is there a game this device was in
/// when it last closed, and if so, where does it belong now.
class SessionResumeService {
  SessionResumeService({
    required SessionStore store,
    required GameSession session,
    required GameRepository repository,
  }) : _store = store,
       _session = session,
       _repository = repository;

  final SessionStore _store;
  final GameSession _session;
  final GameRepository _repository;

  Future<ResumeOutcome> resume() async {
    final persisted = await _store.read();
    if (persisted == null) return const ResumeNone();

    try {
      final crypto = await GameCrypto.fromKeyBytes(persisted.keyBytes);
      await _session.begin(
        gameId: persisted.gameId,
        playerId: persisted.playerId,
        crypto: crypto,
      );
      final state = await _repository.getMyState(persisted.gameId);
      if (state.gameStatus == 'lobby') return const ResumeToLobby();
      // #89: every other status used to fall through to ResumeToIngame,
      // including 'finished' — get_my_state always reports a GameFinished
      // event for that status, so this is the only case that can reach
      // here without one being a genuine (if unexpected) event shape.
      if (state.gameStatus == 'finished') {
        if (state.event case GameFinished event) return ResumeToFinish(event);
      }
      final endsAt = state.event is DispersalStarted
          ? (state.event as DispersalStarted).endsAt
          : DateTime.now();
      return ResumeToIngame(endsAt);
    } catch (e) {
      // Debug-only: this whole flow runs silently on every cold start, so
      // a wrong resume decision has no other visible trail to diagnose it
      // by — this bit us twice while building it (a stale schema cache, a
      // save that hadn't landed before a simulated crash).
      assert(() {
        // ignore: avoid_print
        print('RESUME_DEBUG: failed: $e');
        return true;
      }());
      // Game's gone (finished + cleaned up, or this device was somehow
      // never a member) — a reinstall would already have wiped the store,
      // so this is the "genuinely nothing to resume" case, not that one.
      await _session.end();
      return const ResumeNone();
    }
  }
}
