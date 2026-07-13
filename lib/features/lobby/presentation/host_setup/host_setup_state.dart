import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/lobby_error.dart';

part 'host_setup_state.freezed.dart';

enum HostSetupStatus { editing, submitting, success, failure }

/// Name + selfie + a GPS-derived geofence center only — game mode, play
/// area radius, and timing all default (see GameSettings) and move to the
/// lobby's own "Game settings" screen, editable after the game exists (#62).
@freezed
sealed class HostSetupState with _$HostSetupState {
  const factory HostSetupState({
    @Default(HostSetupStatus.editing) HostSetupStatus status,
    LatLng? geofenceCenter,
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
