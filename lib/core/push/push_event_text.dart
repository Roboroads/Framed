import '../../i18n/strings.g.dart';

/// Localized (title, body) for a push-triggered local notification (#28).
///
/// The push payload itself only ever carries `{event, game_id}` (#27) — no
/// name, no ciphertext. [detail] is whatever extra context the background
/// handler's own fetch-and-decrypt managed to recover (a target's name, a
/// killer's name); every event still reads as a real message without it,
/// airplane mode included — never raw ciphertext, never a stuck blank
/// notification.
class PushEventText {
  const PushEventText._();

  static (String title, String body) forEvent(String event, {String? detail}) {
    switch (event) {
      case 'target_assigned':
        return (t.push.targetAssignedTitle, t.push.targetAssignedBody);
      case 'compass_pulse':
        return (t.push.compassPulseTitle, t.push.compassPulseBody);
      case 'frame_to_judge':
        return (
          t.push.frameToJudgeTitle,
          detail != null
              ? t.push.frameToJudgeBodyNamed(name: detail)
              : t.push.frameToJudgeBody,
        );
      case 'frame_verdict':
        return (t.push.frameVerdictTitle, t.push.frameVerdictBody);
      case 'warning':
        return (t.push.warningTitle, t.push.warningBody);
      case 'you_died':
        return (
          t.push.youDiedTitle,
          detail != null
              ? t.push.youDiedBodyNamed(name: detail)
              : t.push.youDiedBody,
        );
      case 'game_finished':
        return (
          t.push.gameFinishedTitle,
          detail != null
              ? t.push.gameFinishedBodyNamed(name: detail)
              : t.push.gameFinishedBody,
        );
      default:
        return (t.push.fallbackTitle, t.push.fallbackBody);
    }
  }
}
