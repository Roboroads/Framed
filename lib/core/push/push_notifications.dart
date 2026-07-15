import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../i18n/strings.g.dart';

/// Renders the local notification a push wakeup (#28) resolves into.
/// Max-importance Android channel (this is the pocket-attention path,
/// IDEA.md "Notifications") — iOS's equivalent (time-sensitive
/// interruption level) needs the Time Sensitive entitlement, tracked as
/// real-device work under #31.
class PushNotifications {
  PushNotifications._();

  static const _channelId = 'framed_game_events';
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          AndroidNotificationChannel(
            _channelId,
            t.push.channelName,
            description: t.push.channelDescription,
            importance: Importance.max,
          ),
        );
    _initialized = true;
  }

  static Future<void> show({
    required String title,
    required String body,
  }) async {
    await ensureInitialized();
    await _plugin.show(
      // Millisecond timestamps collide less than a fixed id — a burst of
      // two pushes should show as two notifications, not one overwritten
      // by the other (there's no dedupe/grouping requirement here).
      DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          t.push.channelName,
          channelDescription: t.push.channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  /// A local alarm (#46): fires around [at] — inexact, not
  /// [AndroidScheduleMode.exactAllowWhileIdle], deliberately: exact alarms
  /// need `SCHEDULE_EXACT_ALARM`, a separate runtime-grantable permission
  /// on Android 12+ that would need its own request/explainer flow (like
  /// background location's, `BackgroundLocationGate`) for a feature that's
  /// only ever a fallback for a missed push, not the primary delivery
  /// path. A few minutes of OS-batched slack here is an acceptable
  /// trade-off against that whole extra permission surface. The caller
  /// (see `LocalAlarms`) is responsible for cancelling this first if a
  /// matching push already arrived. [id] identifies the alarm slot (a
  /// fixed constant per use, not per occurrence) — scheduling the same
  /// [id] again replaces whatever was pending under it, same
  /// `flutter_local_notifications` behavior [show] already relies on.
  static Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime at,
  }) async {
    await ensureInitialized();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      // UTC, not tz.local: this only ever needs to fire at one absolute
      // instant, never a repeating local-calendar time, so there's no
      // reason to resolve (or ship a dependency to resolve) the device's
      // actual timezone name just for this.
      tz.TZDateTime.from(at, tz.UTC),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          t.push.channelName,
          channelDescription: t.push.channelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> cancel(int id) async {
    await ensureInitialized();
    await _plugin.cancel(id);
  }
}
