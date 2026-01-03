import 'package:json_annotation/json_annotation.dart';

part 'auth_tokens.g.dart';

/// JWT 토큰 쌍
///
/// - accessToken: 15분 유효 (API 인증에 사용)
/// - refreshToken: 7일 유효 (Access Token 재발급에 사용)
@JsonSerializable()
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);

  Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
}
