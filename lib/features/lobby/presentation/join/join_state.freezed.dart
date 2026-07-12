// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'join_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JoinState {

 JoinStatus get status; String get name; Uint8List? get selfieBytes; LobbyError? get error;
/// Create a copy of JoinState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinStateCopyWith<JoinState> get copyWith => _$JoinStateCopyWithImpl<JoinState>(this as JoinState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinState&&(identical(other.status, status) || other.status == status)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selfieBytes, selfieBytes)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,name,const DeepCollectionEquality().hash(selfieBytes),error);

@override
String toString() {
  return 'JoinState(status: $status, name: $name, selfieBytes: $selfieBytes, error: $error)';
}


}

/// @nodoc
abstract mixin class $JoinStateCopyWith<$Res>  {
  factory $JoinStateCopyWith(JoinState value, $Res Function(JoinState) _then) = _$JoinStateCopyWithImpl;
@useResult
$Res call({
 JoinStatus status, String name, Uint8List? selfieBytes, LobbyError? error
});




}
/// @nodoc
class _$JoinStateCopyWithImpl<$Res>
    implements $JoinStateCopyWith<$Res> {
  _$JoinStateCopyWithImpl(this._self, this._then);

  final JoinState _self;
  final $Res Function(JoinState) _then;

/// Create a copy of JoinState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? name = null,Object? selfieBytes = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JoinStatus,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selfieBytes: freezed == selfieBytes ? _self.selfieBytes : selfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LobbyError?,
  ));
}

}


/// Adds pattern-matching-related methods to [JoinState].
extension JoinStatePatterns on JoinState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinState value)  $default,){
final _that = this;
switch (_that) {
case _JoinState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinState value)?  $default,){
final _that = this;
switch (_that) {
case _JoinState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( JoinStatus status,  String name,  Uint8List? selfieBytes,  LobbyError? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinState() when $default != null:
return $default(_that.status,_that.name,_that.selfieBytes,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( JoinStatus status,  String name,  Uint8List? selfieBytes,  LobbyError? error)  $default,) {final _that = this;
switch (_that) {
case _JoinState():
return $default(_that.status,_that.name,_that.selfieBytes,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( JoinStatus status,  String name,  Uint8List? selfieBytes,  LobbyError? error)?  $default,) {final _that = this;
switch (_that) {
case _JoinState() when $default != null:
return $default(_that.status,_that.name,_that.selfieBytes,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _JoinState extends JoinState {
  const _JoinState({this.status = JoinStatus.editing, this.name = '', this.selfieBytes, this.error}): super._();
  

@override@JsonKey() final  JoinStatus status;
@override@JsonKey() final  String name;
@override final  Uint8List? selfieBytes;
@override final  LobbyError? error;

/// Create a copy of JoinState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinStateCopyWith<_JoinState> get copyWith => __$JoinStateCopyWithImpl<_JoinState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinState&&(identical(other.status, status) || other.status == status)&&(identical(other.name, name) || other.name == name)&&const DeepCollectionEquality().equals(other.selfieBytes, selfieBytes)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,name,const DeepCollectionEquality().hash(selfieBytes),error);

@override
String toString() {
  return 'JoinState(status: $status, name: $name, selfieBytes: $selfieBytes, error: $error)';
}


}

/// @nodoc
abstract mixin class _$JoinStateCopyWith<$Res> implements $JoinStateCopyWith<$Res> {
  factory _$JoinStateCopyWith(_JoinState value, $Res Function(_JoinState) _then) = __$JoinStateCopyWithImpl;
@override @useResult
$Res call({
 JoinStatus status, String name, Uint8List? selfieBytes, LobbyError? error
});




}
/// @nodoc
class __$JoinStateCopyWithImpl<$Res>
    implements _$JoinStateCopyWith<$Res> {
  __$JoinStateCopyWithImpl(this._self, this._then);

  final _JoinState _self;
  final $Res Function(_JoinState) _then;

/// Create a copy of JoinState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? name = null,Object? selfieBytes = freezed,Object? error = freezed,}) {
  return _then(_JoinState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as JoinStatus,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,selfieBytes: freezed == selfieBytes ? _self.selfieBytes : selfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as LobbyError?,
  ));
}


}

// dart format on
