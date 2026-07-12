// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lobby_roster_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LobbyRosterEntry {

 String get playerId; String get nameCiphertext; bool get hasSelfie;
/// Create a copy of LobbyRosterEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LobbyRosterEntryCopyWith<LobbyRosterEntry> get copyWith => _$LobbyRosterEntryCopyWithImpl<LobbyRosterEntry>(this as LobbyRosterEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LobbyRosterEntry&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.nameCiphertext, nameCiphertext) || other.nameCiphertext == nameCiphertext)&&(identical(other.hasSelfie, hasSelfie) || other.hasSelfie == hasSelfie));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,nameCiphertext,hasSelfie);

@override
String toString() {
  return 'LobbyRosterEntry(playerId: $playerId, nameCiphertext: $nameCiphertext, hasSelfie: $hasSelfie)';
}


}

/// @nodoc
abstract mixin class $LobbyRosterEntryCopyWith<$Res>  {
  factory $LobbyRosterEntryCopyWith(LobbyRosterEntry value, $Res Function(LobbyRosterEntry) _then) = _$LobbyRosterEntryCopyWithImpl;
@useResult
$Res call({
 String playerId, String nameCiphertext, bool hasSelfie
});




}
/// @nodoc
class _$LobbyRosterEntryCopyWithImpl<$Res>
    implements $LobbyRosterEntryCopyWith<$Res> {
  _$LobbyRosterEntryCopyWithImpl(this._self, this._then);

  final LobbyRosterEntry _self;
  final $Res Function(LobbyRosterEntry) _then;

/// Create a copy of LobbyRosterEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? nameCiphertext = null,Object? hasSelfie = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,nameCiphertext: null == nameCiphertext ? _self.nameCiphertext : nameCiphertext // ignore: cast_nullable_to_non_nullable
as String,hasSelfie: null == hasSelfie ? _self.hasSelfie : hasSelfie // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LobbyRosterEntry].
extension LobbyRosterEntryPatterns on LobbyRosterEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LobbyRosterEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LobbyRosterEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LobbyRosterEntry value)  $default,){
final _that = this;
switch (_that) {
case _LobbyRosterEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LobbyRosterEntry value)?  $default,){
final _that = this;
switch (_that) {
case _LobbyRosterEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String nameCiphertext,  bool hasSelfie)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LobbyRosterEntry() when $default != null:
return $default(_that.playerId,_that.nameCiphertext,_that.hasSelfie);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String nameCiphertext,  bool hasSelfie)  $default,) {final _that = this;
switch (_that) {
case _LobbyRosterEntry():
return $default(_that.playerId,_that.nameCiphertext,_that.hasSelfie);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String nameCiphertext,  bool hasSelfie)?  $default,) {final _that = this;
switch (_that) {
case _LobbyRosterEntry() when $default != null:
return $default(_that.playerId,_that.nameCiphertext,_that.hasSelfie);case _:
  return null;

}
}

}

/// @nodoc


class _LobbyRosterEntry implements LobbyRosterEntry {
  const _LobbyRosterEntry({required this.playerId, required this.nameCiphertext, required this.hasSelfie});
  

@override final  String playerId;
@override final  String nameCiphertext;
@override final  bool hasSelfie;

/// Create a copy of LobbyRosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LobbyRosterEntryCopyWith<_LobbyRosterEntry> get copyWith => __$LobbyRosterEntryCopyWithImpl<_LobbyRosterEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LobbyRosterEntry&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.nameCiphertext, nameCiphertext) || other.nameCiphertext == nameCiphertext)&&(identical(other.hasSelfie, hasSelfie) || other.hasSelfie == hasSelfie));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,nameCiphertext,hasSelfie);

@override
String toString() {
  return 'LobbyRosterEntry(playerId: $playerId, nameCiphertext: $nameCiphertext, hasSelfie: $hasSelfie)';
}


}

/// @nodoc
abstract mixin class _$LobbyRosterEntryCopyWith<$Res> implements $LobbyRosterEntryCopyWith<$Res> {
  factory _$LobbyRosterEntryCopyWith(_LobbyRosterEntry value, $Res Function(_LobbyRosterEntry) _then) = __$LobbyRosterEntryCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String nameCiphertext, bool hasSelfie
});




}
/// @nodoc
class __$LobbyRosterEntryCopyWithImpl<$Res>
    implements _$LobbyRosterEntryCopyWith<$Res> {
  __$LobbyRosterEntryCopyWithImpl(this._self, this._then);

  final _LobbyRosterEntry _self;
  final $Res Function(_LobbyRosterEntry) _then;

/// Create a copy of LobbyRosterEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? nameCiphertext = null,Object? hasSelfie = null,}) {
  return _then(_LobbyRosterEntry(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,nameCiphertext: null == nameCiphertext ? _self.nameCiphertext : nameCiphertext // ignore: cast_nullable_to_non_nullable
as String,hasSelfie: null == hasSelfie ? _self.hasSelfie : hasSelfie // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
