import 'dart:typed_data';

import 'geofence_info.dart';

/// Storage + location access for the game feature.
abstract interface class GameRepository {
  /// Downloads the still-encrypted selfie at [path] (`selfies/{game_id}/{player_id}`,
  /// RLS-gated to members of that game) — callers decrypt it with the game key.
  Future<Uint8List> downloadSelfie(String path);

  /// Reports this device's current position. Plaintext server-side by
  /// design — the server enforces the geofence, compass, and staleness with
  /// it (#12). Alive players only, dispersing/active games only.
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  });

  /// The game's play area, for the soft-punishment target map (#18) — the
  /// geofence is set once at host setup and static for the whole game.
  Future<GeofenceInfo> getGeofence(String gameId);
}
