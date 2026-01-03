import 'package:json_annotation/json_annotation.dart';

part 'login_request.g.dart';

/// 소셜 로그인 제공자
enum SocialProvider {
  @JsonValue('KAKAO')
  kakao,
  @JsonValue('NAVER')
  naver,
}

/// 로그인 요청 모델
@JsonSerializable()
class LoginRequest {
  final SocialProvider socialProvider;
  final String socialId;
  final String email;

  LoginRequest({
    required this.socialProvider,
    required this.socialId,
    required this.email,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}
