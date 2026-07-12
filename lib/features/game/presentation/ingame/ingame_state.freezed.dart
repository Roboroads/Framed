// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingame_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$IngameState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngameState()';
}


}

/// @nodoc
class $IngameStateCopyWith<$Res>  {
$IngameStateCopyWith(IngameState _, $Res Function(IngameState) __);
}


/// Adds pattern-matching-related methods to [IngameState].
extension IngameStatePatterns on IngameState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( IngameDispersing value)?  dispersing,TResult Function( IngamePlaying value)?  playing,TResult Function( IngameTargetLoadFailed value)?  targetLoadFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case IngameDispersing() when dispersing != null:
return dispersing(_that);case IngamePlaying() when playing != null:
return playing(_that);case IngameTargetLoadFailed() when targetLoadFailed != null:
return targetLoadFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( IngameDispersing value)  dispersing,required TResult Function( IngamePlaying value)  playing,required TResult Function( IngameTargetLoadFailed value)  targetLoadFailed,}){
final _that = this;
switch (_that) {
case IngameDispersing():
return dispersing(_that);case IngamePlaying():
return playing(_that);case IngameTargetLoadFailed():
return targetLoadFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( IngameDispersing value)?  dispersing,TResult? Function( IngamePlaying value)?  playing,TResult? Function( IngameTargetLoadFailed value)?  targetLoadFailed,}){
final _that = this;
switch (_that) {
case IngameDispersing() when dispersing != null:
return dispersing(_that);case IngamePlaying() when playing != null:
return playing(_that);case IngameTargetLoadFailed() when targetLoadFailed != null:
return targetLoadFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( DateTime endsAt)?  dispersing,TResult Function( Target target)?  playing,TResult Function()?  targetLoadFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case IngameDispersing() when dispersing != null:
return dispersing(_that.endsAt);case IngamePlaying() when playing != null:
return playing(_that.target);case IngameTargetLoadFailed() when targetLoadFailed != null:
return targetLoadFailed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( DateTime endsAt)  dispersing,required TResult Function( Target target)  playing,required TResult Function()  targetLoadFailed,}) {final _that = this;
switch (_that) {
case IngameDispersing():
return dispersing(_that.endsAt);case IngamePlaying():
return playing(_that.target);case IngameTargetLoadFailed():
return targetLoadFailed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( DateTime endsAt)?  dispersing,TResult? Function( Target target)?  playing,TResult? Function()?  targetLoadFailed,}) {final _that = this;
switch (_that) {
case IngameDispersing() when dispersing != null:
return dispersing(_that.endsAt);case IngamePlaying() when playing != null:
return playing(_that.target);case IngameTargetLoadFailed() when targetLoadFailed != null:
return targetLoadFailed();case _:
  return null;

}
}

}

/// @nodoc


class IngameDispersing implements IngameState {
  const IngameDispersing({required this.endsAt});
  

 final  DateTime endsAt;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngameDispersingCopyWith<IngameDispersing> get copyWith => _$IngameDispersingCopyWithImpl<IngameDispersing>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameDispersing&&(identical(other.endsAt, endsAt) || other.endsAt == endsAt));
}


@override
int get hashCode => Object.hash(runtimeType,endsAt);

@override
String toString() {
  return 'IngameState.dispersing(endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $IngameDispersingCopyWith<$Res> implements $IngameStateCopyWith<$Res> {
  factory $IngameDispersingCopyWith(IngameDispersing value, $Res Function(IngameDispersing) _then) = _$IngameDispersingCopyWithImpl;
@useResult
$Res call({
 DateTime endsAt
});




}
/// @nodoc
class _$IngameDispersingCopyWithImpl<$Res>
    implements $IngameDispersingCopyWith<$Res> {
  _$IngameDispersingCopyWithImpl(this._self, this._then);

  final IngameDispersing _self;
  final $Res Function(IngameDispersing) _then;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? endsAt = null,}) {
  return _then(IngameDispersing(
endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class IngamePlaying implements IngameState {
  const IngamePlaying({required this.target});
  

 final  Target target;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngamePlayingCopyWith<IngamePlaying> get copyWith => _$IngamePlayingCopyWithImpl<IngamePlaying>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngamePlaying&&(identical(other.target, target) || other.target == target));
}


@override
int get hashCode => Object.hash(runtimeType,target);

@override
String toString() {
  return 'IngameState.playing(target: $target)';
}


}

/// @nodoc
abstract mixin class $IngamePlayingCopyWith<$Res> implements $IngameStateCopyWith<$Res> {
  factory $IngamePlayingCopyWith(IngamePlaying value, $Res Function(IngamePlaying) _then) = _$IngamePlayingCopyWithImpl;
@useResult
$Res call({
 Target target
});


$TargetCopyWith<$Res> get target;

}
/// @nodoc
class _$IngamePlayingCopyWithImpl<$Res>
    implements $IngamePlayingCopyWith<$Res> {
  _$IngamePlayingCopyWithImpl(this._self, this._then);

  final IngamePlaying _self;
  final $Res Function(IngamePlaying) _then;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = null,}) {
  return _then(IngamePlaying(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Target,
  ));
}

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetCopyWith<$Res> get target {
  
  return $TargetCopyWith<$Res>(_self.target, (value) {
    return _then(_self.copyWith(target: value));
  });
}
}

/// @nodoc


class IngameTargetLoadFailed implements IngameState {
  const IngameTargetLoadFailed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameTargetLoadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngameState.targetLoadFailed()';
}


}




// dart format on
