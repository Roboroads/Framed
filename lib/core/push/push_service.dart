import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// FCM/APNs token lifecycle (#28). Every call here is best-effort: without
/// a real Firebase project (#28's decision — none exists yet), init
/// fails and every method degrades to "no push," never a crash — the app
/// already works fully over realtime alone.
class PushService {
  StreamSubscription<String>? _refreshSub;

  /// Obtained once at app start and passed into `create_game`/`join_game`
  /// (#8, #9) — null there is already the steady "no push token on file"
  /// state the backend expects.
  Future<String?> getToken() async {
    try {
      await Firebase.initializeApp();
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Rare (reinstall, FCM-side rotation) — [onRefresh] is expected to
  /// persist the new token server-side via the own-push-token update
  /// policy (11-policies.sql).
  void listenForRefresh(void Function(String token) onRefresh) {
    _refreshSub?.cancel();
    try {
      _refreshSub = FirebaseMessaging.instance.onTokenRefresh.listen(onRefresh);
    } catch (_) {
      // No Firebase project configured — nothing to listen to.
    }
  }
}
