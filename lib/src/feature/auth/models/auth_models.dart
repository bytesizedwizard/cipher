import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';

@freezed
abstract class AuthEntity with _$AuthEntity {
  const AuthEntity._();

  factory AuthEntity({
    required String label,
    required String secret,
    required String issuer,
    required String algorithm,
    required int digits,
    required int period,
    required String type,
  }) = _AuthEntity;
}
