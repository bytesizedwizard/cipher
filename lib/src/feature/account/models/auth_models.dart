import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cipher/src/feature/account/utils/account_storage_keys.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// Represents an authentication entity with its properties
/// and provides methods to access derived information.
///
/// Not to be confused with [SecureEntity], which is used for
/// storage and data transfer.
///
/// Fields:
/// - id: Unique identifier for the entity
/// - label: Label for the entity (e.g., account name)
/// - issuer: Issuer of the OTP (e.g., service provider)
/// - algorithm: Algorithm used for OTP generation (e.g., SHA1)
/// - digits: Number of digits in the generated OTP
/// - period: Time period for TOTP validity (in seconds)
/// - type: Type of OTP (e.g., TOTP or HOTP)
/// - otp: The current one-time password (OTP) value
///
/// Example usage:
/// ```dart
/// final entity = Entity(
///   '1', 'Example:User', 'SECRET', 'ExampleIssuer',
///   'SHA1', 6, 30, 'totp', '123456'
/// );
/// print(entity.accountName); // Outputs: User
/// ```
///
/// To be used for UI representation and OTP generation.
@freezed
@JsonSerializable()
class Account with _$Account {
  @override
  final String label;
  @override
  final String issuer;
  @override
  final String algorithm;
  @override
  final int digits;
  @override
  final int period;
  @override
  final String type;
  @override
  String? otp;

  Account({
    required this.label,
    required this.issuer,
    required this.algorithm,
    required this.digits,
    required this.period,
    required this.type,
    String? otp,
  });

  factory Account.fromJson(Map<String, Object?> json) =>
      _$AccountFromJson(json);

  Map<String, Object?> toJson() => _$AccountToJson(this);

  String get accountName {
    if (label.contains(':')) {
      return label.split(':')[1];
    } else {
      return label;
    }
  }

  String get id {
    return accountStorageKey(issuer, label);
  }

  String get storageId => authoritativeAccountStorageKey(issuer, label);
}
