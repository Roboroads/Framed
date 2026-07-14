import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/game/di.dart';
import '../../features/game/domain/game_repository.dart';
import '../../features/lobby/di.dart';
import '../push/push_service.dart';
import '../realtime/game_channels.dart';
import '../session/game_session.dart';
import '../session/session_resume_service.dart';
import '../session/session_store.dart';

final getIt = GetIt.instance;

/// Register app-wide singletons. Feature registrations go in their own
/// feature `di.dart` files, called from here.
void configureDependencies() {
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerLazySingleton<GameChannels>(() => GameChannels(getIt()));
  getIt.registerLazySingleton<SessionStore>(SessionStore.new);
  getIt.registerLazySingleton<PushService>(PushService.new);
  configureLobbyDependencies();
  configureGameDependencies();
  getIt.registerLazySingleton<SessionResumeService>(
    () => SessionResumeService(
      store: getIt(),
      session: getIt<GameSession>(),
      repository: getIt<GameRepository>(),
    ),
  );
}
