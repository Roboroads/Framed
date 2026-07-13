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
  Future<(String, GameEvent?)> getMyState(String gameId) async {
    final result =
        await _client.rpc('get_my_state', params: {'p_game_id': gameId})
            as Map<String, dynamic>;
    final gameStatus = result['game_status'] as String;
    final eventName = result['event'] as String?;
    if (eventName == null) return (gameStatus, null);
    final event = GameEvent.fromBroadcast(
      eventName,
      Map<String, dynamic>.from(result['payload'] as Map),
    );
    return (gameStatus, event);
  }
}
