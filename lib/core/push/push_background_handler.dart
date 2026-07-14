import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import '../crypto/game_crypto.dart';
import '../realtime/game_event.dart';
import '../session/session_store.dart';
import 'push_event_text.dart';
import 'push_notifications.dart';
import '../../features/game/data/supabase_game_repository.dart';

/// FCM's background-message entry point (#28) — a fresh isolate per
/// firebase_messaging's contract, so nothing from the main isolate's DI
/// (get_it, the live GameSession) is reachable here. Everything this needs
/// — the client, the persisted session, the game key — is rebuilt from
/// scratch, matching how [SessionResumeService] rebuilds a session on a
/// normal cold start.
///
/// Must stay top-level (or static) and keep this exact signature —
/// `FirebaseMessaging.onBackgroundMessage` reflects on it.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // No native Firebase project configured yet (#28's decision) — bail
    // rather than touch anything that assumes it succeeded.
    return;
  }

  final event = message.data['event'] as String?;
  final gameId = message.data['game_id'] as String?;
  if (event == null || gameId == null) return;

  final detail = await _fetchDetail(event: event, gameId: gameId);
  final (title, body) = PushEventText.forEvent(event, detail: detail);
  await PushNotifications.show(title: title, body: body);
}

// Best-effort enrichment: only target_assigned and you_died have a name
// worth fetching (get_my_state's current catch-up shape, #53/#54). Any
// failure here — no persisted session, a stale one, airplane mode — just
// means the per-event fallback text renders instead; it's never blocking
// and never leaks ciphertext.
Future<String?> _fetchDetail({
  required String event,
  required String gameId,
}) async {
  if (event != 'target_assigned' && event != 'you_died') return null;
  try {
    final persisted = await SessionStore().read();
    if (persisted == null || persisted.gameId != gameId) return null;

    if (Supabase.instance.client.auth.currentSession == null) {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
      );
    }
    final crypto = await GameCrypto.fromKeyBytes(persisted.keyBytes);
    final repository = SupabaseGameRepository(Supabase.instance.client);
    final fetched = (await repository.getMyState(gameId)).event;

    if (event == 'target_assigned' && fetched is TargetAssigned) {
      return await crypto.decryptString(fetched.nameCiphertext);
    }
    if (event == 'you_died' &&
        fetched is YouDied &&
        fetched.killerNameCiphertext != null) {
      return await crypto.decryptString(fetched.killerNameCiphertext!);
    }
    return null;
  } catch (_) {
    return null;
  }
}
