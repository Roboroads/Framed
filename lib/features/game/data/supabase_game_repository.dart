import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/realtime/game_event.dart';
import '../domain/game_repository.dart';
import '../domain/geofence_info.dart';

class SupabaseGameRepository implements GameRepository {
  SupabaseGameRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Uint8List> downloadSelfie(String path) {
    return _client.storage.from('selfies').download(path);
  }

  @override
  Future<void> submitLocation({
    required String gameId,
    required double lat,
    required double lng,
  }) async {
    await _client.rpc(
      'submit_location',
      params: {'game_id': gameId, 'lat': lat, 'lng': lng},
    );
  }

  @override
  Future<GeofenceInfo> getGeofence(String gameId) async {
    final row = await _client
        .rpc('get_my_geofence', params: {'game_id': gameId})
        .single();
    return GeofenceInfo(
      lat: (row['lat'] as num).toDouble(),
      lng: (row['lng'] as num).toDouble(),
      radiusM: row['radius_m'] as int,
    );
  }

  @override
  Future<void> uploadFramePhoto({
    required String photoPath,
    required Uint8List encryptedBytes,
  }) async {
    await _client.storage
        .from('frames')
        .uploadBinary(
          photoPath,
          encryptedBytes,
          fileOptions: const FileOptions(upsert: true),
        );
  }

  @override
  Future<void> submitFrame({
    required String gameId,
    required String photoPath,
  }) async {
    await _client.rpc(
      'submit_frame',
      params: {'game_id': gameId, 'photo_path': photoPath},
    );
  }

  @override
  Future<Uint8List> downloadFramePhoto(String path) {
    return _client.storage.from('frames').download(path);
  }

  @override
  Future<void> castVote({required String frameId, required bool vote}) async {
    await _client.rpc('cast_vote', params: {'frame_id': frameId, 'vote': vote});
  }

  @override
  Future<MyStateResult> getMyState(String gameId) async {
    final result =
        await _client.rpc('get_my_state', params: {'p_game_id': gameId})
            as Map<String, dynamic>;
    final gameStatus = result['game_status'] as String;
    final nextPulseAt = result['next_pulse_at'] != null
        ? DateTime.parse(result['next_pulse_at'] as String)
        : null;
    final activeWarning = result['active_warning'] != null
        ? GameEvent.fromBroadcast(
            'warning',
            Map<String, dynamic>.from(result['active_warning'] as Map),
          )
        : null;
    final eventName = result['event'] as String?;
    final event = eventName != null
        ? GameEvent.fromBroadcast(
            eventName,
            Map<String, dynamic>.from(result['payload'] as Map),
          )
        : null;
    return (
      gameStatus: gameStatus,
      event: event,
      nextPulseAt: nextPulseAt,
      activeWarning: activeWarning,
    );
  }

  @override
  Future<Map<String, String>> getRoster(String gameId) async {
    final rows = await _client
        .from('players')
        .select('id, name_ciphertext')
        .eq('game_id', gameId);
    return {
      for (final row in rows)
        row['id'] as String: row['name_ciphertext'] as String,
    };
  }

  @override
  Future<List<ChatMessageEvent>> fetchChatHistory(String gameId) async {
    final rows = await _client
        .from('chat_messages')
        .select('id, sender_id, ciphertext, created_at')
        .eq('game_id', gameId)
        .order('created_at');
    return [
      for (final row in rows)
        ChatMessageEvent(
          messageId: row['id'] as String,
          senderId: row['sender_id'] as String,
          ciphertext: row['ciphertext'] as String,
          createdAt: DateTime.parse(row['created_at'] as String),
        ),
    ];
  }

  @override
  Future<String> sendChat({
    required String gameId,
    required String ciphertext,
  }) async {
    return await _client.rpc(
          'send_chat',
          params: {'p_game_id': gameId, 'p_ciphertext': ciphertext},
        )
        as String;
  }

  @override
  Future<String> getGameMode(String gameId) async {
    final row = await _client
        .from('games')
        .select('mode')
        .eq('id', gameId)
        .single();
    return row['mode'] as String;
  }

  @override
  Future<(String, bool)> myPlayerInfo(String gameId) async {
    // auth_uid isn't a client-selectable/filterable column (11-policies.sql
    // grants id/game_id/name_ciphertext/selfie_path/is_host/status/joined_at
    // only) — framed_my_player is the sanctioned "which row is mine" path,
    // already exposed to authenticated clients for exactly this.
    final playerId =
        await _client.rpc('framed_my_player', params: {'gid': gameId})
            as String;
    final row = await _client
        .from('players')
        .select('is_host')
        .eq('id', playerId)
        .single();
    return (playerId, row['is_host'] as bool);
  }

  @override
  Future<String> replayGame({
    required String gameId,
    required String keyCiphertext,
  }) async {
    return await _client.rpc(
          'replay_game',
          params: {'game_id': gameId, 'key_ciphertext': keyCiphertext},
        )
        as String;
  }

  @override
  Future<void> uploadReplaySelfie({
    required String path,
    required Uint8List encryptedBytes,
  }) async {
    await _client.storage
        .from('selfies')
        .uploadBinary(
          path,
          encryptedBytes,
          fileOptions: const FileOptions(upsert: true),
        );
  }

  @override
  Future<void> rejoinReplay({
    required String gameId,
    required String nameCiphertext,
    required String nameHmac,
  }) async {
    await _client.rpc(
      'rejoin_replay',
      params: {
        'game_id': gameId,
        'name_ciphertext': nameCiphertext,
        'name_hmac': nameHmac,
      },
    );
  }

  @override
  Future<void> leaveFinishedGame(String gameId) async {
    await _client.rpc('leave_finished_game', params: {'game_id': gameId});
  }

  @override
  Future<Map<String, String>> getDeadPlayers(String gameId) async {
    final rows = await _client.rpc(
      'get_dead_players',
      params: {'p_game_id': gameId},
    );
    return {
      for (final row in rows as List)
        row['player_id'] as String: row['name_ciphertext'] as String,
    };
  }

  @override
  Future<void> leaveActiveGame(String gameId) async {
    await _client.rpc('leave_active_game', params: {'game_id': gameId});
  }

  @override
  Future<void> updatePushToken({
    required String gameId,
    required String token,
  }) async {
    // RLS (players_own_update, 11-policies.sql) already restricts this to
    // the caller's own row; the game_id filter just keeps it from also
    // touching a stale row in some other game this auth_uid was once in.
    await _client
        .from('players')
        .update({'push_token': token})
        .eq('game_id', gameId);
  }
}
