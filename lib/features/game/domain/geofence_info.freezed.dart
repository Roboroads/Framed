// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'geofence_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GeofenceInfo {

 double get lat; double get lng; int get radiusM;
/// Create a copy of GeofenceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeofenceInfoCopyWith<GeofenceInfo> get copyWith => _$GeofenceInfoCopyWithImpl<GeofenceInfo>(this as GeofenceInfo, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeofenceInfo&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM));
}


@override
int get hashCode => Object.hash(runtimeType,lat,lng,radiusM);

@override
String toString() {
  return 'GeofenceInfo(lat: $lat, lng: $lng, radiusM: $radiusM)';
}


}

/// @nodoc
abstract mixin class $GeofenceInfoCopyWith<$Res>  {
  factory $GeofenceInfoCopyWith(GeofenceInfo value, $Res Function(GeofenceInfo) _then) = _$GeofenceInfoCopyWithImpl;
@useResult
$Res call({
 double lat, double lng, int radiusM
});




}
/// @nodoc
class _$GeofenceInfoCopyWithImpl<$Res>
    implements $GeofenceInfoCopyWith<$Res> {
  _$GeofenceInfoCopyWithImpl(this._self, this._then);

  final GeofenceInfo _self;
  final $Res Function(GeofenceInfo) _then;

/// Create a copy of GeofenceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lat = null,Object? lng = null,Object? radiusM = null,}) {
  return _then(_self.copyWith(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GeofenceInfo].
extension GeofenceInfoPatterns on GeofenceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeofenceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeofenceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeofenceInfo value)  $default,){
final _that = this;
switch (_that) {
case _GeofenceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeofenceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _GeofenceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double lat,  double lng,  int radiusM)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeofenceInfo() when $default != null:
return $default(_that.lat,_that.lng,_that.radiusM);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double lat,  double lng,  int radiusM)  $default,) {final _that = this;
switch (_that) {
case _GeofenceInfo():
return $default(_that.lat,_that.lng,_that.radiusM);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double lat,  double lng,  int radiusM)?  $default,) {final _that = this;
switch (_that) {
case _GeofenceInfo() when $default != null:
return $default(_that.lat,_that.lng,_that.radiusM);case _:
  return null;

}
}

}

/// @nodoc


class _GeofenceInfo implements GeofenceInfo {
  const _GeofenceInfo({required this.lat, required this.lng, required this.radiusM});
  

@override final  double lat;
@override final  double lng;
@override final  int radiusM;

/// Create a copy of GeofenceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeofenceInfoCopyWith<_GeofenceInfo> get copyWith => __$GeofenceInfoCopyWithImpl<_GeofenceInfo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeofenceInfo&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM));
}


@override
int get hashCode => Object.hash(runtimeType,lat,lng,radiusM);

@override
String toString() {
  return 'GeofenceInfo(lat: $lat, lng: $lng, radiusM: $radiusM)';
}


}

/// @nodoc
abstract mixin class _$GeofenceInfoCopyWith<$Res> implements $GeofenceInfoCopyWith<$Res> {
  factory _$GeofenceInfoCopyWith(_GeofenceInfo value, $Res Function(_GeofenceInfo) _then) = __$GeofenceInfoCopyWithImpl;
@override @useResult
$Res call({
 double lat, double lng, int radiusM
});




}
/// @nodoc
class __$GeofenceInfoCopyWithImpl<$Res>
    implements _$GeofenceInfoCopyWith<$Res> {
  __$GeofenceInfoCopyWithImpl(this._self, this._then);

  final _GeofenceInfo _self;
  final $Res Function(_GeofenceInfo) _then;

/// Create a copy of GeofenceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lat = null,Object? lng = null,Object? radiusM = null,}) {
  return _then(_GeofenceInfo(
lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
