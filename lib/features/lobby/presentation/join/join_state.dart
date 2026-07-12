import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/lobby_error.dart';

part 'join_state.freezed.dart';

enum JoinStatus { editing, submitting, success, failure }

@freezed
sealed class JoinState with _$JoinState {
  const factory JoinState({
    @Default(JoinStatus.editing) JoinStatus status,
    @Default('') String name,
    Uint8List? selfieBytes,
    LobbyError? error,
  }) = _JoinState;

  const JoinState._();

  bool get canSubmit =>
      status != JoinStatus.submitting &&
      name.trim().isNotEmpty &&
      selfieBytes != null;
}
