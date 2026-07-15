import '../realtime/game_event.dart';

/// What a cold-start resume attempt found (#54). Plain sealed classes, not
/// freezed — this is consumed once by the home screen and discarded, no
/// equality/copyWith needed.
sealed class ResumeOutcome {
  const ResumeOutcome();
}

/// No persisted session, or it turned out to be unusable (game gone,
/// player not found) — the persisted session store has already been
/// cleared, home screen renders normally.
class ResumeNone extends ResumeOutcome {
  const ResumeNone();
}

class ResumeToLobby extends ResumeOutcome {
  const ResumeToLobby();
}

/// [initialEndsAt] is a placeholder the moment [IngameBloc]'s own
/// get_my_state catch-up call replaces — see its constructor. Only
/// meaningful for the split second before that call resolves.
class ResumeToIngame extends ResumeOutcome {
  const ResumeToIngame(this.initialEndsAt);

  final DateTime initialEndsAt;
}

/// A game that already finished by the time this device resumed (#89) —
/// cold start, or reopening after force-close. Without this case, resume()
/// used to fall through to [ResumeToIngame] for every status but 'lobby',
/// landing the player on a dispersing screen frozen at 00:00 forever, since
/// nothing about a finished game matches a DispersalStarted catch-up event.
class ResumeToFinish extends ResumeOutcome {
  const ResumeToFinish(this.event);

  final GameFinished event;
}
