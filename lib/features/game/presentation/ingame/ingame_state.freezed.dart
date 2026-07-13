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
mixin _$IngamePhase {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngamePhase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngamePhase()';
}


}

/// @nodoc
class $IngamePhaseCopyWith<$Res>  {
$IngamePhaseCopyWith(IngamePhase _, $Res Function(IngamePhase) __);
}


/// Adds pattern-matching-related methods to [IngamePhase].
extension IngamePhasePatterns on IngamePhase {
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


class IngameDispersing implements IngamePhase {
  const IngameDispersing({required this.endsAt});
  

 final  DateTime endsAt;

/// Create a copy of IngamePhase
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
  return 'IngamePhase.dispersing(endsAt: $endsAt)';
}


}

/// @nodoc
abstract mixin class $IngameDispersingCopyWith<$Res> implements $IngamePhaseCopyWith<$Res> {
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

/// Create a copy of IngamePhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? endsAt = null,}) {
  return _then(IngameDispersing(
endsAt: null == endsAt ? _self.endsAt : endsAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc


class IngamePlaying implements IngamePhase {
  const IngamePlaying({required this.target});
  

 final  Target target;

/// Create a copy of IngamePhase
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
  return 'IngamePhase.playing(target: $target)';
}


}

/// @nodoc
abstract mixin class $IngamePlayingCopyWith<$Res> implements $IngamePhaseCopyWith<$Res> {
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

/// Create a copy of IngamePhase
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? target = null,}) {
  return _then(IngamePlaying(
target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as Target,
  ));
}

/// Create a copy of IngamePhase
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


class IngameTargetLoadFailed implements IngamePhase {
  const IngameTargetLoadFailed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameTargetLoadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngamePhase.targetLoadFailed()';
}


}




/// @nodoc
mixin _$IngameWarning {

 List<String> get reasons; DateTime get hardDeadline;
/// Create a copy of IngameWarning
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngameWarningCopyWith<IngameWarning> get copyWith => _$IngameWarningCopyWithImpl<IngameWarning>(this as IngameWarning, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameWarning&&const DeepCollectionEquality().equals(other.reasons, reasons)&&(identical(other.hardDeadline, hardDeadline) || other.hardDeadline == hardDeadline));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(reasons),hardDeadline);

@override
String toString() {
  return 'IngameWarning(reasons: $reasons, hardDeadline: $hardDeadline)';
}


}

/// @nodoc
abstract mixin class $IngameWarningCopyWith<$Res>  {
  factory $IngameWarningCopyWith(IngameWarning value, $Res Function(IngameWarning) _then) = _$IngameWarningCopyWithImpl;
@useResult
$Res call({
 List<String> reasons, DateTime hardDeadline
});




}
/// @nodoc
class _$IngameWarningCopyWithImpl<$Res>
    implements $IngameWarningCopyWith<$Res> {
  _$IngameWarningCopyWithImpl(this._self, this._then);

  final IngameWarning _self;
  final $Res Function(IngameWarning) _then;

/// Create a copy of IngameWarning
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reasons = null,Object? hardDeadline = null,}) {
  return _then(_self.copyWith(
reasons: null == reasons ? _self.reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,hardDeadline: null == hardDeadline ? _self.hardDeadline : hardDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [IngameWarning].
extension IngameWarningPatterns on IngameWarning {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngameWarning value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngameWarning() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngameWarning value)  $default,){
final _that = this;
switch (_that) {
case _IngameWarning():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngameWarning value)?  $default,){
final _that = this;
switch (_that) {
case _IngameWarning() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> reasons,  DateTime hardDeadline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngameWarning() when $default != null:
return $default(_that.reasons,_that.hardDeadline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> reasons,  DateTime hardDeadline)  $default,) {final _that = this;
switch (_that) {
case _IngameWarning():
return $default(_that.reasons,_that.hardDeadline);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> reasons,  DateTime hardDeadline)?  $default,) {final _that = this;
switch (_that) {
case _IngameWarning() when $default != null:
return $default(_that.reasons,_that.hardDeadline);case _:
  return null;

}
}

}

/// @nodoc


class _IngameWarning implements IngameWarning {
  const _IngameWarning({required final  List<String> reasons, required this.hardDeadline}): _reasons = reasons;
  

 final  List<String> _reasons;
@override List<String> get reasons {
  if (_reasons is EqualUnmodifiableListView) return _reasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reasons);
}

@override final  DateTime hardDeadline;

/// Create a copy of IngameWarning
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngameWarningCopyWith<_IngameWarning> get copyWith => __$IngameWarningCopyWithImpl<_IngameWarning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngameWarning&&const DeepCollectionEquality().equals(other._reasons, _reasons)&&(identical(other.hardDeadline, hardDeadline) || other.hardDeadline == hardDeadline));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_reasons),hardDeadline);

@override
String toString() {
  return 'IngameWarning(reasons: $reasons, hardDeadline: $hardDeadline)';
}


}

/// @nodoc
abstract mixin class _$IngameWarningCopyWith<$Res> implements $IngameWarningCopyWith<$Res> {
  factory _$IngameWarningCopyWith(_IngameWarning value, $Res Function(_IngameWarning) _then) = __$IngameWarningCopyWithImpl;
@override @useResult
$Res call({
 List<String> reasons, DateTime hardDeadline
});




}
/// @nodoc
class __$IngameWarningCopyWithImpl<$Res>
    implements _$IngameWarningCopyWith<$Res> {
  __$IngameWarningCopyWithImpl(this._self, this._then);

  final _IngameWarning _self;
  final $Res Function(_IngameWarning) _then;

/// Create a copy of IngameWarning
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reasons = null,Object? hardDeadline = null,}) {
  return _then(_IngameWarning(
reasons: null == reasons ? _self._reasons : reasons // ignore: cast_nullable_to_non_nullable
as List<String>,hardDeadline: null == hardDeadline ? _self.hardDeadline : hardDeadline // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$IngameState {

 IngamePhase get phase; IngameWarning? get warning;
/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngameStateCopyWith<IngameState> get copyWith => _$IngameStateCopyWithImpl<IngameState>(this as IngameState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.warning, warning) || other.warning == warning));
}


@override
int get hashCode => Object.hash(runtimeType,phase,warning);

@override
String toString() {
  return 'IngameState(phase: $phase, warning: $warning)';
}


}

/// @nodoc
abstract mixin class $IngameStateCopyWith<$Res>  {
  factory $IngameStateCopyWith(IngameState value, $Res Function(IngameState) _then) = _$IngameStateCopyWithImpl;
@useResult
$Res call({
 IngamePhase phase, IngameWarning? warning
});


$IngamePhaseCopyWith<$Res> get phase;$IngameWarningCopyWith<$Res>? get warning;

}
/// @nodoc
class _$IngameStateCopyWithImpl<$Res>
    implements $IngameStateCopyWith<$Res> {
  _$IngameStateCopyWithImpl(this._self, this._then);

  final IngameState _self;
  final $Res Function(IngameState) _then;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? warning = freezed,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as IngamePhase,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IngameWarning?,
  ));
}
/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngamePhaseCopyWith<$Res> get phase {
  
  return $IngamePhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameWarningCopyWith<$Res>? get warning {
    if (_self.warning == null) {
    return null;
  }

  return $IngameWarningCopyWith<$Res>(_self.warning!, (value) {
    return _then(_self.copyWith(warning: value));
  });
}
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngameState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngameState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngameState value)  $default,){
final _that = this;
switch (_that) {
case _IngameState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngameState value)?  $default,){
final _that = this;
switch (_that) {
case _IngameState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IngamePhase phase,  IngameWarning? warning)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngameState() when $default != null:
return $default(_that.phase,_that.warning);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IngamePhase phase,  IngameWarning? warning)  $default,) {final _that = this;
switch (_that) {
case _IngameState():
return $default(_that.phase,_that.warning);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IngamePhase phase,  IngameWarning? warning)?  $default,) {final _that = this;
switch (_that) {
case _IngameState() when $default != null:
return $default(_that.phase,_that.warning);case _:
  return null;

}
}

}

/// @nodoc


class _IngameState implements IngameState {
  const _IngameState({required this.phase, this.warning});
  

@override final  IngamePhase phase;
@override final  IngameWarning? warning;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngameStateCopyWith<_IngameState> get copyWith => __$IngameStateCopyWithImpl<_IngameState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngameState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.warning, warning) || other.warning == warning));
}


@override
int get hashCode => Object.hash(runtimeType,phase,warning);

@override
String toString() {
  return 'IngameState(phase: $phase, warning: $warning)';
}


}

/// @nodoc
abstract mixin class _$IngameStateCopyWith<$Res> implements $IngameStateCopyWith<$Res> {
  factory _$IngameStateCopyWith(_IngameState value, $Res Function(_IngameState) _then) = __$IngameStateCopyWithImpl;
@override @useResult
$Res call({
 IngamePhase phase, IngameWarning? warning
});


@override $IngamePhaseCopyWith<$Res> get phase;@override $IngameWarningCopyWith<$Res>? get warning;

}
/// @nodoc
class __$IngameStateCopyWithImpl<$Res>
    implements _$IngameStateCopyWith<$Res> {
  __$IngameStateCopyWithImpl(this._self, this._then);

  final _IngameState _self;
  final $Res Function(_IngameState) _then;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? warning = freezed,}) {
  return _then(_IngameState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as IngamePhase,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IngameWarning?,
  ));
}

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngamePhaseCopyWith<$Res> get phase {
  
  return $IngamePhaseCopyWith<$Res>(_self.phase, (value) {
    return _then(_self.copyWith(phase: value));
  });
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameWarningCopyWith<$Res>? get warning {
    if (_self.warning == null) {
    return null;
  }

  return $IngameWarningCopyWith<$Res>(_self.warning!, (value) {
    return _then(_self.copyWith(warning: value));
  });
}
}

// dart format on
