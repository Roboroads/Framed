import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/game_settings.dart';
import '../domain/lobby_repository.dart';

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
    required GameSettings settings,
  }) {
    return _client.rpc(
      'update_settings',
      params: {'game_id': gameId, 'settings': settings.toJson()},
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
}
