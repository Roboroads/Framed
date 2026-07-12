/// Mirrors the `game_mode` enum in `backend/volumes/db/init/10-schema.sql`.
/// See IDEA.md "Game modes".
enum GameMode {
  mostFrames('most_frames'),
  lastManStanding('last_man_standing');

  const GameMode(this.wireValue);

  /// The exact string the `mode` column and settings jsonb expect.
  final String wireValue;

  static GameMode fromWireValue(String value) =>
      values.firstWhere((m) => m.wireValue == value);
}
