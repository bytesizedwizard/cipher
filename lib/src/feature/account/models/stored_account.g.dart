// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stored_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoredAccountRecord _$StoredAccountRecordFromJson(Map<String, dynamic> json) =>
    _StoredAccountRecord(
      account: _accountFromJson(json['account']),
      encodedSecret: json['encodedSecret'] as String,
      version: (json['version'] as num).toInt(),
    );

Map<String, dynamic> _$StoredAccountRecordToJson(
  _StoredAccountRecord instance,
) => <String, dynamic>{
  'account': _accountToJson(instance.account),
  'encodedSecret': instance.encodedSecret,
  'version': instance.version,
};
