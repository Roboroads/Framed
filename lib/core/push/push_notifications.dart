import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
}
