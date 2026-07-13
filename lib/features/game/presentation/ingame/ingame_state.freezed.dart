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
mixin _$IngameCompass {

 double get bearingDeg; double get distanceM; DateTime get expiresAt; DateTime get receivedAt;
/// Create a copy of IngameCompass
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngameCompassCopyWith<IngameCompass> get copyWith => _$IngameCompassCopyWithImpl<IngameCompass>(this as IngameCompass, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameCompass&&(identical(other.bearingDeg, bearingDeg) || other.bearingDeg == bearingDeg)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt));
}


@override
int get hashCode => Object.hash(runtimeType,bearingDeg,distanceM,expiresAt,receivedAt);

@override
String toString() {
  return 'IngameCompass(bearingDeg: $bearingDeg, distanceM: $distanceM, expiresAt: $expiresAt, receivedAt: $receivedAt)';
}


}

/// @nodoc
abstract mixin class $IngameCompassCopyWith<$Res>  {
  factory $IngameCompassCopyWith(IngameCompass value, $Res Function(IngameCompass) _then) = _$IngameCompassCopyWithImpl;
@useResult
$Res call({
 double bearingDeg, double distanceM, DateTime expiresAt, DateTime receivedAt
});




}
/// @nodoc
class _$IngameCompassCopyWithImpl<$Res>
    implements $IngameCompassCopyWith<$Res> {
  _$IngameCompassCopyWithImpl(this._self, this._then);

  final IngameCompass _self;
  final $Res Function(IngameCompass) _then;

/// Create a copy of IngameCompass
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bearingDeg = null,Object? distanceM = null,Object? expiresAt = null,Object? receivedAt = null,}) {
  return _then(_self.copyWith(
bearingDeg: null == bearingDeg ? _self.bearingDeg : bearingDeg // ignore: cast_nullable_to_non_nullable
as double,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [IngameCompass].
extension IngameCompassPatterns on IngameCompass {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngameCompass value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngameCompass() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngameCompass value)  $default,){
final _that = this;
switch (_that) {
case _IngameCompass():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngameCompass value)?  $default,){
final _that = this;
switch (_that) {
case _IngameCompass() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double bearingDeg,  double distanceM,  DateTime expiresAt,  DateTime receivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngameCompass() when $default != null:
return $default(_that.bearingDeg,_that.distanceM,_that.expiresAt,_that.receivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double bearingDeg,  double distanceM,  DateTime expiresAt,  DateTime receivedAt)  $default,) {final _that = this;
switch (_that) {
case _IngameCompass():
return $default(_that.bearingDeg,_that.distanceM,_that.expiresAt,_that.receivedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double bearingDeg,  double distanceM,  DateTime expiresAt,  DateTime receivedAt)?  $default,) {final _that = this;
switch (_that) {
case _IngameCompass() when $default != null:
return $default(_that.bearingDeg,_that.distanceM,_that.expiresAt,_that.receivedAt);case _:
  return null;

}
}

}

/// @nodoc


class _IngameCompass implements IngameCompass {
  const _IngameCompass({required this.bearingDeg, required this.distanceM, required this.expiresAt, required this.receivedAt});
  

@override final  double bearingDeg;
@override final  double distanceM;
@override final  DateTime expiresAt;
@override final  DateTime receivedAt;

/// Create a copy of IngameCompass
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngameCompassCopyWith<_IngameCompass> get copyWith => __$IngameCompassCopyWithImpl<_IngameCompass>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngameCompass&&(identical(other.bearingDeg, bearingDeg) || other.bearingDeg == bearingDeg)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt));
}


@override
int get hashCode => Object.hash(runtimeType,bearingDeg,distanceM,expiresAt,receivedAt);

@override
String toString() {
  return 'IngameCompass(bearingDeg: $bearingDeg, distanceM: $distanceM, expiresAt: $expiresAt, receivedAt: $receivedAt)';
}


}

/// @nodoc
abstract mixin class _$IngameCompassCopyWith<$Res> implements $IngameCompassCopyWith<$Res> {
  factory _$IngameCompassCopyWith(_IngameCompass value, $Res Function(_IngameCompass) _then) = __$IngameCompassCopyWithImpl;
@override @useResult
$Res call({
 double bearingDeg, double distanceM, DateTime expiresAt, DateTime receivedAt
});




}
/// @nodoc
class __$IngameCompassCopyWithImpl<$Res>
    implements _$IngameCompassCopyWith<$Res> {
  __$IngameCompassCopyWithImpl(this._self, this._then);

  final _IngameCompass _self;
  final $Res Function(_IngameCompass) _then;

/// Create a copy of IngameCompass
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bearingDeg = null,Object? distanceM = null,Object? expiresAt = null,Object? receivedAt = null,}) {
  return _then(_IngameCompass(
bearingDeg: null == bearingDeg ? _self.bearingDeg : bearingDeg // ignore: cast_nullable_to_non_nullable
as double,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$IngameTargetLocation {

 double get lat; double get lng;
/// Create a copy of IngameTargetLocation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngameTargetLocationCopyWith<IngameTargetLocation> get copyWith => _$IngameTargetLocationCopyWithImpl<IngameTargetLocation>(this as IngameTargetLocation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameTargetLocation&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}


@override
int get hashCode => Object.hash(runtimeType,lat,lng);

@override
String toString() {
  return 'IngameTargetLocation(lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $IngameTargetLocationCopyWith<$Res>  {
  factory $IngameTargetLocationCopyWith(IngameTargetLocation value, $Res Function(IngameTargetLocation) _then) = _$IngameTargetLocationCopyWithImpl;
@useResult
$Res call({
 double lat, double lng
});




}
/// @nodoc
class _$IngameTargetLocationCopyWithImpl<$Res>
    implements $IngameTargetLocationCopyWith<$Res> {
  _$IngameTargetLocationCopyWithImpl(this._self, this._then);

  final IngameTargetLocation _self;
  final $Res Function(IngameTargetLocation) _then;

/// Create a copy of IngameTargetLocation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,}) {
  return _then(_self.copyWith(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [IngameTargetLocation].
extension IngameTargetLocationPatterns on IngameTargetLocation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngameTargetLocation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngameTargetLocation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngameTargetLocation value)  $default,){
final _that = this;
switch (_that) {
case _IngameTargetLocation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngameTargetLocation value)?  $default,){
final _that = this;
switch (_that) {
case _IngameTargetLocation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngameTargetLocation() when $default != null:
return $default(_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng)  $default,) {final _that = this;
switch (_that) {
case _IngameTargetLocation():
return $default(_that.lat,_that.lng);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng)?  $default,) {final _that = this;
switch (_that) {
case _IngameTargetLocation() when $default != null:
return $default(_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc


class _IngameTargetLocation implements IngameTargetLocation {
  const _IngameTargetLocation({required this.lat, required this.lng});
  

@override final  double lat;
@override final  double lng;

/// Create a copy of IngameTargetLocation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngameTargetLocationCopyWith<_IngameTargetLocation> get copyWith => __$IngameTargetLocationCopyWithImpl<_IngameTargetLocation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngameTargetLocation&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}


@override
int get hashCode => Object.hash(runtimeType,lat,lng);

@override
String toString() {
  return 'IngameTargetLocation(lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$IngameTargetLocationCopyWith<$Res> implements $IngameTargetLocationCopyWith<$Res> {
  factory _$IngameTargetLocationCopyWith(_IngameTargetLocation value, $Res Function(_IngameTargetLocation) _then) = __$IngameTargetLocationCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng
});




}
/// @nodoc
class __$IngameTargetLocationCopyWithImpl<$Res>
    implements _$IngameTargetLocationCopyWith<$Res> {
  __$IngameTargetLocationCopyWithImpl(this._self, this._then);

  final _IngameTargetLocation _self;
  final $Res Function(_IngameTargetLocation) _then;

/// Create a copy of IngameTargetLocation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,}) {
  return _then(_IngameTargetLocation(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$IngameFrameStatus {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameFrameStatus);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngameFrameStatus()';
}


}

/// @nodoc
class $IngameFrameStatusCopyWith<$Res>  {
$IngameFrameStatusCopyWith(IngameFrameStatus _, $Res Function(IngameFrameStatus) __);
}


/// Adds pattern-matching-related methods to [IngameFrameStatus].
extension IngameFrameStatusPatterns on IngameFrameStatus {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FrameReady value)?  ready,TResult Function( FrameWaitingForVerdict value)?  waitingForVerdict,TResult Function( FrameCooldown value)?  cooldown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FrameReady() when ready != null:
return ready(_that);case FrameWaitingForVerdict() when waitingForVerdict != null:
return waitingForVerdict(_that);case FrameCooldown() when cooldown != null:
return cooldown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FrameReady value)  ready,required TResult Function( FrameWaitingForVerdict value)  waitingForVerdict,required TResult Function( FrameCooldown value)  cooldown,}){
final _that = this;
switch (_that) {
case FrameReady():
return ready(_that);case FrameWaitingForVerdict():
return waitingForVerdict(_that);case FrameCooldown():
return cooldown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FrameReady value)?  ready,TResult? Function( FrameWaitingForVerdict value)?  waitingForVerdict,TResult? Function( FrameCooldown value)?  cooldown,}){
final _that = this;
switch (_that) {
case FrameReady() when ready != null:
return ready(_that);case FrameWaitingForVerdict() when waitingForVerdict != null:
return waitingForVerdict(_that);case FrameCooldown() when cooldown != null:
return cooldown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  ready,TResult Function()?  waitingForVerdict,TResult Function( DateTime until)?  cooldown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FrameReady() when ready != null:
return ready();case FrameWaitingForVerdict() when waitingForVerdict != null:
return waitingForVerdict();case FrameCooldown() when cooldown != null:
return cooldown(_that.until);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  ready,required TResult Function()  waitingForVerdict,required TResult Function( DateTime until)  cooldown,}) {final _that = this;
switch (_that) {
case FrameReady():
return ready();case FrameWaitingForVerdict():
return waitingForVerdict();case FrameCooldown():
return cooldown(_that.until);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  ready,TResult? Function()?  waitingForVerdict,TResult? Function( DateTime until)?  cooldown,}) {final _that = this;
switch (_that) {
case FrameReady() when ready != null:
return ready();case FrameWaitingForVerdict() when waitingForVerdict != null:
return waitingForVerdict();case FrameCooldown() when cooldown != null:
return cooldown(_that.until);case _:
  return null;

}
}

}

/// @nodoc


class FrameReady implements IngameFrameStatus {
  const FrameReady();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FrameReady);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngameFrameStatus.ready()';
}


}




/// @nodoc


class FrameWaitingForVerdict implements IngameFrameStatus {
  const FrameWaitingForVerdict();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FrameWaitingForVerdict);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'IngameFrameStatus.waitingForVerdict()';
}


}




/// @nodoc


class FrameCooldown implements IngameFrameStatus {
  const FrameCooldown({required this.until});
  

 final  DateTime until;

/// Create a copy of IngameFrameStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FrameCooldownCopyWith<FrameCooldown> get copyWith => _$FrameCooldownCopyWithImpl<FrameCooldown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FrameCooldown&&(identical(other.until, until) || other.until == until));
}


@override
int get hashCode => Object.hash(runtimeType,until);

@override
String toString() {
  return 'IngameFrameStatus.cooldown(until: $until)';
}


}

/// @nodoc
abstract mixin class $FrameCooldownCopyWith<$Res> implements $IngameFrameStatusCopyWith<$Res> {
  factory $FrameCooldownCopyWith(FrameCooldown value, $Res Function(FrameCooldown) _then) = _$FrameCooldownCopyWithImpl;
@useResult
$Res call({
 DateTime until
});




}
/// @nodoc
class _$FrameCooldownCopyWithImpl<$Res>
    implements $FrameCooldownCopyWith<$Res> {
  _$FrameCooldownCopyWithImpl(this._self, this._then);

  final FrameCooldown _self;
  final $Res Function(FrameCooldown) _then;

/// Create a copy of IngameFrameStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? until = null,}) {
  return _then(FrameCooldown(
until: null == until ? _self.until : until // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$IngameState {

 IngamePhase get phase; IngameWarning? get warning; IngameCompass? get compass; IngameTargetLocation? get targetLocation; IngameFrameStatus get frameStatus;
/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngameStateCopyWith<IngameState> get copyWith => _$IngameStateCopyWithImpl<IngameState>(this as IngameState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngameState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.compass, compass) || other.compass == compass)&&(identical(other.targetLocation, targetLocation) || other.targetLocation == targetLocation)&&(identical(other.frameStatus, frameStatus) || other.frameStatus == frameStatus));
}


@override
int get hashCode => Object.hash(runtimeType,phase,warning,compass,targetLocation,frameStatus);

@override
String toString() {
  return 'IngameState(phase: $phase, warning: $warning, compass: $compass, targetLocation: $targetLocation, frameStatus: $frameStatus)';
}


}

/// @nodoc
abstract mixin class $IngameStateCopyWith<$Res>  {
  factory $IngameStateCopyWith(IngameState value, $Res Function(IngameState) _then) = _$IngameStateCopyWithImpl;
@useResult
$Res call({
 IngamePhase phase, IngameWarning? warning, IngameCompass? compass, IngameTargetLocation? targetLocation, IngameFrameStatus frameStatus
});


$IngamePhaseCopyWith<$Res> get phase;$IngameWarningCopyWith<$Res>? get warning;$IngameCompassCopyWith<$Res>? get compass;$IngameTargetLocationCopyWith<$Res>? get targetLocation;$IngameFrameStatusCopyWith<$Res> get frameStatus;

}
/// @nodoc
class _$IngameStateCopyWithImpl<$Res>
    implements $IngameStateCopyWith<$Res> {
  _$IngameStateCopyWithImpl(this._self, this._then);

  final IngameState _self;
  final $Res Function(IngameState) _then;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? phase = null,Object? warning = freezed,Object? compass = freezed,Object? targetLocation = freezed,Object? frameStatus = null,}) {
  return _then(_self.copyWith(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as IngamePhase,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IngameWarning?,compass: freezed == compass ? _self.compass : compass // ignore: cast_nullable_to_non_nullable
as IngameCompass?,targetLocation: freezed == targetLocation ? _self.targetLocation : targetLocation // ignore: cast_nullable_to_non_nullable
as IngameTargetLocation?,frameStatus: null == frameStatus ? _self.frameStatus : frameStatus // ignore: cast_nullable_to_non_nullable
as IngameFrameStatus,
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
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameCompassCopyWith<$Res>? get compass {
    if (_self.compass == null) {
    return null;
  }

  return $IngameCompassCopyWith<$Res>(_self.compass!, (value) {
    return _then(_self.copyWith(compass: value));
  });
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameTargetLocationCopyWith<$Res>? get targetLocation {
    if (_self.targetLocation == null) {
    return null;
  }

  return $IngameTargetLocationCopyWith<$Res>(_self.targetLocation!, (value) {
    return _then(_self.copyWith(targetLocation: value));
  });
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameFrameStatusCopyWith<$Res> get frameStatus {
  
  return $IngameFrameStatusCopyWith<$Res>(_self.frameStatus, (value) {
    return _then(_self.copyWith(frameStatus: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( IngamePhase phase,  IngameWarning? warning,  IngameCompass? compass,  IngameTargetLocation? targetLocation,  IngameFrameStatus frameStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngameState() when $default != null:
return $default(_that.phase,_that.warning,_that.compass,_that.targetLocation,_that.frameStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( IngamePhase phase,  IngameWarning? warning,  IngameCompass? compass,  IngameTargetLocation? targetLocation,  IngameFrameStatus frameStatus)  $default,) {final _that = this;
switch (_that) {
case _IngameState():
return $default(_that.phase,_that.warning,_that.compass,_that.targetLocation,_that.frameStatus);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( IngamePhase phase,  IngameWarning? warning,  IngameCompass? compass,  IngameTargetLocation? targetLocation,  IngameFrameStatus frameStatus)?  $default,) {final _that = this;
switch (_that) {
case _IngameState() when $default != null:
return $default(_that.phase,_that.warning,_that.compass,_that.targetLocation,_that.frameStatus);case _:
  return null;

}
}

}

/// @nodoc


class _IngameState implements IngameState {
  const _IngameState({required this.phase, this.warning, this.compass, this.targetLocation, this.frameStatus = const IngameFrameStatus.ready()});
  

@override final  IngamePhase phase;
@override final  IngameWarning? warning;
@override final  IngameCompass? compass;
@override final  IngameTargetLocation? targetLocation;
@override@JsonKey() final  IngameFrameStatus frameStatus;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngameStateCopyWith<_IngameState> get copyWith => __$IngameStateCopyWithImpl<_IngameState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngameState&&(identical(other.phase, phase) || other.phase == phase)&&(identical(other.warning, warning) || other.warning == warning)&&(identical(other.compass, compass) || other.compass == compass)&&(identical(other.targetLocation, targetLocation) || other.targetLocation == targetLocation)&&(identical(other.frameStatus, frameStatus) || other.frameStatus == frameStatus));
}


@override
int get hashCode => Object.hash(runtimeType,phase,warning,compass,targetLocation,frameStatus);

@override
String toString() {
  return 'IngameState(phase: $phase, warning: $warning, compass: $compass, targetLocation: $targetLocation, frameStatus: $frameStatus)';
}


}

/// @nodoc
abstract mixin class _$IngameStateCopyWith<$Res> implements $IngameStateCopyWith<$Res> {
  factory _$IngameStateCopyWith(_IngameState value, $Res Function(_IngameState) _then) = __$IngameStateCopyWithImpl;
@override @useResult
$Res call({
 IngamePhase phase, IngameWarning? warning, IngameCompass? compass, IngameTargetLocation? targetLocation, IngameFrameStatus frameStatus
});


@override $IngamePhaseCopyWith<$Res> get phase;@override $IngameWarningCopyWith<$Res>? get warning;@override $IngameCompassCopyWith<$Res>? get compass;@override $IngameTargetLocationCopyWith<$Res>? get targetLocation;@override $IngameFrameStatusCopyWith<$Res> get frameStatus;

}
/// @nodoc
class __$IngameStateCopyWithImpl<$Res>
    implements _$IngameStateCopyWith<$Res> {
  __$IngameStateCopyWithImpl(this._self, this._then);

  final _IngameState _self;
  final $Res Function(_IngameState) _then;

/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? phase = null,Object? warning = freezed,Object? compass = freezed,Object? targetLocation = freezed,Object? frameStatus = null,}) {
  return _then(_IngameState(
phase: null == phase ? _self.phase : phase // ignore: cast_nullable_to_non_nullable
as IngamePhase,warning: freezed == warning ? _self.warning : warning // ignore: cast_nullable_to_non_nullable
as IngameWarning?,compass: freezed == compass ? _self.compass : compass // ignore: cast_nullable_to_non_nullable
as IngameCompass?,targetLocation: freezed == targetLocation ? _self.targetLocation : targetLocation // ignore: cast_nullable_to_non_nullable
as IngameTargetLocation?,frameStatus: null == frameStatus ? _self.frameStatus : frameStatus // ignore: cast_nullable_to_non_nullable
as IngameFrameStatus,
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
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameCompassCopyWith<$Res>? get compass {
    if (_self.compass == null) {
    return null;
  }

  return $IngameCompassCopyWith<$Res>(_self.compass!, (value) {
    return _then(_self.copyWith(compass: value));
  });
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameTargetLocationCopyWith<$Res>? get targetLocation {
    if (_self.targetLocation == null) {
    return null;
  }

  return $IngameTargetLocationCopyWith<$Res>(_self.targetLocation!, (value) {
    return _then(_self.copyWith(targetLocation: value));
  });
}/// Create a copy of IngameState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$IngameFrameStatusCopyWith<$Res> get frameStatus {
  
  return $IngameFrameStatusCopyWith<$Res>(_self.frameStatus, (value) {
    return _then(_self.copyWith(frameStatus: value));
  });
}
}

// dart format on
