import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injector.dart';
import '../../core/session/game_session.dart';
import 'data/supabase_lobby_repository.dart';
import 'domain/lobby_repository.dart';

void configureLobbyDependencies() {
  getIt.registerLazySingleton<LobbyRepository>(
    () => SupabaseLobbyRepository(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<GameSession>(GameSession.new);
}
