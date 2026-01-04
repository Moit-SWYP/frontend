import 'package:json_annotation/json_annotation.dart';

part 'social_link_request.g.dart';

/// 소셜 계정 연동 요청
///
/// POST /api/members/me/social-accounts
@JsonSerializable()
class SocialLinkRequest {
  final String socialProvider; // 소셜 제공자 (KAKAO, NAVER)
  final String socialId; // 소셜 ID

  SocialLinkRequest({
    required this.socialProvider,
    required this.socialId,
  });

  factory SocialLinkRequest.fromJson(Map<String, dynamic> json) =>
      _$SocialLinkRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SocialLinkRequestToJson(this);
}
