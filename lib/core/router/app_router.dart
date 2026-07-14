import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/finish/finish_page.dart';
import '../../features/game/presentation/ingame/ingame_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../realtime/game_event.dart';
import '../../features/lobby/presentation/host_setup/host_setup_page.dart';
import '../../features/lobby/presentation/join/join_page.dart';
import '../../features/lobby/presentation/lobby/lobby_page.dart';
import '../../features/lobby/presentation/scan/scan_page.dart';
import '../crypto/qr_payload.dart';
import '../di/injector.dart';
import '../location/background_location_gate.dart';
import '../permissions/permission_gate.dart';
import '../session/game_session.dart';

/// The app's declarative route table (issue #49).
///
/// Everything reachable by a normal in-app tap is a named route here. The
/// ephemeral "open the camera, get bytes back" flows (selfie capture,
/// frame capture/confirm — see PreJoinForm, IngamePage's frame button,
/// FrameConfirmPage) stay plain `Navigator.push` calls at their call
/// sites on purpose: they return non-serializable data (raw photo bytes,
/// a live IngameBloc) and are never a bookmarkable/deep-linkable
/// destination, which is the entire point of a route existing here. A
/// plain push still works fine layered on top of a GoRouter Navigator.
final appRouter = GoRouter(
  initialLocation: '/',
  redirect: _redirectJoinLink,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/permission-gate',
      // Two callers: an in-app push with `extra` set to the next route
      // (home_page's QR-scan entry), or the join-link redirect below, which
      // can only pass a location string (redirect has no `extra` param) —
      // carried as a `next` query parameter instead.
      builder: (context, state) => PermissionGate(
        nextRoute: state.extra as String? ?? state.uri.queryParameters['next']!,
      ),
    ),
    GoRoute(path: '/scan', builder: (context, state) => const ScanPage()),
    GoRoute(path: '/join', builder: _buildJoinPage),
    GoRoute(
      path: '/host-setup',
      builder: (context, state) => const HostSetupPage(),
    ),
    GoRoute(path: '/lobby', builder: (context, state) => const LobbyPage()),
    GoRoute(
      path: '/location-gate',
      builder: (context, state) =>
          BackgroundLocationGate(initialEndsAt: state.extra! as DateTime),
    ),
    GoRoute(
      path: '/ingame',
      builder: (context, state) =>
          IngamePage(initialEndsAt: state.extra! as DateTime),
    ),
    GoRoute(
      path: '/finish',
      builder: (context, state) =>
          FinishPage(event: state.extra! as GameFinished),
    ),
  ],
);

// https://getframed.fun/join?v=1&t={token}#k={key} (the QR payload format,
// core/crypto/qr_payload.dart — an Android App Link / iOS Universal Link,
// #66) has "join" as a *path* segment, but go_router's own route table
// only ever sees a same-app in-app navigation as far as its `path` field —
// it has no way to match "https://getframed.fun/join" against a plain
// "/join" GoRoute. Rewrite it to /permission-gate once, here, preserving
// the query (v, t) and fragment (k) as the gate's `next` destination —
// same PermissionGate stop the QR-scan path already goes through (#76:
// a join link used to skip it and land straight on JoinPage), rather than
// changing the wire format QR codes and shared links use.
//
// Android redelivers the same intent (singleTop launch mode) on a second
// tap of the link, or any other stale VIEW redelivery — see #72. Without a
// session check this yanked a player already in the lobby (or further:
// ingame, judging, death, finish) back onto a fresh JoinPage, and a
// resubmit silently swapped their session out from under the still-live
// LobbyBloc/IngameBloc bound to the old one. GameSession.isActive is true
// from create_game/join_game success until the game ends or is left, so a
// join intent arriving while it's true is always redundant — a device
// can't meaningfully be in two games at once. Redirecting to '/' rather
// than just returning null: an unmatched location (this URI's path is
// empty, not a registered route) would otherwise replace the current
// screen with go_router's error page. '/' re-runs HomePage's session
// resume, which lands back on the correct live screen instead.
String? _redirectJoinLink(BuildContext context, GoRouterState state) {
  final uri = state.uri;
  if (uri.host != 'getframed.fun' || uri.path != '/join') return null;
  if (getIt<GameSession>().isActive) return '/';
  final next = Uri(
    path: '/join',
    queryParameters: uri.queryParameters,
    fragment: uri.fragment,
  ).toString();
  return Uri(
    path: '/permission-gate',
    queryParameters: {'next': next},
  ).toString();
}

Widget _buildJoinPage(BuildContext context, GoRouterState state) {
  if (state.extra case final QrPayload payload) {
    return JoinPage(
      joinToken: payload.joinToken,
      gameKeyBytes: payload.keyBytes,
    );
  }
  // No extra: reached via an https://getframed.fun/join link, routed
  // through /permission-gate first and pushed here as a bare
  // /join?...#... path once permissions are granted — parse it directly,
  // reusing QrPayload's own validation rather than duplicating it
  // (QrPayload.parse doesn't check scheme/host itself, exactly so this
  // bare-path shape parses too).
  try {
    final payload = QrPayload.parse(state.uri.toString());
    return JoinPage(
      joinToken: payload.joinToken,
      gameKeyBytes: payload.keyBytes,
    );
  } on QrPayloadFormatException {
    return const HomePage();
  }
}
