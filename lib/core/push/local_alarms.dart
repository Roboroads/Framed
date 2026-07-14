import 'push_event_text.dart';
import 'push_notifications.dart';

/// Client-scheduled local alarms (#46): a reliability backstop for the two
/// time-sensitive moments push alone can't guarantee — the compass pulse's
/// next-fire time and a rule-break's hard deadline. Not a replacement for
/// push, which stays primary and already handles decrypt-and-render
/// correctly (#27/#28); this only makes sure roughly the right instant
/// still gets *some* on-device alert if a push is delayed or dropped
/// (inexact OS-batched scheduling, see [PushNotifications.scheduleAt] —
/// deliberately, to avoid a second permission-request flow for a pure
/// fallback path). Carries no payload of its own — same generic (title,
/// body) [PushEventText] already gives the push-triggered version of each
/// event, since a missed-push alarm should look no different from the
/// notification push itself would have shown.
///
/// [IngameBloc] owns the reschedule/cancel lifecycle: every fresh
/// `compass_pulse`/`warning` update (live or caught up) reschedules the
/// matching alarm to the server's current timing, and clearing a warning
/// (or this player dying) cancels it outright — a stale alarm must never
/// fire uselessly after the thing it was for has already resolved.
abstract interface class LocalAlarms {
  Future<void> scheduleCompassPulse(DateTime at);
  Future<void> cancelCompassPulse();
  Future<void> scheduleWarningDeadline(DateTime at);
  Future<void> cancelWarningDeadline();

  /// Both at once — this player is done needing either (dead, or the
  /// bloc's own disposal).
  Future<void> cancelAll();
}

class FlutterLocalAlarms implements LocalAlarms {
  // Fixed per slot, not per occurrence — scheduling the same id again
  // replaces whatever was pending under it (PushNotifications.scheduleAt),
  // which is exactly the reschedule half of the lifecycle above.
  static const _compassPulseId = 1001;
  static const _warningDeadlineId = 1002;

  @override
  Future<void> scheduleCompassPulse(DateTime at) async {
    if (!at.isAfter(DateTime.now())) return;
    final (title, body) = PushEventText.forEvent('compass_pulse');
    await PushNotifications.scheduleAt(
      id: _compassPulseId,
      title: title,
      body: body,
      at: at,
    );
  }

  @override
  Future<void> cancelCompassPulse() =>
      PushNotifications.cancel(_compassPulseId);

  @override
  Future<void> scheduleWarningDeadline(DateTime at) async {
    if (!at.isAfter(DateTime.now())) return;
    final (title, body) = PushEventText.forEvent('warning');
    await PushNotifications.scheduleAt(
      id: _warningDeadlineId,
      title: title,
      body: body,
      at: at,
    );
  }

  @override
  Future<void> cancelWarningDeadline() =>
      PushNotifications.cancel(_warningDeadlineId);

  @override
  Future<void> cancelAll() async {
    await cancelCompassPulse();
    await cancelWarningDeadline();
  }
}
