import 'package:json_annotation/json_annotation.dart';

part 'social_account.g.dart';

/// 소셜 계정 정보
///
/// 회원에 연동된 소셜 로그인 계정
@JsonSerializable()
class SocialAccount {
  final String provider; // 소셜 제공자 (KAKAO, NAVER)

  SocialAccount({
    required this.provider,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialAccountFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAccountToJson(this);

  /// 제공자 이름 한글 변환
  String get providerName {
    switch (provider) {
      case 'KAKAO':
        return '카카오';
      case 'NAVER':
        return '네이버';
      default:
        return provider;
    }
  }
}
