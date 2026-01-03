import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/auth/data/models/auth_tokens.dart';

part 'auth_response.g.dart';

/// 인증 응답 모델
///
/// 로그인/회원가입 공통 응답
/// - 기존 회원: signupRequired = false, tokens 포함
/// - 신규 회원: signupRequired = true, tokens = null
@JsonSerializable()
class AuthResponse {
  final bool signupRequired;
  final AuthTokens? tokens;

  AuthResponse({
    required this.signupRequired,
    this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);

  /// 로그인 성공 여부 (토큰이 있으면 성공)
  bool get isAuthenticated => tokens != null;
}
