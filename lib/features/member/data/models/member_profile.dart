import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';

part 'member_profile.g.dart';

/// 소셜 계정 정보
@JsonSerializable()
class SocialAccount {
  @JsonKey(name: 'socialProvider')
  final String provider; // KAKAO, NAVER

  SocialAccount({
    required this.provider,
  });

  factory SocialAccount.fromJson(Map<String, dynamic> json) =>
      _$SocialAccountFromJson(json);

  Map<String, dynamic> toJson() => _$SocialAccountToJson(this);
}

/// 회원 프로필 모델
///
/// GET /api/members/me 응답 데이터
@JsonSerializable()
class MemberProfile {
  final String email;
  final String nickname;
  final String birthDate; // yyyy-MM-dd
  final Gender gender;
  final List<SocialAccount> socialAccounts;

  MemberProfile({
    required this.email,
    required this.nickname,
    required this.birthDate,
    required this.gender,
    required this.socialAccounts,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) =>
      _$MemberProfileFromJson(json);

  Map<String, dynamic> toJson() => _$MemberProfileToJson(this);

  /// 성별 표시용 텍스트
  String get genderText => gender == Gender.male ? '남성' : '여성';

  /// 첫 번째 소셜 계정 provider
  String? get primarySocialProvider =>
      socialAccounts.isNotEmpty ? socialAccounts.first.provider : null;
}
