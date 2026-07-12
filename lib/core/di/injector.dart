import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../realtime/game_channels.dart';

final getIt = GetIt.instance;

/// Register app-wide singletons. Feature registrations go in their own
/// feature `di.dart` files, called from here.
void configureDependencies() {
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerLazySingleton<GameChannels>(() => GameChannels(getIt()));
}
