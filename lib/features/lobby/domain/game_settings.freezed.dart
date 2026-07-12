// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameSettings {

 GameMode get mode; double get geofenceLat; double get geofenceLng; int get geofenceRadiusM; int get disperseMinutes; int get softPunishmentMinutes; int get hardPunishmentMinutes; int get compassUpdateIntervalMinutes; int get compassViewSeconds; int get voteTimeoutMinutes; int get frameCooldownMinutes;
/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GameSettingsCopyWith<GameSettings> get copyWith => _$GameSettingsCopyWithImpl<GameSettings>(this as GameSettings, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.geofenceLat, geofenceLat) || other.geofenceLat == geofenceLat)&&(identical(other.geofenceLng, geofenceLng) || other.geofenceLng == geofenceLng)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,mode,geofenceLat,geofenceLng,geofenceRadiusM,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes);

@override
String toString() {
  return 'GameSettings(mode: $mode, geofenceLat: $geofenceLat, geofenceLng: $geofenceLng, geofenceRadiusM: $geofenceRadiusM, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes)';
}


}

/// @nodoc
abstract mixin class $GameSettingsCopyWith<$Res>  {
  factory $GameSettingsCopyWith(GameSettings value, $Res Function(GameSettings) _then) = _$GameSettingsCopyWithImpl;
@useResult
$Res call({
 GameMode mode, double geofenceLat, double geofenceLng, int geofenceRadiusM, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes
});




}
/// @nodoc
class _$GameSettingsCopyWithImpl<$Res>
    implements $GameSettingsCopyWith<$Res> {
  _$GameSettingsCopyWithImpl(this._self, this._then);

  final GameSettings _self;
  final $Res Function(GameSettings) _then;

/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? geofenceLat = null,Object? geofenceLng = null,Object? geofenceRadiusM = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,geofenceLat: null == geofenceLat ? _self.geofenceLat : geofenceLat // ignore: cast_nullable_to_non_nullable
as double,geofenceLng: null == geofenceLng ? _self.geofenceLng : geofenceLng // ignore: cast_nullable_to_non_nullable
as double,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GameSettings].
extension GameSettingsPatterns on GameSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GameSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GameSettings value)  $default,){
final _that = this;
switch (_that) {
case _GameSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GameSettings value)?  $default,){
final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GameMode mode,  double geofenceLat,  double geofenceLng,  int geofenceRadiusM,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
return $default(_that.mode,_that.geofenceLat,_that.geofenceLng,_that.geofenceRadiusM,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GameMode mode,  double geofenceLat,  double geofenceLng,  int geofenceRadiusM,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes)  $default,) {final _that = this;
switch (_that) {
case _GameSettings():
return $default(_that.mode,_that.geofenceLat,_that.geofenceLng,_that.geofenceRadiusM,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GameMode mode,  double geofenceLat,  double geofenceLng,  int geofenceRadiusM,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes)?  $default,) {final _that = this;
switch (_that) {
case _GameSettings() when $default != null:
return $default(_that.mode,_that.geofenceLat,_that.geofenceLng,_that.geofenceRadiusM,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes);case _:
  return null;

}
}

}

/// @nodoc


class _GameSettings extends GameSettings {
  const _GameSettings({this.mode = GameMode.mostFrames, required this.geofenceLat, required this.geofenceLng, this.geofenceRadiusM = 200, this.disperseMinutes = 10, this.softPunishmentMinutes = 2, this.hardPunishmentMinutes = 5, this.compassUpdateIntervalMinutes = 10, this.compassViewSeconds = 30, this.voteTimeoutMinutes = 5, this.frameCooldownMinutes = 5}): super._();
  

@override@JsonKey() final  GameMode mode;
@override final  double geofenceLat;
@override final  double geofenceLng;
@override@JsonKey() final  int geofenceRadiusM;
@override@JsonKey() final  int disperseMinutes;
@override@JsonKey() final  int softPunishmentMinutes;
@override@JsonKey() final  int hardPunishmentMinutes;
@override@JsonKey() final  int compassUpdateIntervalMinutes;
@override@JsonKey() final  int compassViewSeconds;
@override@JsonKey() final  int voteTimeoutMinutes;
@override@JsonKey() final  int frameCooldownMinutes;

/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GameSettingsCopyWith<_GameSettings> get copyWith => __$GameSettingsCopyWithImpl<_GameSettings>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GameSettings&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.geofenceLat, geofenceLat) || other.geofenceLat == geofenceLat)&&(identical(other.geofenceLng, geofenceLng) || other.geofenceLng == geofenceLng)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,mode,geofenceLat,geofenceLng,geofenceRadiusM,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes);

@override
String toString() {
  return 'GameSettings(mode: $mode, geofenceLat: $geofenceLat, geofenceLng: $geofenceLng, geofenceRadiusM: $geofenceRadiusM, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes)';
}


}

/// @nodoc
abstract mixin class _$GameSettingsCopyWith<$Res> implements $GameSettingsCopyWith<$Res> {
  factory _$GameSettingsCopyWith(_GameSettings value, $Res Function(_GameSettings) _then) = __$GameSettingsCopyWithImpl;
@override @useResult
$Res call({
 GameMode mode, double geofenceLat, double geofenceLng, int geofenceRadiusM, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes
});




}
/// @nodoc
class __$GameSettingsCopyWithImpl<$Res>
    implements _$GameSettingsCopyWith<$Res> {
  __$GameSettingsCopyWithImpl(this._self, this._then);

  final _GameSettings _self;
  final $Res Function(_GameSettings) _then;

/// Create a copy of GameSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? geofenceLat = null,Object? geofenceLng = null,Object? geofenceRadiusM = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,}) {
  return _then(_GameSettings(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,geofenceLat: null == geofenceLat ? _self.geofenceLat : geofenceLat // ignore: cast_nullable_to_non_nullable
as double,geofenceLng: null == geofenceLng ? _self.geofenceLng : geofenceLng // ignore: cast_nullable_to_non_nullable
as double,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
