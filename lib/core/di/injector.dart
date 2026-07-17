import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/game/data/supabase_game_repository.dart';
import '../../features/game/domain/game_repository.dart';
import '../../features/lobby/data/supabase_lobby_repository.dart';
import '../../features/lobby/domain/lobby_repository.dart';
import '../audio/game_sounds.dart';
import '../location/wake_lock_service.dart';
import '../push/local_alarms.dart';
import '../push/push_service.dart';
import '../realtime/game_channels.dart';
import '../session/game_session.dart';
import '../session/session_resume_service.dart';
import '../session/session_store.dart';

final getIt = GetIt.instance;

/// Register app-wide singletons and feature dependencies.
void configureDependencies() {
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerLazySingleton<GameChannels>(() => GameChannels(getIt()));
  getIt.registerLazySingleton<SessionStore>(SessionStore.new);
  getIt.registerLazySingleton<GameSounds>(AudioPlayerGameSounds.new);
  getIt.registerLazySingleton<PushService>(PushService.new);
  getIt.registerLazySingleton<LocalAlarms>(FlutterLocalAlarms.new);
  getIt.registerLazySingleton<WakeLockService>(FlutterWakeLockService.new);
  getIt.registerLazySingleton<LobbyRepository>(
    () => SupabaseLobbyRepository(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<GameSession>(() => GameSession(getIt()));
  getIt.registerLazySingleton<GameRepository>(
    () => SupabaseGameRepository(getIt<SupabaseClient>()),
  );
  getIt.registerLazySingleton<SessionResumeService>(
    () => SessionResumeService(
      store: getIt(),
      session: getIt<GameSession>(),
      repository: getIt<GameRepository>(),
    ),
  );
}
