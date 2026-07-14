import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen from auto-locking (#78) — the ingame screen's default
/// state, so a compass pulse or warning modal is never missed to a
/// dimmed/locked screen while playing outside. A per-player toggle in case
/// someone wants to save battery instead.
abstract interface class WakeLockService {
  Future<void> enable();
  Future<void> disable();
}

class FlutterWakeLockService implements WakeLockService {
  @override
  Future<void> enable() => WakelockPlus.enable();

  @override
  Future<void> disable() => WakelockPlus.disable();
}
