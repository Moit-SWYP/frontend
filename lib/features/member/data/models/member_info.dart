import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/member/data/models/character_type.dart';
import 'package:moit/features/member/data/models/social_account.dart';

part 'member_info.g.dart';

/// 회원 정보
///
/// GET /api/members/me 응답 데이터
@JsonSerializable()
class MemberInfo {
  final String email; // 이메일
  final String nickname; // 닉네임
  final String birthDate; // 생년월일 (yyyy-MM-dd)
  final String gender; // 성별 (MALE, FEMALE)
  final List<SocialAccount> socialAccounts; // 연동된 소셜 계정 목록

  @JsonKey(includeFromJson: false, includeToJson: false)
  CharacterType? characterType; // 캐릭터 타입 (선택적)

  MemberInfo({
    required this.email,
    required this.nickname,
    required this.birthDate,
    required this.gender,
    required this.socialAccounts,
    this.characterType,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) =>
      _$MemberInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MemberInfoToJson(this);

  /// 성별 한글 변환
  String get genderText {
    switch (gender) {
      case 'MALE':
        return '남성';
      case 'FEMALE':
        return '여성';
      default:
        return '미지정';
    }
  }

  /// 연동된 소셜 계정 수
  int get socialAccountCount => socialAccounts.length;

  /// 특정 제공자 연동 여부
  bool isSocialLinked(String provider) {
    return socialAccounts.any((account) => account.provider == provider);
  }
}
