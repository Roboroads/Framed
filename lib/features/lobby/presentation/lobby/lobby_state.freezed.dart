// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LobbyPlayer {

 String get id; String get name; bool get hasSelfie;
/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyPlayerCopyWith<LobbyPlayer> get copyWith => _$LobbyPlayerCopyWithImpl<LobbyPlayer>(this as LobbyPlayer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyPlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hasSelfie, hasSelfie) || other.hasSelfie == hasSelfie));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,hasSelfie);

@override
String toString() {
  return 'LobbyPlayer(id: $id, name: $name, hasSelfie: $hasSelfie)';
}


}

/// @nodoc
abstract mixin class $LobbyPlayerCopyWith<$Res>  {
  factory $LobbyPlayerCopyWith(LobbyPlayer value, $Res Function(LobbyPlayer) _then) = _$LobbyPlayerCopyWithImpl;
@useResult
$Res call({
 String id, String name, bool hasSelfie
});




}
/// @nodoc
class _$LobbyPlayerCopyWithImpl<$Res>
    implements $LobbyPlayerCopyWith<$Res> {
  _$LobbyPlayerCopyWithImpl(this._self, this._then);

  final LobbyPlayer _self;
  final $Res Function(LobbyPlayer) _then;

/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? hasSelfie = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hasSelfie: null == hasSelfie ? _self.hasSelfie : hasSelfie // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbyPlayer].
extension LobbyPlayerPatterns on LobbyPlayer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbyPlayer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbyPlayer value)  $default,){
final _that = this;
switch (_that) {
case _LobbyPlayer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbyPlayer value)?  $default,){
final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  bool hasSelfie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
return $default(_that.id,_that.name,_that.hasSelfie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  bool hasSelfie)  $default,) {final _that = this;
switch (_that) {
case _LobbyPlayer():
return $default(_that.id,_that.name,_that.hasSelfie);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  bool hasSelfie)?  $default,) {final _that = this;
switch (_that) {
case _LobbyPlayer() when $default != null:
return $default(_that.id,_that.name,_that.hasSelfie);case _:
  return null;

}
}

}

/// @nodoc


class _LobbyPlayer implements LobbyPlayer {
  const _LobbyPlayer({required this.id, required this.name, required this.hasSelfie});
  

@override final  String id;
@override final  String name;
@override final  bool hasSelfie;

/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyPlayerCopyWith<_LobbyPlayer> get copyWith => __$LobbyPlayerCopyWithImpl<_LobbyPlayer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyPlayer&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hasSelfie, hasSelfie) || other.hasSelfie == hasSelfie));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,hasSelfie);

@override
String toString() {
  return 'LobbyPlayer(id: $id, name: $name, hasSelfie: $hasSelfie)';
}


}

/// @nodoc
abstract mixin class _$LobbyPlayerCopyWith<$Res> implements $LobbyPlayerCopyWith<$Res> {
  factory _$LobbyPlayerCopyWith(_LobbyPlayer value, $Res Function(_LobbyPlayer) _then) = __$LobbyPlayerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, bool hasSelfie
});




}
/// @nodoc
class __$LobbyPlayerCopyWithImpl<$Res>
    implements _$LobbyPlayerCopyWith<$Res> {
  __$LobbyPlayerCopyWithImpl(this._self, this._then);

  final _LobbyPlayer _self;
  final $Res Function(_LobbyPlayer) _then;

/// Create a copy of LobbyPlayer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? hasSelfie = null,}) {
  return _then(_LobbyPlayer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hasSelfie: null == hasSelfie ? _self.hasSelfie : hasSelfie // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$LobbyState {

 LobbyPhase get phase; List<LobbyPlayer> get roster; String? get hostPlayerId; String? get joinToken; GameMode get mode; int get disperseMinutes; int get softPunishmentMinutes; int get hardPunishmentMinutes; int get compassUpdateIntervalMinutes; int get compassViewSeconds; int get voteTimeoutMinutes; int get frameCooldownMinutes; int get geofenceRadiusM; bool get starting; LobbyError? get error; DateTime? get dispersalEndsAt;
/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyStateCopyWith<LobbyState> get copyWith => _$LobbyStateCopyWithImpl<LobbyState>(this as LobbyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyState&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other.roster, roster)&&(identical(other.hostPlayerId, hostPlayerId) || other.hostPlayerId == hostPlayerId)&&(identical(other.joinToken, joinToken) || other.joinToken == joinToken)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.starting, starting) || other.starting == starting)&&(identical(other.error, error) || other.error == error)&&(identical(other.dispersalEndsAt, dispersalEndsAt) || other.dispersalEndsAt == dispersalEndsAt));
}


@override
int get hashCode => Object.hash(runtimeType,phase,const DeepCollectionEquality().hash(roster),hostPlayerId,joinToken,mode,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes,geofenceRadiusM,starting,error,dispersalEndsAt);

@override
String toString() {
  return 'LobbyState(phase: $phase, roster: $roster, hostPlayerId: $hostPlayerId, joinToken: $joinToken, mode: $mode, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes, geofenceRadiusM: $geofenceRadiusM, starting: $starting, error: $error, dispersalEndsAt: $dispersalEndsAt)';
}


}

/// @nodoc
abstract mixin class $LobbyStateCopyWith<$Res>  {
  factory $LobbyStateCopyWith(LobbyState value, $Res Function(LobbyState) _then) = _$LobbyStateCopyWithImpl;
@useResult
$Res call({
 LobbyPhase phase, List<LobbyPlayer> roster, String? hostPlayerId, String? joinToken, GameMode mode, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes, int geofenceRadiusM, bool starting, LobbyError? error, DateTime? dispersalEndsAt
});




}
/// @nodoc
class _$LobbyStateCopyWithImpl<$Res>
    implements $LobbyStateCopyWith<$Res> {
  _$LobbyStateCopyWithImpl(this._self, this._then);

  final LobbyState _self;
  final $Res Function(LobbyState) _then;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? roster = null,Object? hostPlayerId = freezed,Object? joinToken = freezed,Object? mode = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,Object? geofenceRadiusM = null,Object? starting = null,Object? error = freezed,Object? dispersalEndsAt = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LobbyPhase,roster: null == roster ? _self.roster : roster // ignore: cast_nullable_to_non_nullable
as List<LobbyPlayer>,hostPlayerId: freezed == hostPlayerId ? _self.hostPlayerId : hostPlayerId // ignore: cast_nullable_to_non_nullable
as String?,joinToken: freezed == joinToken ? _self.joinToken : joinToken // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,starting: null == starting ? _self.starting : starting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LobbyError?,dispersalEndsAt: freezed == dispersalEndsAt ? _self.dispersalEndsAt : dispersalEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbyState].
extension LobbyStatePatterns on LobbyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbyState value)  $default,){
final _that = this;
switch (_that) {
case _LobbyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbyState value)?  $default,){
final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( LobbyPhase phase,  List<LobbyPlayer> roster,  String? hostPlayerId,  String? joinToken,  GameMode mode,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  int geofenceRadiusM,  bool starting,  LobbyError? error,  DateTime? dispersalEndsAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
return $default(_that.phase,_that.roster,_that.hostPlayerId,_that.joinToken,_that.mode,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.geofenceRadiusM,_that.starting,_that.error,_that.dispersalEndsAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( LobbyPhase phase,  List<LobbyPlayer> roster,  String? hostPlayerId,  String? joinToken,  GameMode mode,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  int geofenceRadiusM,  bool starting,  LobbyError? error,  DateTime? dispersalEndsAt)  $default,) {final _that = this;
switch (_that) {
case _LobbyState():
return $default(_that.phase,_that.roster,_that.hostPlayerId,_that.joinToken,_that.mode,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.geofenceRadiusM,_that.starting,_that.error,_that.dispersalEndsAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( LobbyPhase phase,  List<LobbyPlayer> roster,  String? hostPlayerId,  String? joinToken,  GameMode mode,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  int geofenceRadiusM,  bool starting,  LobbyError? error,  DateTime? dispersalEndsAt)?  $default,) {final _that = this;
switch (_that) {
case _LobbyState() when $default != null:
return $default(_that.phase,_that.roster,_that.hostPlayerId,_that.joinToken,_that.mode,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.geofenceRadiusM,_that.starting,_that.error,_that.dispersalEndsAt);case _:
  return null;

}
}

}

/// @nodoc


class _LobbyState extends LobbyState {
  const _LobbyState({this.phase = LobbyPhase.loading, final  List<LobbyPlayer> roster = const <LobbyPlayer>[], this.hostPlayerId, this.joinToken, this.mode = GameMode.mostFrames, this.disperseMinutes = 10, this.softPunishmentMinutes = 2, this.hardPunishmentMinutes = 5, this.compassUpdateIntervalMinutes = 10, this.compassViewSeconds = 30, this.voteTimeoutMinutes = 5, this.frameCooldownMinutes = 5, this.geofenceRadiusM = 200, this.starting = false, this.error, this.dispersalEndsAt}): _roster = roster,super._();
  

@override@JsonKey() final  LobbyPhase phase;
 final  List<LobbyPlayer> _roster;
@override@JsonKey() List<LobbyPlayer> get roster {
  if (_roster is EqualUnmodifiableListView) return _roster;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roster);
}

@override final  String? hostPlayerId;
@override final  String? joinToken;
@override@JsonKey() final  GameMode mode;
@override@JsonKey() final  int disperseMinutes;
@override@JsonKey() final  int softPunishmentMinutes;
@override@JsonKey() final  int hardPunishmentMinutes;
@override@JsonKey() final  int compassUpdateIntervalMinutes;
@override@JsonKey() final  int compassViewSeconds;
@override@JsonKey() final  int voteTimeoutMinutes;
@override@JsonKey() final  int frameCooldownMinutes;
@override@JsonKey() final  int geofenceRadiusM;
@override@JsonKey() final  bool starting;
@override final  LobbyError? error;
@override final  DateTime? dispersalEndsAt;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyStateCopyWith<_LobbyState> get copyWith => __$LobbyStateCopyWithImpl<_LobbyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyState&&(identical(other.phase, phase) || other.phase == phase)&&const DeepCollectionEquality().equals(other._roster, _roster)&&(identical(other.hostPlayerId, hostPlayerId) || other.hostPlayerId == hostPlayerId)&&(identical(other.joinToken, joinToken) || other.joinToken == joinToken)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.starting, starting) || other.starting == starting)&&(identical(other.error, error) || other.error == error)&&(identical(other.dispersalEndsAt, dispersalEndsAt) || other.dispersalEndsAt == dispersalEndsAt));
}


@override
int get hashCode => Object.hash(runtimeType,phase,const DeepCollectionEquality().hash(_roster),hostPlayerId,joinToken,mode,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes,geofenceRadiusM,starting,error,dispersalEndsAt);

@override
String toString() {
  return 'LobbyState(phase: $phase, roster: $roster, hostPlayerId: $hostPlayerId, joinToken: $joinToken, mode: $mode, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes, geofenceRadiusM: $geofenceRadiusM, starting: $starting, error: $error, dispersalEndsAt: $dispersalEndsAt)';
}


}

/// @nodoc
abstract mixin class _$LobbyStateCopyWith<$Res> implements $LobbyStateCopyWith<$Res> {
  factory _$LobbyStateCopyWith(_LobbyState value, $Res Function(_LobbyState) _then) = __$LobbyStateCopyWithImpl;
@override @useResult
$Res call({
 LobbyPhase phase, List<LobbyPlayer> roster, String? hostPlayerId, String? joinToken, GameMode mode, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes, int geofenceRadiusM, bool starting, LobbyError? error, DateTime? dispersalEndsAt
});




}
/// @nodoc
class __$LobbyStateCopyWithImpl<$Res>
    implements _$LobbyStateCopyWith<$Res> {
  __$LobbyStateCopyWithImpl(this._self, this._then);

  final _LobbyState _self;
  final $Res Function(_LobbyState) _then;

/// Create a copy of LobbyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? roster = null,Object? hostPlayerId = freezed,Object? joinToken = freezed,Object? mode = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,Object? geofenceRadiusM = null,Object? starting = null,Object? error = freezed,Object? dispersalEndsAt = freezed,}) {
  return _then(_LobbyState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as LobbyPhase,roster: null == roster ? _self._roster : roster // ignore: cast_nullable_to_non_nullable
as List<LobbyPlayer>,hostPlayerId: freezed == hostPlayerId ? _self.hostPlayerId : hostPlayerId // ignore: cast_nullable_to_non_nullable
as String?,joinToken: freezed == joinToken ? _self.joinToken : joinToken // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,starting: null == starting ? _self.starting : starting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LobbyError?,dispersalEndsAt: freezed == dispersalEndsAt ? _self.dispersalEndsAt : dispersalEndsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
