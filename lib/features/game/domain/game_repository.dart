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

  /// Uploads the already-encrypted frame photo to `frames/{photoPath}`
  /// (#19). Upserts, so a retry after a dropped connection can safely
  /// re-upload to the same path instead of erroring on conflict.
  Future<void> uploadFramePhoto({
    required String photoPath,
    required Uint8List encryptedBytes,
  });

  /// `submit_frame(game_id, photo_path)` (#19) — the photo must already be
  /// uploaded at that path. Throws [PostgrestException] on any guard
  /// failure; see [FrameError] for the stable codes.
  Future<void> submitFrame({required String gameId, required String photoPath});

  /// Downloads the still-encrypted frame photo at [path]
  /// (`frames/{game_id}/{uuid}`) — callers decrypt it with the game key.
  Future<Uint8List> downloadFramePhoto(String path);

  /// `cast_vote(frame_id, vote)` (#20). A vote on an already-resolved or
  /// voided frame is a silent server-side no-op, not an error.
  Future<void> castVote({required String frameId, required bool vote});
}
