import 'package:flutter_test/flutter_test.dart';
import 'package:framed/core/push/push_event_text.dart';

void main() {
  group('PushEventText', () {
    test('every known event renders non-empty title and body', () {
      const events = [
        'target_assigned',
        'compass_pulse',
        'frame_to_judge',
        'frame_verdict',
        'warning',
        'you_died',
        'game_finished',
      ];
      for (final event in events) {
        final (title, body) = PushEventText.forEvent(event);
        expect(title, isNotEmpty, reason: 'event: $event');
        expect(body, isNotEmpty, reason: 'event: $event');
      }
    });

    test('an unknown event falls back to the generic message', () {
      final (title, body) = PushEventText.forEvent('something_new');
      final (fallbackTitle, fallbackBody) = PushEventText.forEvent(
        'literally_anything_else',
      );
      expect(title, fallbackTitle);
      expect(body, fallbackBody);
    });

    test('frame_to_judge names the target when a detail is available', () {
      final withoutDetail = PushEventText.forEvent('frame_to_judge');
      final withDetail = PushEventText.forEvent(
        'frame_to_judge',
        detail: 'Alice',
      );
      expect(withDetail.$2, isNot(withoutDetail.$2));
      expect(withDetail.$2, contains('Alice'));
    });

    test('you_died names the killer when a detail is available', () {
      final withDetail = PushEventText.forEvent('you_died', detail: 'Bob');
      expect(withDetail.$2, contains('Bob'));
    });

    test(
      'you_died renders a non-empty body with no detail (mia, or a fetch that failed)',
      () {
        final (_, body) = PushEventText.forEvent('you_died');
        expect(body, isNotEmpty);
        expect(body, isNot(contains(r'$name')));
      },
    );

    test('game_finished names the winner when a detail is available', () {
      final withDetail = PushEventText.forEvent(
        'game_finished',
        detail: 'Carol',
      );
      expect(withDetail.$2, contains('Carol'));
    });

    test('no rendered text ever contains an unresolved placeholder', () {
      const events = [
        'target_assigned',
        'compass_pulse',
        'frame_to_judge',
        'frame_verdict',
        'warning',
        'you_died',
        'game_finished',
        'unknown_event',
      ];
      for (final event in events) {
        final (title, body) = PushEventText.forEvent(event);
        expect(title, isNot(contains(r'$')), reason: 'event: $event');
        expect(body, isNot(contains(r'$')), reason: 'event: $event');
      }
    });
  });
}
