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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PlayerJoined value)?  playerJoined,TResult Function( UnknownGameEvent value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that);case UnknownGameEvent() when unknown != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PlayerJoined value)  playerJoined,required TResult Function( UnknownGameEvent value)  unknown,}){
final _that = this;
switch (_that) {
case PlayerJoined():
return playerJoined(_that);case UnknownGameEvent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PlayerJoined value)?  playerJoined,TResult? Function( UnknownGameEvent value)?  unknown,}){
final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that);case UnknownGameEvent() when unknown != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String playerId,  String nameCiphertext)?  playerJoined,TResult Function( String event,  Map<String, dynamic> payload)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that.playerId,_that.nameCiphertext);case UnknownGameEvent() when unknown != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String playerId,  String nameCiphertext)  playerJoined,required TResult Function( String event,  Map<String, dynamic> payload)  unknown,}) {final _that = this;
switch (_that) {
case PlayerJoined():
return playerJoined(_that.playerId,_that.nameCiphertext);case UnknownGameEvent():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String playerId,  String nameCiphertext)?  playerJoined,TResult? Function( String event,  Map<String, dynamic> payload)?  unknown,}) {final _that = this;
switch (_that) {
case PlayerJoined() when playerJoined != null:
return playerJoined(_that.playerId,_that.nameCiphertext);case UnknownGameEvent() when unknown != null:
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
