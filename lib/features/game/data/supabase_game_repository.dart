import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

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
}
