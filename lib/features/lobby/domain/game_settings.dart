import 'package:freezed_annotation/freezed_annotation.dart';

import 'game_mode.dart';

part 'game_settings.freezed.dart';

/// The host-configurable game options (IDEA.md "Game options"). Plain
/// doubles for the geofence center, not a map-package LatLng — domain code
/// doesn't depend on presentation-layer packages.
@freezed
sealed class GameSettings with _$GameSettings {
  const factory GameSettings({
    @Default(GameMode.mostFrames) GameMode mode,
    required double geofenceLat,
    required double geofenceLng,
    @Default(500) int geofenceRadiusM,
    @Default(10) int disperseMinutes,
    @Default(2) int softPunishmentMinutes,
    @Default(5) int hardPunishmentMinutes,
    @Default(5) int compassUpdateIntervalMinutes,
    @Default(30) int compassViewSeconds,
    @Default(5) int voteTimeoutMinutes,
    @Default(2) int frameCooldownMinutes,
  }) = _GameSettings;

  const GameSettings._();

  /// Keys match the settings jsonb every lobby RPC reads
  /// (backend/volumes/db/init/13-lobby.sql, `framed_apply_settings`).
  Map<String, dynamic> toJson() => {
    'mode': mode.wireValue,
    'geofence_lat': geofenceLat,
    'geofence_lng': geofenceLng,
    'geofence_radius_m': geofenceRadiusM,
    'disperse_minutes': disperseMinutes,
    'soft_punishment_minutes': softPunishmentMinutes,
    'hard_punishment_minutes': hardPunishmentMinutes,
    'compass_update_interval_minutes': compassUpdateIntervalMinutes,
    'compass_view_seconds': compassViewSeconds,
    'vote_timeout_minutes': voteTimeoutMinutes,
    'frame_cooldown_minutes': frameCooldownMinutes,
  };
}
