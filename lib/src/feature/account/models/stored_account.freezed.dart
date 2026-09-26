// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stored_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StoredAccountRecord {

@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson) Account get account; String get encodedSecret; int get version;
/// Create a copy of StoredAccountRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoredAccountRecordCopyWith<StoredAccountRecord> get copyWith => _$StoredAccountRecordCopyWithImpl<StoredAccountRecord>(this as StoredAccountRecord, _$identity);

  /// Serializes this StoredAccountRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoredAccountRecord&&(identical(other.account, account) || other.account == account)&&(identical(other.encodedSecret, encodedSecret) || other.encodedSecret == encodedSecret)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,account,encodedSecret,version);

@override
String toString() {
  return 'StoredAccountRecord(account: $account, encodedSecret: $encodedSecret, version: $version)';
}


}

/// @nodoc
abstract mixin class $StoredAccountRecordCopyWith<$Res>  {
  factory $StoredAccountRecordCopyWith(StoredAccountRecord value, $Res Function(StoredAccountRecord) _then) = _$StoredAccountRecordCopyWithImpl;
@useResult
$Res call({
@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson) Account account, String encodedSecret, int version
});


$AccountCopyWith<$Res> get account;

}
/// @nodoc
class _$StoredAccountRecordCopyWithImpl<$Res>
    implements $StoredAccountRecordCopyWith<$Res> {
  _$StoredAccountRecordCopyWithImpl(this._self, this._then);

  final StoredAccountRecord _self;
  final $Res Function(StoredAccountRecord) _then;

/// Create a copy of StoredAccountRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? account = null,Object? encodedSecret = null,Object? version = null,}) {
  return _then(_self.copyWith(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,encodedSecret: null == encodedSecret ? _self.encodedSecret : encodedSecret // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of StoredAccountRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {

  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}


/// Adds pattern-matching-related methods to [StoredAccountRecord].
extension StoredAccountRecordPatterns on StoredAccountRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoredAccountRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoredAccountRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoredAccountRecord value)  $default,){
final _that = this;
switch (_that) {
case _StoredAccountRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoredAccountRecord value)?  $default,){
final _that = this;
switch (_that) {
case _StoredAccountRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson)  Account account,  String encodedSecret,  int version)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoredAccountRecord() when $default != null:
return $default(_that.account,_that.encodedSecret,_that.version);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson)  Account account,  String encodedSecret,  int version)  $default,) {final _that = this;
switch (_that) {
case _StoredAccountRecord():
return $default(_that.account,_that.encodedSecret,_that.version);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson)  Account account,  String encodedSecret,  int version)?  $default,) {final _that = this;
switch (_that) {
case _StoredAccountRecord() when $default != null:
return $default(_that.account,_that.encodedSecret,_that.version);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StoredAccountRecord implements StoredAccountRecord {
  const _StoredAccountRecord({@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson) required this.account, required this.encodedSecret, required this.version});
  factory _StoredAccountRecord.fromJson(Map<String, dynamic> json) => _$StoredAccountRecordFromJson(json);

@override@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson) final  Account account;
@override final  String encodedSecret;
@override final  int version;

/// Create a copy of StoredAccountRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoredAccountRecordCopyWith<_StoredAccountRecord> get copyWith => __$StoredAccountRecordCopyWithImpl<_StoredAccountRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoredAccountRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoredAccountRecord&&(identical(other.account, account) || other.account == account)&&(identical(other.encodedSecret, encodedSecret) || other.encodedSecret == encodedSecret)&&(identical(other.version, version) || other.version == version));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,account,encodedSecret,version);

@override
String toString() {
  return 'StoredAccountRecord(account: $account, encodedSecret: $encodedSecret, version: $version)';
}


}

/// @nodoc
abstract mixin class _$StoredAccountRecordCopyWith<$Res> implements $StoredAccountRecordCopyWith<$Res> {
  factory _$StoredAccountRecordCopyWith(_StoredAccountRecord value, $Res Function(_StoredAccountRecord) _then) = __$StoredAccountRecordCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(fromJson: _accountFromJson, toJson: _accountToJson) Account account, String encodedSecret, int version
});


@override $AccountCopyWith<$Res> get account;

}
/// @nodoc
class __$StoredAccountRecordCopyWithImpl<$Res>
    implements _$StoredAccountRecordCopyWith<$Res> {
  __$StoredAccountRecordCopyWithImpl(this._self, this._then);

  final _StoredAccountRecord _self;
  final $Res Function(_StoredAccountRecord) _then;

/// Create a copy of StoredAccountRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? account = null,Object? encodedSecret = null,Object? version = null,}) {
  return _then(_StoredAccountRecord(
account: null == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as Account,encodedSecret: null == encodedSecret ? _self.encodedSecret : encodedSecret // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of StoredAccountRecord
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountCopyWith<$Res> get account {

  return $AccountCopyWith<$Res>(_self.account, (value) {
    return _then(_self.copyWith(account: value));
  });
}
}

// dart format on
