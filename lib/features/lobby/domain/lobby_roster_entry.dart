import 'package:freezed_annotation/freezed_annotation.dart';

part 'lobby_roster_entry.freezed.dart';

/// One row of the `players` table as the lobby needs it — still encrypted;
/// [LobbyBloc] decrypts the name with the game key.
@freezed
sealed class LobbyRosterEntry with _$LobbyRosterEntry {
  const factory LobbyRosterEntry({
    required String playerId,
    required String nameCiphertext,
    required bool hasSelfie,
  }) = _LobbyRosterEntry;
}
