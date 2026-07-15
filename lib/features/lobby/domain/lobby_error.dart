import 'package:postgrest/postgrest.dart';

/// The stable error codes raised by the lobby RPCs
/// (backend/volumes/db/init/13-lobby.sql, 14-start-tick.sql), as
/// `raise exception using message = 'code'` — surfaced to Dart via
/// [PostgrestException.message].
enum LobbyError {
  badSettings('bad_settings'),
  nameTaken('name_taken'),
  tooFewPlayers('too_few_players'),
  unknown('');

  const LobbyError(this.code);

  final String code;

  static LobbyError fromException(Object error) {
    if (error is! PostgrestException) return unknown;
    return values.firstWhere(
      (e) => e != unknown && e.code == error.message,
      orElse: () => unknown,
    );
  }
}
