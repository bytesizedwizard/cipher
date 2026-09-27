// ignore_for_file: invalid_annotation_target

import 'package:cipher/src/feature/account/models/auth_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stored_account.freezed.dart';
part 'stored_account.g.dart';

Account _accountFromJson(Object? json) {
  return Account.fromJson(Map<String, Object?>.from(json! as Map));
}

Map<String, Object?> _accountToJson(Account account) => account.toJson();

@freezed
abstract class StoredAccountRecord with _$StoredAccountRecord {
  const factory StoredAccountRecord({
    @JsonKey(fromJson: _accountFromJson, toJson: _accountToJson)
    required Account account,
    required String encodedSecret,
    required int version,
  }) = _StoredAccountRecord;

  factory StoredAccountRecord.fromJson(Map<String, Object?> json) =>
      _$StoredAccountRecordFromJson(json);
}
