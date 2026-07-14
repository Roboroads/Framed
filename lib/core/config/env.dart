/// Backend endpoints. Override per environment with --dart-define, e.g.
/// flutter run --dart-define=SUPABASE_URL=https://framed.example.eu
///
/// Defaults target the local dev backend (backend/docker-compose.yml).
/// Android emulator: use --dart-define=SUPABASE_URL=http://10.0.2.2:8000
/// (localhost inside the emulator is the emulator itself).
///
/// The anon key below is the publicly documented Supabase demo key — it only
/// works against the local dev stack and is not a secret.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyAgCiAgICAicm9sZSI6ICJhbm9uIiwKICAgICJpc3MiOiAic3VwYWJhc2UtZGVtbyIsCiAgICAiaWF0IjogMTY0MTc2OTIwMCwKICAgICJleHAiOiAxNzk5NTM1NjAwCn0.dc_X5iR_VP_qT0zsiyj_I_OZ2T9FtRU2BBNWN8Bu4GE',
  );

  /// GeofenceMap's tile source (#75). Defaults to OSM's own tile server,
  /// fine for development but not for real release traffic — OSM's Tile
  /// Usage Policy treats that server as a volunteer-funded, best-effort
  /// service, not a production CDN. Override with a real provider's
  /// template before shipping, e.g.
  /// --dart-define=TILE_URL_TEMPLATE=https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=...
  static const tileUrlTemplate = String.fromEnvironment(
    'TILE_URL_TEMPLATE',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );
}
