import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/game_mode.dart';
import '../../domain/lobby_error.dart';

part 'host_setup_state.freezed.dart';

enum HostSetupStatus { editing, submitting, success, failure }

@freezed
sealed class HostSetupState with _$HostSetupState {
  const factory HostSetupState({
    @Default(HostSetupStatus.editing) HostSetupStatus status,
    @Default(GameMode.mostFrames) GameMode mode,
    LatLng? geofenceCenter,
    @Default(200) int geofenceRadiusM,
    @Default(10) int disperseMinutes,
    @Default(2) int softPunishmentMinutes,
    @Default(5) int hardPunishmentMinutes,
    @Default(10) int compassUpdateIntervalMinutes,
    @Default(30) int compassViewSeconds,
    @Default(5) int voteTimeoutMinutes,
    @Default(5) int frameCooldownMinutes,
    @Default('') String name,
    Uint8List? selfieBytes,
    // Set once status reaches success — the lobby screen's inputs.
    String? gameId,
    String? joinTokenForQr,
    Uint8List? gameKeyForQr,
    LobbyError? error,
  }) = _HostSetupState;

  const HostSetupState._();

  bool get canSubmit =>
      status != HostSetupStatus.submitting &&
      name.trim().isNotEmpty &&
      selfieBytes != null &&
      geofenceCenter != null;
}
