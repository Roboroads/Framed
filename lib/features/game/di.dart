import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/di/injector.dart';
import 'data/supabase_game_repository.dart';
import 'domain/game_repository.dart';

void configureGameDependencies() {
  getIt.registerLazySingleton<GameRepository>(
    () => SupabaseGameRepository(getIt<SupabaseClient>()),
  );
}
