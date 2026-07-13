import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/game_mode.dart';
import '../domain/game_settings.dart';
import '../domain/lobby_repository.dart';
import '../domain/lobby_roster_entry.dart';
import '../domain/lobby_snapshot.dart';

class SupabaseLobbyRepository implements LobbyRepository {
  SupabaseLobbyRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<(String, String)> createGame({
    required GameSettings settings,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) async {
    final res =
        await _client.rpc(
              'create_game',
              params: {
                'settings': {
                  ...settings.toJson(),
                  'name_ciphertext': nameCiphertext,
                  'name_hmac': nameHmac,
                  'platform': platform,
                  'push_token': ?pushToken,
                },
              },
            )
            as Map<String, dynamic>;
    return (res['game_id'] as String, res['join_token'] as String);
  }

  @override
  Future<(String, String)> joinGame({
    required String joinToken,
    required String nameCiphertext,
    required String nameHmac,
    required String platform,
    String? pushToken,
  }) async {
    final res =
        await _client.rpc(
              'join_game',
              params: {
                'join_token': joinToken,
                'name_ciphertext': nameCiphertext,
                'name_hmac': nameHmac,
                'platform': platform,
                'push_token': ?pushToken,
              },
            )
            as Map<String, dynamic>;
    return (res['game_id'] as String, res['player_id'] as String);
  }

  @override
  Future<void> updateSettings({
    required String gameId,
    required Map<String, dynamic> settings,
  }) {
    return _client.rpc(
      'update_settings',
      params: {'game_id': gameId, 'settings': settings},
    );
  }

  @override
  Future<void> leaveLobby(String gameId) {
    return _client.rpc('leave_lobby', params: {'game_id': gameId});
  }

  @override
  Future<String> myHostPlayerId(String gameId) async {
    final row = await _client
        .from('players')
        .select('id')
        .eq('game_id', gameId)
        .eq('is_host', true)
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> uploadSelfie({
    required String gameId,
    required String playerId,
    required Uint8List encryptedSelfie,
  }) async {
    final path = '$gameId/$playerId';
    await _client.storage.from('selfies').uploadBinary(path, encryptedSelfie);
    await _client.rpc('set_selfie', params: {'game_id': gameId, 'path': path});
  }

  @override
  Future<LobbySnapshot> fetchLobby(String gameId) async {
    final game = await _client
        .from('games')
        .select(
          'host_player_id, join_token, mode, disperse_minutes, '
          'soft_punishment_minutes, hard_punishment_minutes, '
          'compass_update_interval_minutes, compass_view_seconds, '
          'vote_timeout_minutes, frame_cooldown_minutes, geofence_radius_m, '
          'geofence_lat, geofence_lng',
        )
        .eq('id', gameId)
        .single();
    final players = await _client
        .from('players')
        .select('id, name_ciphertext, selfie_path')
        .eq('game_id', gameId)
        .order('joined_at');

    return LobbySnapshot(
      hostPlayerId: game['host_player_id'] as String,
      joinToken: game['join_token'] as String?,
      mode: GameMode.fromWireValue(game['mode'] as String),
      disperseMinutes: game['disperse_minutes'] as int,
      softPunishmentMinutes: game['soft_punishment_minutes'] as int,
      hardPunishmentMinutes: game['hard_punishment_minutes'] as int,
      compassUpdateIntervalMinutes:
          game['compass_update_interval_minutes'] as int,
      compassViewSeconds: game['compass_view_seconds'] as int,
      voteTimeoutMinutes: game['vote_timeout_minutes'] as int,
      frameCooldownMinutes: game['frame_cooldown_minutes'] as int,
      geofenceRadiusM: game['geofence_radius_m'] as int,
      geofenceLat: (game['geofence_lat'] as num).toDouble(),
      geofenceLng: (game['geofence_lng'] as num).toDouble(),
      roster: [
        for (final p in players)
          LobbyRosterEntry(
            playerId: p['id'] as String,
            nameCiphertext: p['name_ciphertext'] as String,
            hasSelfie: p['selfie_path'] != null,
          ),
      ],
    );
  }

  @override
  Future<void> startGame(String gameId) {
    return _client.rpc('start_game', params: {'game_id': gameId});
  }
}
