// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Target {

 String get playerId; String get name; Uint8List get selfieBytes;
/// Create a copy of Target
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TargetCopyWith<Target> get copyWith => _$TargetCopyWithImpl<Target>(this as Target, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Target&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selfieBytes, selfieBytes));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,name,const DeepCollectionEquality().hash(selfieBytes));

@override
String toString() {
  return 'Target(playerId: $playerId, name: $name, selfieBytes: $selfieBytes)';
}


}

/// @nodoc
abstract mixin class $TargetCopyWith<$Res>  {
  factory $TargetCopyWith(Target value, $Res Function(Target) _then) = _$TargetCopyWithImpl;
@useResult
$Res call({
 String playerId, String name, Uint8List selfieBytes
});




}
/// @nodoc
class _$TargetCopyWithImpl<$Res>
    implements $TargetCopyWith<$Res> {
  _$TargetCopyWithImpl(this._self, this._then);

  final Target _self;
  final $Res Function(Target) _then;

/// Create a copy of Target
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playerId = null,Object? name = null,Object? selfieBytes = null,}) {
  return _then(_self.copyWith(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selfieBytes: null == selfieBytes ? _self.selfieBytes : selfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [Target].
extension TargetPatterns on Target {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Target value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Target() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Target value)  $default,){
final _that = this;
switch (_that) {
case _Target():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Target value)?  $default,){
final _that = this;
switch (_that) {
case _Target() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String playerId,  String name,  Uint8List selfieBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Target() when $default != null:
return $default(_that.playerId,_that.name,_that.selfieBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String playerId,  String name,  Uint8List selfieBytes)  $default,) {final _that = this;
switch (_that) {
case _Target():
return $default(_that.playerId,_that.name,_that.selfieBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String playerId,  String name,  Uint8List selfieBytes)?  $default,) {final _that = this;
switch (_that) {
case _Target() when $default != null:
return $default(_that.playerId,_that.name,_that.selfieBytes);case _:
  return null;

}
}

}

/// @nodoc


class _Target implements Target {
  const _Target({required this.playerId, required this.name, required this.selfieBytes});
  

@override final  String playerId;
@override final  String name;
@override final  Uint8List selfieBytes;

/// Create a copy of Target
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TargetCopyWith<_Target> get copyWith => __$TargetCopyWithImpl<_Target>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Target&&(identical(other.playerId, playerId) || other.playerId == playerId)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selfieBytes, selfieBytes));
}


@override
int get hashCode => Object.hash(runtimeType,playerId,name,const DeepCollectionEquality().hash(selfieBytes));

@override
String toString() {
  return 'Target(playerId: $playerId, name: $name, selfieBytes: $selfieBytes)';
}


}

/// @nodoc
abstract mixin class _$TargetCopyWith<$Res> implements $TargetCopyWith<$Res> {
  factory _$TargetCopyWith(_Target value, $Res Function(_Target) _then) = __$TargetCopyWithImpl;
@override @useResult
$Res call({
 String playerId, String name, Uint8List selfieBytes
});




}
/// @nodoc
class __$TargetCopyWithImpl<$Res>
    implements _$TargetCopyWith<$Res> {
  __$TargetCopyWithImpl(this._self, this._then);

  final _Target _self;
  final $Res Function(_Target) _then;

/// Create a copy of Target
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playerId = null,Object? name = null,Object? selfieBytes = null,}) {
  return _then(_Target(
playerId: null == playerId ? _self.playerId : playerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selfieBytes: null == selfieBytes ? _self.selfieBytes : selfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

// dart format on
