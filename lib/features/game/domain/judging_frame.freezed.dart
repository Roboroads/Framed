// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'judging_frame.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$JudgingFrame {

 String get frameId; Uint8List get photoBytes; String get targetName; Uint8List get targetSelfieBytes;
/// Create a copy of JudgingFrame
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JudgingFrameCopyWith<JudgingFrame> get copyWith => _$JudgingFrameCopyWithImpl<JudgingFrame>(this as JudgingFrame, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JudgingFrame&&(identical(other.frameId, frameId) || other.frameId == frameId)&&const DeepCollectionEquality().equals(other.photoBytes, photoBytes)&&(identical(other.targetName, targetName) || other.targetName == targetName)&&const DeepCollectionEquality().equals(other.targetSelfieBytes, targetSelfieBytes));
}


@override
int get hashCode => Object.hash(runtimeType,frameId,const DeepCollectionEquality().hash(photoBytes),targetName,const DeepCollectionEquality().hash(targetSelfieBytes));

@override
String toString() {
  return 'JudgingFrame(frameId: $frameId, photoBytes: $photoBytes, targetName: $targetName, targetSelfieBytes: $targetSelfieBytes)';
}


}

/// @nodoc
abstract mixin class $JudgingFrameCopyWith<$Res>  {
  factory $JudgingFrameCopyWith(JudgingFrame value, $Res Function(JudgingFrame) _then) = _$JudgingFrameCopyWithImpl;
@useResult
$Res call({
 String frameId, Uint8List photoBytes, String targetName, Uint8List targetSelfieBytes
});




}
/// @nodoc
class _$JudgingFrameCopyWithImpl<$Res>
    implements $JudgingFrameCopyWith<$Res> {
  _$JudgingFrameCopyWithImpl(this._self, this._then);

  final JudgingFrame _self;
  final $Res Function(JudgingFrame) _then;

/// Create a copy of JudgingFrame
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? frameId = null,Object? photoBytes = null,Object? targetName = null,Object? targetSelfieBytes = null,}) {
  return _then(_self.copyWith(
frameId: null == frameId ? _self.frameId : frameId // ignore: cast_nullable_to_non_nullable
as String,photoBytes: null == photoBytes ? _self.photoBytes : photoBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,targetName: null == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String,targetSelfieBytes: null == targetSelfieBytes ? _self.targetSelfieBytes : targetSelfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}

}


/// Adds pattern-matching-related methods to [JudgingFrame].
extension JudgingFramePatterns on JudgingFrame {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JudgingFrame value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JudgingFrame() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JudgingFrame value)  $default,){
final _that = this;
switch (_that) {
case _JudgingFrame():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JudgingFrame value)?  $default,){
final _that = this;
switch (_that) {
case _JudgingFrame() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String frameId,  Uint8List photoBytes,  String targetName,  Uint8List targetSelfieBytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JudgingFrame() when $default != null:
return $default(_that.frameId,_that.photoBytes,_that.targetName,_that.targetSelfieBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String frameId,  Uint8List photoBytes,  String targetName,  Uint8List targetSelfieBytes)  $default,) {final _that = this;
switch (_that) {
case _JudgingFrame():
return $default(_that.frameId,_that.photoBytes,_that.targetName,_that.targetSelfieBytes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String frameId,  Uint8List photoBytes,  String targetName,  Uint8List targetSelfieBytes)?  $default,) {final _that = this;
switch (_that) {
case _JudgingFrame() when $default != null:
return $default(_that.frameId,_that.photoBytes,_that.targetName,_that.targetSelfieBytes);case _:
  return null;

}
}

}

/// @nodoc


class _JudgingFrame implements JudgingFrame {
  const _JudgingFrame({required this.frameId, required this.photoBytes, required this.targetName, required this.targetSelfieBytes});
  

@override final  String frameId;
@override final  Uint8List photoBytes;
@override final  String targetName;
@override final  Uint8List targetSelfieBytes;

/// Create a copy of JudgingFrame
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JudgingFrameCopyWith<_JudgingFrame> get copyWith => __$JudgingFrameCopyWithImpl<_JudgingFrame>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JudgingFrame&&(identical(other.frameId, frameId) || other.frameId == frameId)&&const DeepCollectionEquality().equals(other.photoBytes, photoBytes)&&(identical(other.targetName, targetName) || other.targetName == targetName)&&const DeepCollectionEquality().equals(other.targetSelfieBytes, targetSelfieBytes));
}


@override
int get hashCode => Object.hash(runtimeType,frameId,const DeepCollectionEquality().hash(photoBytes),targetName,const DeepCollectionEquality().hash(targetSelfieBytes));

@override
String toString() {
  return 'JudgingFrame(frameId: $frameId, photoBytes: $photoBytes, targetName: $targetName, targetSelfieBytes: $targetSelfieBytes)';
}


}

/// @nodoc
abstract mixin class _$JudgingFrameCopyWith<$Res> implements $JudgingFrameCopyWith<$Res> {
  factory _$JudgingFrameCopyWith(_JudgingFrame value, $Res Function(_JudgingFrame) _then) = __$JudgingFrameCopyWithImpl;
@override @useResult
$Res call({
 String frameId, Uint8List photoBytes, String targetName, Uint8List targetSelfieBytes
});




}
/// @nodoc
class __$JudgingFrameCopyWithImpl<$Res>
    implements _$JudgingFrameCopyWith<$Res> {
  __$JudgingFrameCopyWithImpl(this._self, this._then);

  final _JudgingFrame _self;
  final $Res Function(_JudgingFrame) _then;

/// Create a copy of JudgingFrame
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? frameId = null,Object? photoBytes = null,Object? targetName = null,Object? targetSelfieBytes = null,}) {
  return _then(_JudgingFrame(
frameId: null == frameId ? _self.frameId : frameId // ignore: cast_nullable_to_non_nullable
as String,photoBytes: null == photoBytes ? _self.photoBytes : photoBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,targetName: null == targetName ? _self.targetName : targetName // ignore: cast_nullable_to_non_nullable
as String,targetSelfieBytes: null == targetSelfieBytes ? _self.targetSelfieBytes : targetSelfieBytes // ignore: cast_nullable_to_non_nullable
as Uint8List,
  ));
}


}

// dart format on
