import 'dart:typed_data';

/// Storage access for the game feature. One method for now: the target's
/// encrypted reference selfie (#11); frame photo upload etc. join later.
abstract interface class GameRepository {
  /// Downloads the still-encrypted selfie at [path] (`selfies/{game_id}/{player_id}`,
  /// RLS-gated to members of that game) — callers decrypt it with the game key.
  Future<Uint8List> downloadSelfie(String path);
}
