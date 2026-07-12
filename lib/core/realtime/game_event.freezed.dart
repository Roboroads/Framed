// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GameEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GameEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'GameEvent()';
}


}

/// @nodoc
class $GameEventCopyWith<$Res>  {
$GameEventCopyWith(GameEvent _, $Res Function(GameEvent) __);
}


/// Adds pattern-matching-related methods to [GameEvent].
extension GameEventPatterns on GameEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PlayerJoined value)?  playerJoined,TResult Function( PlayerReady value)?  playerReady,TResult Function( PlayerLeft value)?  playerLeft,TResult Function( HostChanged value)?  hostChanged,TResult Function( SettingsChanged value)?  settingsChanged,TResult Function( DispersalStarted value)?  dispersalStarted,TResult Function( TargetAssigned value)?  targetAssigned,TResult Function( UnknownGameEvent value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that);case PlayerReady() when playerReady != null:
return playerReady(_that);case PlayerLeft() when playerLeft != null:
return playerLeft(_that);case HostChanged() when hostChanged != null:
return hostChanged(_that);case SettingsChanged() when settingsChanged != null:
return settingsChanged(_that);case DispersalStarted() when dispersalStarted != null:
return dispersalStarted(_that);case TargetAssigned() when targetAssigned != null:
return targetAssigned(_that);case UnknownGameEvent() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PlayerJoined value)  playerJoined,required TResult Function( PlayerReady value)  playerReady,required TResult Function( PlayerLeft value)  playerLeft,required TResult Function( HostChanged value)  hostChanged,required TResult Function( SettingsChanged value)  settingsChanged,required TResult Function( DispersalStarted value)  dispersalStarted,required TResult Function( TargetAssigned value)  targetAssigned,required TResult Function( UnknownGameEvent value)  unknown,}){
final _that = this;
switch (_that) {
case PlayerJoined():
return playerJoined(_that);case PlayerReady():
return playerReady(_that);case PlayerLeft():
return playerLeft(_that);case HostChanged():
return hostChanged(_that);case SettingsChanged():
return settingsChanged(_that);case DispersalStarted():
return dispersalStarted(_that);case TargetAssigned():
return targetAssigned(_that);case UnknownGameEvent():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PlayerJoined value)?  playerJoined,TResult? Function( PlayerReady value)?  playerReady,TResult? Function( PlayerLeft value)?  playerLeft,TResult? Function( HostChanged value)?  hostChanged,TResult? Function( SettingsChanged value)?  settingsChanged,TResult? Function( DispersalStarted value)?  dispersalStarted,TResult? Function( TargetAssigned value)?  targetAssigned,TResult? Function( UnknownGameEvent value)?  unknown,}){
final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that);case PlayerReady() when playerReady != null:
return playerReady(_that);case PlayerLeft() when playerLeft != null:
return playerLeft(_that);case HostChanged() when hostChanged != null:
return hostChanged(_that);case SettingsChanged() when settingsChanged != null:
return settingsChanged(_that);case DispersalStarted() when dispersalStarted != null:
return dispersalStarted(_that);case TargetAssigned() when targetAssigned != null:
return targetAssigned(_that);case UnknownGameEvent() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String playerId,  String nameCiphertext)?  playerJoined,TResult Function( String playerId)?  playerReady,TResult Function( String playerId)?  playerLeft,TResult Function( String playerId)?  hostChanged,TResult Function( Map<String, dynamic> settings)?  settingsChanged,TResult Function( DateTime endsAt)?  dispersalStarted,TResult Function( String targetId,  String nameCiphertext,  String selfiePath)?  targetAssigned,TResult Function( String event,  Map<String, dynamic> payload)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that.playerId,_that.nameCiphertext);case PlayerReady() when playerReady != null:
return playerReady(_that.playerId);case PlayerLeft() when playerLeft != null:
return playerLeft(_that.playerId);case HostChanged() when hostChanged != null:
return hostChanged(_that.playerId);case SettingsChanged() when settingsChanged != null:
return settingsChanged(_that.settings);case DispersalStarted() when dispersalStarted != null:
return dispersalStarted(_that.endsAt);case TargetAssigned() when targetAssigned != null:
return targetAssigned(_that.targetId,_that.nameCiphertext,_that.selfiePath);case UnknownGameEvent() when unknown != null:
return unknown(_that.event,_that.payload);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String playerId,  String nameCiphertext)  playerJoined,required TResult Function( String playerId)  playerReady,required TResult Function( String playerId)  playerLeft,required TResult Function( String playerId)  hostChanged,required TResult Function( Map<String, dynamic> settings)  settingsChanged,required TResult Function( DateTime endsAt)  dispersalStarted,required TResult Function( String targetId,  String nameCiphertext,  String selfiePath)  targetAssigned,required TResult Function( String event,  Map<String, dynamic> payload)  unknown,}) {final _that = this;
switch (_that) {
case PlayerJoined():
return playerJoined(_that.playerId,_that.nameCiphertext);case PlayerReady():
return playerReady(_that.playerId);case PlayerLeft():
return playerLeft(_that.playerId);case HostChanged():
return hostChanged(_that.playerId);case SettingsChanged():
return settingsChanged(_that.settings);case DispersalStarted():
return dispersalStarted(_that.endsAt);case TargetAssigned():
return targetAssigned(_that.targetId,_that.nameCiphertext,_that.selfiePath);case UnknownGameEvent():
return unknown(_that.event,_that.payload);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String playerId,  String nameCiphertext)?  playerJoined,TResult? Function( String playerId)?  playerReady,TResult? Function( String playerId)?  playerLeft,TResult? Function( String playerId)?  hostChanged,TResult? Function( Map<String, dynamic> settings)?  settingsChanged,TResult? Function( DateTime endsAt)?  dispersalStarted,TResult? Function( String targetId,  String nameCiphertext,  String selfiePath)?  targetAssigned,TResult? Function( String event,  Map<String, dynamic> payload)?  unknown,}) {final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that.playerId,_that.nameCiphertext);case PlayerReady() when playerReady != null:
return playerReady(_that.playerId);case PlayerLeft() when playerLeft != null:
return playerLeft(_that.playerId);case HostChanged() when hostChanged != null:
return hostChanged(_that.playerId);case SettingsChanged() when settingsChanged != null:
return settingsChanged(_that.settings);case DispersalStarted() when dispersalStarted != null:
return dispersalStarted(_that.endsAt);case TargetAssigned() when targetAssigned != null:
return targetAssigned(_that.targetId,_that.nameCiphertext,_that.selfiePath);case UnknownGameEvent() when unknown != null:
return unknown(_that.event,_that.payload);case _:
  return null;

}
}

}

/// @nodoc


class PlayerJoined implements GameEvent {
  const PlayerJoined({required this.playerId, required this.nameCiphertext});
  

 final  String playerId;
 final  String nameCiphertext;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerJoinedCopyWith<PlayerJoined> get copyWith => _$PlayerJoinedCopyWithImpl<PlayerJoined>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerJoined&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.nameCiphertext, nameCiphertext) || other.nameCiphertext == nameCiphertext));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,nameCiphertext);

@override
String toString() {
  return 'GameEvent.playerJoined(playerId: $playerId, nameCiphertext: $nameCiphertext)';
}


}

/// @nodoc
abstract mixin class $PlayerJoinedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerJoinedCopyWith(PlayerJoined value, $Res Function(PlayerJoined) _then) = _$PlayerJoinedCopyWithImpl;
@useResult
$Res call({
 String playerId, String nameCiphertext
});




}
/// @nodoc
class _$PlayerJoinedCopyWithImpl<$Res>
    implements $PlayerJoinedCopyWith<$Res> {
  _$PlayerJoinedCopyWithImpl(this._self, this._then);

  final PlayerJoined _self;
  final $Res Function(PlayerJoined) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? nameCiphertext = null,}) {
  return _then(PlayerJoined(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,nameCiphertext: null == nameCiphertext ? _self.nameCiphertext : nameCiphertext // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PlayerReady implements GameEvent {
  const PlayerReady({required this.playerId});
  

 final  String playerId;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerReadyCopyWith<PlayerReady> get copyWith => _$PlayerReadyCopyWithImpl<PlayerReady>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerReady&&(identical(other.playerId, playerId) || other.playerId == playerId));
}


@override
int get hashCode => Object.hash(runtimeType,playerId);

@override
String toString() {
  return 'GameEvent.playerReady(playerId: $playerId)';
}


}

/// @nodoc
abstract mixin class $PlayerReadyCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerReadyCopyWith(PlayerReady value, $Res Function(PlayerReady) _then) = _$PlayerReadyCopyWithImpl;
@useResult
$Res call({
 String playerId
});




}
/// @nodoc
class _$PlayerReadyCopyWithImpl<$Res>
    implements $PlayerReadyCopyWith<$Res> {
  _$PlayerReadyCopyWithImpl(this._self, this._then);

  final PlayerReady _self;
  final $Res Function(PlayerReady) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playerId = null,}) {
  return _then(PlayerReady(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PlayerLeft implements GameEvent {
  const PlayerLeft({required this.playerId});
  

 final  String playerId;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlayerLeftCopyWith<PlayerLeft> get copyWith => _$PlayerLeftCopyWithImpl<PlayerLeft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlayerLeft&&(identical(other.playerId, playerId) || other.playerId == playerId));
}


@override
int get hashCode => Object.hash(runtimeType,playerId);

@override
String toString() {
  return 'GameEvent.playerLeft(playerId: $playerId)';
}


}

/// @nodoc
abstract mixin class $PlayerLeftCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $PlayerLeftCopyWith(PlayerLeft value, $Res Function(PlayerLeft) _then) = _$PlayerLeftCopyWithImpl;
@useResult
$Res call({
 String playerId
});




}
/// @nodoc
class _$PlayerLeftCopyWithImpl<$Res>
    implements $PlayerLeftCopyWith<$Res> {
  _$PlayerLeftCopyWithImpl(this._self, this._then);

  final PlayerLeft _self;
  final $Res Function(PlayerLeft) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playerId = null,}) {
  return _then(PlayerLeft(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class HostChanged implements GameEvent {
  const HostChanged({required this.playerId});
  

 final  String playerId;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HostChangedCopyWith<HostChanged> get copyWith => _$HostChangedCopyWithImpl<HostChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HostChanged&&(identical(other.playerId, playerId) || other.playerId == playerId));
}


@override
int get hashCode => Object.hash(runtimeType,playerId);

@override
String toString() {
  return 'GameEvent.hostChanged(playerId: $playerId)';
}


}

/// @nodoc
abstract mixin class $HostChangedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $HostChangedCopyWith(HostChanged value, $Res Function(HostChanged) _then) = _$HostChangedCopyWithImpl;
@useResult
$Res call({
 String playerId
});




}
/// @nodoc
class _$HostChangedCopyWithImpl<$Res>
    implements $HostChangedCopyWith<$Res> {
  _$HostChangedCopyWithImpl(this._self, this._then);

  final HostChanged _self;
  final $Res Function(HostChanged) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playerId = null,}) {
  return _then(HostChanged(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SettingsChanged implements GameEvent {
  const SettingsChanged({required final  Map<String, dynamic> settings}): _settings = settings;
  

 final  Map<String, dynamic> _settings;
 Map<String, dynamic> get settings {
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_settings);
}


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SettingsChangedCopyWith<SettingsChanged> get copyWith => _$SettingsChangedCopyWithImpl<SettingsChanged>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SettingsChanged&&const DeepCollectionEquality().equals(other._settings, _settings));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'GameEvent.settingsChanged(settings: $settings)';
}


}

/// @nodoc
abstract mixin class $SettingsChangedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $SettingsChangedCopyWith(SettingsChanged value, $Res Function(SettingsChanged) _then) = _$SettingsChangedCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> settings
});




}
/// @nodoc
class _$SettingsChangedCopyWithImpl<$Res>
    implements $SettingsChangedCopyWith<$Res> {
  _$SettingsChangedCopyWithImpl(this._self, this._then);

  final SettingsChanged _self;
  final $Res Function(SettingsChanged) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? settings = null,}) {
  return _then(SettingsChanged(
settings: null == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class DispersalStarted implements GameEvent {
  const DispersalStarted({required this.endsAt});
  

 final  DateTime endsAt;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DispersalStartedCopyWith<DispersalStarted> get copyWith => _$DispersalStartedCopyWithImpl<DispersalStarted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DispersalStarted&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}


@override
int get hashCode => Object.hash(runtimeType,endsAt);

@override
String toString() {
  return 'GameEvent.dispersalStarted(endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $DispersalStartedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $DispersalStartedCopyWith(DispersalStarted value, $Res Function(DispersalStarted) _then) = _$DispersalStartedCopyWithImpl;
@useResult
$Res call({
 DateTime endsAt
});




}
/// @nodoc
class _$DispersalStartedCopyWithImpl<$Res>
    implements $DispersalStartedCopyWith<$Res> {
  _$DispersalStartedCopyWithImpl(this._self, this._then);

  final DispersalStarted _self;
  final $Res Function(DispersalStarted) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? endsAt = null,}) {
  return _then(DispersalStarted(
endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class TargetAssigned implements GameEvent {
  const TargetAssigned({required this.targetId, required this.nameCiphertext, required this.selfiePath});
  

 final  String targetId;
 final  String nameCiphertext;
 final  String selfiePath;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetAssignedCopyWith<TargetAssigned> get copyWith => _$TargetAssignedCopyWithImpl<TargetAssigned>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetAssigned&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.nameCiphertext, nameCiphertext) || other.nameCiphertext == nameCiphertext)&&(identical(other.selfiePath, selfiePath) || other.selfiePath == selfiePath));
}


@override
int get hashCode => Object.hash(runtimeType,targetId,nameCiphertext,selfiePath);

@override
String toString() {
  return 'GameEvent.targetAssigned(targetId: $targetId, nameCiphertext: $nameCiphertext, selfiePath: $selfiePath)';
}


}

/// @nodoc
abstract mixin class $TargetAssignedCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $TargetAssignedCopyWith(TargetAssigned value, $Res Function(TargetAssigned) _then) = _$TargetAssignedCopyWithImpl;
@useResult
$Res call({
 String targetId, String nameCiphertext, String selfiePath
});




}
/// @nodoc
class _$TargetAssignedCopyWithImpl<$Res>
    implements $TargetAssignedCopyWith<$Res> {
  _$TargetAssignedCopyWithImpl(this._self, this._then);

  final TargetAssigned _self;
  final $Res Function(TargetAssigned) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? targetId = null,Object? nameCiphertext = null,Object? selfiePath = null,}) {
  return _then(TargetAssigned(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,nameCiphertext: null == nameCiphertext ? _self.nameCiphertext : nameCiphertext // ignore: cast_nullable_to_non_nullable
as String,selfiePath: null == selfiePath ? _self.selfiePath : selfiePath // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownGameEvent implements GameEvent {
  const UnknownGameEvent({required this.event, required final  Map<String, dynamic> payload}): _payload = payload;
  

 final  String event;
 final  Map<String, dynamic> _payload;
 Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}


/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownGameEventCopyWith<UnknownGameEvent> get copyWith => _$UnknownGameEventCopyWithImpl<UnknownGameEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownGameEvent&&(identical(other.event, event) || other.event == event)&&const DeepCollectionEquality().equals(other._payload, _payload));
}


@override
int get hashCode => Object.hash(runtimeType,event,const DeepCollectionEquality().hash(_payload));

@override
String toString() {
  return 'GameEvent.unknown(event: $event, payload: $payload)';
}


}

/// @nodoc
abstract mixin class $UnknownGameEventCopyWith<$Res> implements $GameEventCopyWith<$Res> {
  factory $UnknownGameEventCopyWith(UnknownGameEvent value, $Res Function(UnknownGameEvent) _then) = _$UnknownGameEventCopyWithImpl;
@useResult
$Res call({
 String event, Map<String, dynamic> payload
});




}
/// @nodoc
class _$UnknownGameEventCopyWithImpl<$Res>
    implements $UnknownGameEventCopyWith<$Res> {
  _$UnknownGameEventCopyWithImpl(this._self, this._then);

  final UnknownGameEvent _self;
  final $Res Function(UnknownGameEvent) _then;

/// Create a copy of GameEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? event = null,Object? payload = null,}) {
  return _then(UnknownGameEvent(
event: null == event ? _self.event : event // ignore: cast_nullable_to_non_nullable
as String,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
