// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  label: json['label'] as String,
  issuer: json['issuer'] as String,
  algorithm: json['algorithm'] as String,
  digits: (json['digits'] as num).toInt(),
  period: (json['period'] as num).toInt(),
  type: json['type'] as String,
  counter: (json['counter'] as num?)?.toInt() ?? 0,
  otp: json['otp'] as String?,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'label': instance.label,
  'issuer': instance.issuer,
  'algorithm': instance.algorithm,
  'digits': instance.digits,
  'period': instance.period,
  'type': instance.type,
  'counter': instance.counter,
  'otp': instance.otp,
};
