// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LobbySnapshot {

 String get hostPlayerId; String? get joinToken; GameMode get mode; int get disperseMinutes; int get softPunishmentMinutes; int get hardPunishmentMinutes; int get compassUpdateIntervalMinutes; int get compassViewSeconds; int get voteTimeoutMinutes; int get frameCooldownMinutes; int get geofenceRadiusM; List<LobbyRosterEntry> get roster;
/// Create a copy of LobbySnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbySnapshotCopyWith<LobbySnapshot> get copyWith => _$LobbySnapshotCopyWithImpl<LobbySnapshot>(this as LobbySnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbySnapshot&&(identical(other.hostPlayerId, hostPlayerId) || other.hostPlayerId == hostPlayerId)&&(identical(other.joinToken, joinToken) || other.joinToken == joinToken)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&const DeepCollectionEquality().equals(other.roster, roster));
}


@override
int get hashCode => Object.hash(runtimeType,hostPlayerId,joinToken,mode,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes,geofenceRadiusM,const DeepCollectionEquality().hash(roster));

@override
String toString() {
  return 'LobbySnapshot(hostPlayerId: $hostPlayerId, joinToken: $joinToken, mode: $mode, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes, geofenceRadiusM: $geofenceRadiusM, roster: $roster)';
}


}

/// @nodoc
abstract mixin class $LobbySnapshotCopyWith<$Res>  {
  factory $LobbySnapshotCopyWith(LobbySnapshot value, $Res Function(LobbySnapshot) _then) = _$LobbySnapshotCopyWithImpl;
@useResult
$Res call({
 String hostPlayerId, String? joinToken, GameMode mode, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes, int geofenceRadiusM, List<LobbyRosterEntry> roster
});




}
/// @nodoc
class _$LobbySnapshotCopyWithImpl<$Res>
    implements $LobbySnapshotCopyWith<$Res> {
  _$LobbySnapshotCopyWithImpl(this._self, this._then);

  final LobbySnapshot _self;
  final $Res Function(LobbySnapshot) _then;

/// Create a copy of LobbySnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hostPlayerId = null,Object? joinToken = freezed,Object? mode = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,Object? geofenceRadiusM = null,Object? roster = null,}) {
  return _then(_self.copyWith(
hostPlayerId: null == hostPlayerId ? _self.hostPlayerId : hostPlayerId // ignore: cast_nullable_to_non_nullable
as String,joinToken: freezed == joinToken ? _self.joinToken : joinToken // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,roster: null == roster ? _self.roster : roster // ignore: cast_nullable_to_non_nullable
as List<LobbyRosterEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbySnapshot].
extension LobbySnapshotPatterns on LobbySnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbySnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbySnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbySnapshot value)  $default,){
final _that = this;
switch (_that) {
case _LobbySnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbySnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _LobbySnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String hostPlayerId,  String? joinToken,  GameMode mode,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  int geofenceRadiusM,  List<LobbyRosterEntry> roster)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbySnapshot() when $default != null:
return $default(_that.hostPlayerId,_that.joinToken,_that.mode,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.geofenceRadiusM,_that.roster);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String hostPlayerId,  String? joinToken,  GameMode mode,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  int geofenceRadiusM,  List<LobbyRosterEntry> roster)  $default,) {final _that = this;
switch (_that) {
case _LobbySnapshot():
return $default(_that.hostPlayerId,_that.joinToken,_that.mode,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.geofenceRadiusM,_that.roster);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String hostPlayerId,  String? joinToken,  GameMode mode,  int disperseMinutes,  int softPunishmentMinutes,  int hardPunishmentMinutes,  int compassUpdateIntervalMinutes,  int compassViewSeconds,  int voteTimeoutMinutes,  int frameCooldownMinutes,  int geofenceRadiusM,  List<LobbyRosterEntry> roster)?  $default,) {final _that = this;
switch (_that) {
case _LobbySnapshot() when $default != null:
return $default(_that.hostPlayerId,_that.joinToken,_that.mode,_that.disperseMinutes,_that.softPunishmentMinutes,_that.hardPunishmentMinutes,_that.compassUpdateIntervalMinutes,_that.compassViewSeconds,_that.voteTimeoutMinutes,_that.frameCooldownMinutes,_that.geofenceRadiusM,_that.roster);case _:
  return null;

}
}

}

/// @nodoc


class _LobbySnapshot implements LobbySnapshot {
  const _LobbySnapshot({required this.hostPlayerId, required this.joinToken, required this.mode, required this.disperseMinutes, required this.softPunishmentMinutes, required this.hardPunishmentMinutes, required this.compassUpdateIntervalMinutes, required this.compassViewSeconds, required this.voteTimeoutMinutes, required this.frameCooldownMinutes, required this.geofenceRadiusM, required final  List<LobbyRosterEntry> roster}): _roster = roster;
  

@override final  String hostPlayerId;
@override final  String? joinToken;
@override final  GameMode mode;
@override final  int disperseMinutes;
@override final  int softPunishmentMinutes;
@override final  int hardPunishmentMinutes;
@override final  int compassUpdateIntervalMinutes;
@override final  int compassViewSeconds;
@override final  int voteTimeoutMinutes;
@override final  int frameCooldownMinutes;
@override final  int geofenceRadiusM;
 final  List<LobbyRosterEntry> _roster;
@override List<LobbyRosterEntry> get roster {
  if (_roster is EqualUnmodifiableListView) return _roster;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roster);
}


/// Create a copy of LobbySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbySnapshotCopyWith<_LobbySnapshot> get copyWith => __$LobbySnapshotCopyWithImpl<_LobbySnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbySnapshot&&(identical(other.hostPlayerId, hostPlayerId) || other.hostPlayerId == hostPlayerId)&&(identical(other.joinToken, joinToken) || other.joinToken == joinToken)&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.disperseMinutes, disperseMinutes) || other.disperseMinutes == disperseMinutes)&&(identical(other.softPunishmentMinutes, softPunishmentMinutes) || other.softPunishmentMinutes == softPunishmentMinutes)&&(identical(other.hardPunishmentMinutes, hardPunishmentMinutes) || other.hardPunishmentMinutes == hardPunishmentMinutes)&&(identical(other.compassUpdateIntervalMinutes, compassUpdateIntervalMinutes) || other.compassUpdateIntervalMinutes == compassUpdateIntervalMinutes)&&(identical(other.compassViewSeconds, compassViewSeconds) || other.compassViewSeconds == compassViewSeconds)&&(identical(other.voteTimeoutMinutes, voteTimeoutMinutes) || other.voteTimeoutMinutes == voteTimeoutMinutes)&&(identical(other.frameCooldownMinutes, frameCooldownMinutes) || other.frameCooldownMinutes == frameCooldownMinutes)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&const DeepCollectionEquality().equals(other._roster, _roster));
}


@override
int get hashCode => Object.hash(runtimeType,hostPlayerId,joinToken,mode,disperseMinutes,softPunishmentMinutes,hardPunishmentMinutes,compassUpdateIntervalMinutes,compassViewSeconds,voteTimeoutMinutes,frameCooldownMinutes,geofenceRadiusM,const DeepCollectionEquality().hash(_roster));

@override
String toString() {
  return 'LobbySnapshot(hostPlayerId: $hostPlayerId, joinToken: $joinToken, mode: $mode, disperseMinutes: $disperseMinutes, softPunishmentMinutes: $softPunishmentMinutes, hardPunishmentMinutes: $hardPunishmentMinutes, compassUpdateIntervalMinutes: $compassUpdateIntervalMinutes, compassViewSeconds: $compassViewSeconds, voteTimeoutMinutes: $voteTimeoutMinutes, frameCooldownMinutes: $frameCooldownMinutes, geofenceRadiusM: $geofenceRadiusM, roster: $roster)';
}


}

/// @nodoc
abstract mixin class _$LobbySnapshotCopyWith<$Res> implements $LobbySnapshotCopyWith<$Res> {
  factory _$LobbySnapshotCopyWith(_LobbySnapshot value, $Res Function(_LobbySnapshot) _then) = __$LobbySnapshotCopyWithImpl;
@override @useResult
$Res call({
 String hostPlayerId, String? joinToken, GameMode mode, int disperseMinutes, int softPunishmentMinutes, int hardPunishmentMinutes, int compassUpdateIntervalMinutes, int compassViewSeconds, int voteTimeoutMinutes, int frameCooldownMinutes, int geofenceRadiusM, List<LobbyRosterEntry> roster
});




}
/// @nodoc
class __$LobbySnapshotCopyWithImpl<$Res>
    implements _$LobbySnapshotCopyWith<$Res> {
  __$LobbySnapshotCopyWithImpl(this._self, this._then);

  final _LobbySnapshot _self;
  final $Res Function(_LobbySnapshot) _then;

/// Create a copy of LobbySnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hostPlayerId = null,Object? joinToken = freezed,Object? mode = null,Object? disperseMinutes = null,Object? softPunishmentMinutes = null,Object? hardPunishmentMinutes = null,Object? compassUpdateIntervalMinutes = null,Object? compassViewSeconds = null,Object? voteTimeoutMinutes = null,Object? frameCooldownMinutes = null,Object? geofenceRadiusM = null,Object? roster = null,}) {
  return _then(_LobbySnapshot(
hostPlayerId: null == hostPlayerId ? _self.hostPlayerId : hostPlayerId // ignore: cast_nullable_to_non_nullable
as String,joinToken: freezed == joinToken ? _self.joinToken : joinToken // ignore: cast_nullable_to_non_nullable
as String?,mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as GameMode,disperseMinutes: null == disperseMinutes ? _self.disperseMinutes : disperseMinutes // ignore: cast_nullable_to_non_nullable
as int,softPunishmentMinutes: null == softPunishmentMinutes ? _self.softPunishmentMinutes : softPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,hardPunishmentMinutes: null == hardPunishmentMinutes ? _self.hardPunishmentMinutes : hardPunishmentMinutes // ignore: cast_nullable_to_non_nullable
as int,compassUpdateIntervalMinutes: null == compassUpdateIntervalMinutes ? _self.compassUpdateIntervalMinutes : compassUpdateIntervalMinutes // ignore: cast_nullable_to_non_nullable
as int,compassViewSeconds: null == compassViewSeconds ? _self.compassViewSeconds : compassViewSeconds // ignore: cast_nullable_to_non_nullable
as int,voteTimeoutMinutes: null == voteTimeoutMinutes ? _self.voteTimeoutMinutes : voteTimeoutMinutes // ignore: cast_nullable_to_non_nullable
as int,frameCooldownMinutes: null == frameCooldownMinutes ? _self.frameCooldownMinutes : frameCooldownMinutes // ignore: cast_nullable_to_non_nullable
as int,geofenceRadiusM: null == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as int,roster: null == roster ? _self._roster : roster // ignore: cast_nullable_to_non_nullable
as List<LobbyRosterEntry>,
  ));
}


}

// dart format on
