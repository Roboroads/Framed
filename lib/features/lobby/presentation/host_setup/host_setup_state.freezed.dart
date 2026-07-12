// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'host_setup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HostSetupState {

 HostSetupStatus get status; GameMode get mode; LatLng? get geofenceCenter; int get geofenceRadiusM; int get disperseMinutes; int get softPunishmentMinutes; int get hardPunishmentMinutes; int get compassUpdateIntervalMinutes; int get compassViewSeconds; int get voteTimeoutMinutes; int get frameCooldownMinutes; String get name; Uint8List? get selfieBytes;// Set once status reaches success — the lobby screen's inputs.
 String? get gameId; String? get joinTokenForQr; Uint8List? get gameKeyForQr; LobbyError? get error;
/// Create a copy of HostSetupState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HostSetupStateCopyWith<HostSetupState> get copyWith => _$HostSetupStateCopyWithImpl<HostSetupState>(this as HostSetupState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HostSetupState&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.geofenceCenter, geofenceCenter) || other.geofenceCenter == geofenceCenter)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selfieBytes, selfieBytes)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.joinTokenForQr, joinTokenForQr) || other.joinTokenForQr == joinTokenForQr)&&const DeepCollectionEquality().equals(other.gameKeyForQr, gameKeyForQr)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,mode,geofenceCenter,geofenceRadiusM,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes,name,const DeepCollectionEquality().hash(selfieBytes),gameId,joinTokenForQr,const DeepCollectionEquality().hash(gameKeyForQr),error);

@override
String toString() {
  return 'HostSetupState(status: $status, mode: $mode, geofenceCenter: $geofenceCenter, geofenceRadiusM: $geofenceRadiusM, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes, name: $name, selfieBytes: $selfieBytes, gameId: $gameId, joinTokenForQr: $joinTokenForQr, gameKeyForQr: $gameKeyForQr, error: $error)';
}


}

/// @nodoc
abstract mixin class $HostSetupStateCopyWith<$Res>  {
  factory $HostSetupStateCopyWith(HostSetupState value, $Res Function(HostSetupState) _then) = _$HostSetupStateCopyWithImpl;
@useResult
$Res call({
 HostSetupStatus status, GameMode mode, LatLng? geofenceCenter, int geofenceRadiusM, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes, String name, Uint8List? selfieBytes, String? gameId, String? joinTokenForQr, Uint8List? gameKeyForQr, LobbyError? error
});




}
/// @nodoc
class _$HostSetupStateCopyWithImpl<$Res>
    implements $HostSetupStateCopyWith<$Res> {
  _$HostSetupStateCopyWithImpl(this._self, this._then);

  final HostSetupState _self;
  final $Res Function(HostSetupState) _then;

/// Create a copy of HostSetupState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? mode = null,Object? geofenceCenter = freezed,Object? geofenceRadiusM = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,Object? name = null,Object? selfieBytes = freezed,Object? gameId = freezed,Object? joinTokenForQr = freezed,Object? gameKeyForQr = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HostSetupStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,geofenceCenter: freezed == geofenceCenter ? _self.geofenceCenter : geofenceCenter // ignore: cast_nullable_to_non_nullable
as LatLng?,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selfieBytes: freezed == selfieBytes ? _self.selfieBytes : selfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,joinTokenForQr: freezed == joinTokenForQr ? _self.joinTokenForQr : joinTokenForQr // ignore: cast_nullable_to_non_nullable
as String?,gameKeyForQr: freezed == gameKeyForQr ? _self.gameKeyForQr : gameKeyForQr // ignore: cast_nullable_to_non_nullable
as Uint8List?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LobbyError?,
  ));
}

}


/// Adds pattern-matching-related methods to [HostSetupState].
extension HostSetupStatePatterns on HostSetupState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HostSetupState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HostSetupState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HostSetupState value)  $default,){
final _that = this;
switch (_that) {
case _HostSetupState():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HostSetupState value)?  $default,){
final _that = this;
switch (_that) {
case _HostSetupState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HostSetupStatus status,  GameMode mode,  LatLng? geofenceCenter,  int geofenceRadiusM,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  String name,  Uint8List? selfieBytes,  String? gameId,  String? joinTokenForQr,  Uint8List? gameKeyForQr,  LobbyError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HostSetupState() when $default != null:
return $default(_that.status,_that.mode,_that.geofenceCenter,_that.geofenceRadiusM,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.name,_that.selfieBytes,_that.gameId,_that.joinTokenForQr,_that.gameKeyForQr,_that.error);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HostSetupStatus status,  GameMode mode,  LatLng? geofenceCenter,  int geofenceRadiusM,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  String name,  Uint8List? selfieBytes,  String? gameId,  String? joinTokenForQr,  Uint8List? gameKeyForQr,  LobbyError? error)  $default,) {final _that = this;
switch (_that) {
case _HostSetupState():
return $default(_that.status,_that.mode,_that.geofenceCenter,_that.geofenceRadiusM,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.name,_that.selfieBytes,_that.gameId,_that.joinTokenForQr,_that.gameKeyForQr,_that.error);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HostSetupStatus status,  GameMode mode,  LatLng? geofenceCenter,  int geofenceRadiusM,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  String name,  Uint8List? selfieBytes,  String? gameId,  String? joinTokenForQr,  Uint8List? gameKeyForQr,  LobbyError? error)?  $default,) {final _that = this;
switch (_that) {
case _HostSetupState() when $default != null:
return $default(_that.status,_that.mode,_that.geofenceCenter,_that.geofenceRadiusM,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.name,_that.selfieBytes,_that.gameId,_that.joinTokenForQr,_that.gameKeyForQr,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _HostSetupState extends HostSetupState {
  const _HostSetupState({this.status = HostSetupStatus.editing, this.mode = GameMode.mostFrames, this.geofenceCenter, this.geofenceRadiusM = 200, this.disperseMinutes = 10, this.softPunishmentMinutes = 2, this.hardPunishmentMinutes = 5, this.compassUpdateIntervalMinutes = 10, this.compassViewSeconds = 30, this.voteTimeoutMinutes = 5, this.frameCooldownMinutes = 5, this.name = '', this.selfieBytes, this.gameId, this.joinTokenForQr, this.gameKeyForQr, this.error}): super._();
  

@override@JsonKey() final  HostSetupStatus status;
@override@JsonKey() final  GameMode mode;
@override final  LatLng? geofenceCenter;
@override@JsonKey() final  int geofenceRadiusM;
@override@JsonKey() final  int disperseMinutes;
@override@JsonKey() final  int softPunishmentMinutes;
@override@JsonKey() final  int hardPunishmentMinutes;
@override@JsonKey() final  int compassUpdateIntervalMinutes;
@override@JsonKey() final  int compassViewSeconds;
@override@JsonKey() final  int voteTimeoutMinutes;
@override@JsonKey() final  int frameCooldownMinutes;
@override@JsonKey() final  String name;
@override final  Uint8List? selfieBytes;
// Set once status reaches success — the lobby screen's inputs.
@override final  String? gameId;
@override final  String? joinTokenForQr;
@override final  Uint8List? gameKeyForQr;
@override final  LobbyError? error;

/// Create a copy of HostSetupState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HostSetupStateCopyWith<_HostSetupState> get copyWith => __$HostSetupStateCopyWithImpl<_HostSetupState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HostSetupState&&(identical(other.status, status) || other.status == status)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.geofenceCenter, geofenceCenter) || other.geofenceCenter == geofenceCenter)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selfieBytes, selfieBytes)&&(identical(other.gameId, gameId) || other.gameId == gameId)&&(identical(other.joinTokenForQr, joinTokenForQr) || other.joinTokenForQr == joinTokenForQr)&&const DeepCollectionEquality().equals(other.gameKeyForQr, gameKeyForQr)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,mode,geofenceCenter,geofenceRadiusM,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes,name,const DeepCollectionEquality().hash(selfieBytes),gameId,joinTokenForQr,const DeepCollectionEquality().hash(gameKeyForQr),error);

@override
String toString() {
  return 'HostSetupState(status: $status, mode: $mode, geofenceCenter: $geofenceCenter, geofenceRadiusM: $geofenceRadiusM, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes, name: $name, selfieBytes: $selfieBytes, gameId: $gameId, joinTokenForQr: $joinTokenForQr, gameKeyForQr: $gameKeyForQr, error: $error)';
}


}

/// @nodoc
abstract mixin class _$HostSetupStateCopyWith<$Res> implements $HostSetupStateCopyWith<$Res> {
  factory _$HostSetupStateCopyWith(_HostSetupState value, $Res Function(_HostSetupState) _then) = __$HostSetupStateCopyWithImpl;
@override @useResult
$Res call({
 HostSetupStatus status, GameMode mode, LatLng? geofenceCenter, int geofenceRadiusM, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes, String name, Uint8List? selfieBytes, String? gameId, String? joinTokenForQr, Uint8List? gameKeyForQr, LobbyError? error
});




}
/// @nodoc
class __$HostSetupStateCopyWithImpl<$Res>
    implements _$HostSetupStateCopyWith<$Res> {
  __$HostSetupStateCopyWithImpl(this._self, this._then);

  final _HostSetupState _self;
  final $Res Function(_HostSetupState) _then;

/// Create a copy of HostSetupState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? mode = null,Object? geofenceCenter = freezed,Object? geofenceRadiusM = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,Object? name = null,Object? selfieBytes = freezed,Object? gameId = freezed,Object? joinTokenForQr = freezed,Object? gameKeyForQr = freezed,Object? error = freezed,}) {
  return _then(_HostSetupState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HostSetupStatus,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,geofenceCenter: freezed == geofenceCenter ? _self.geofenceCenter : geofenceCenter // ignore: cast_nullable_to_non_nullable
as LatLng?,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selfieBytes: freezed == selfieBytes ? _self.selfieBytes : selfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,gameId: freezed == gameId ? _self.gameId : gameId // ignore: cast_nullable_to_non_nullable
as String?,joinTokenForQr: freezed == joinTokenForQr ? _self.joinTokenForQr : joinTokenForQr // ignore: cast_nullable_to_non_nullable
as String?,gameKeyForQr: freezed == gameKeyForQr ? _self.gameKeyForQr : gameKeyForQr // ignore: cast_nullable_to_non_nullable
as Uint8List?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LobbyError?,
  ));
}


}

// dart format on
