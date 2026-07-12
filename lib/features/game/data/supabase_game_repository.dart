import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/game_repository.dart';

class SupabaseGameRepository implements GameRepository {
  SupabaseGameRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Uint8List> downloadSelfie(String path) {
    return _client.storage.from('selfies').download(path);
  }
}
