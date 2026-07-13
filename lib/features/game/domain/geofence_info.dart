import 'package:freezed_annotation/freezed_annotation.dart';

part 'geofence_info.freezed.dart';

/// The game's play area (issue #18) — fetched once per ingame session,
/// static for the whole game (the host can't move the geofence mid-game).
@freezed
sealed class GeofenceInfo with _$GeofenceInfo {
  const factory GeofenceInfo({
    required double lat,
    required double lng,
    required int radiusM,
  }) = _GeofenceInfo;
}
