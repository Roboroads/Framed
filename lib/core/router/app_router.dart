import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/game/presentation/ingame/ingame_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/lobby/presentation/host_setup/host_setup_page.dart';
import '../../features/lobby/presentation/join/join_page.dart';
import '../../features/lobby/presentation/lobby/lobby_page.dart';
import '../../features/lobby/presentation/scan/scan_page.dart';
import '../crypto/qr_payload.dart';
import '../location/background_location_gate.dart';
import '../permissions/permission_gate.dart';

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
      builder: (context, state) =>
          PermissionGate(nextRoute: state.extra! as String),
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
  ],
);

// framed://join?v=1&t={token}&k={key} (the QR payload format,
// core/crypto/qr_payload.dart) is a custom-scheme link where "join" is the
// URI *host*, not the path — go_router matches routes by path, so it can't
// see this directly. Rewrite it to the internal /join path once, here,
// rather than changing a wire format QR codes and shared links already
// use.
String? _redirectJoinLink(BuildContext context, GoRouterState state) {
  final uri = state.uri;
  if (uri.scheme != 'framed' || uri.host != 'join') return null;
  return Uri(path: '/join', queryParameters: uri.queryParameters).toString();
}

Widget _buildJoinPage(BuildContext context, GoRouterState state) {
  if (state.extra case final QrPayload payload) {
    return JoinPage(
      joinToken: payload.joinToken,
      gameKeyBytes: payload.keyBytes,
    );
  }
  // No extra: reached via a framed://join link (rewritten by the redirect
  // above). Rebuild the original shape and reuse QrPayload's own
  // validation rather than duplicating it.
  final relink = Uri(
    scheme: 'framed',
    host: 'join',
    queryParameters: state.uri.queryParameters,
  );
  try {
    final payload = QrPayload.parse(relink.toString());
    return JoinPage(
      joinToken: payload.joinToken,
      gameKeyBytes: payload.keyBytes,
    );
  } on QrPayloadFormatException {
    return const HomePage();
  }
}
