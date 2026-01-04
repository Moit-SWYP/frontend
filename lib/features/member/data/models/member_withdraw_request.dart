import 'package:json_annotation/json_annotation.dart';

part 'member_withdraw_request.g.dart';

/// 회원 탈퇴 요청
///
/// POST /api/members/me/withdraw
@JsonSerializable()
class MemberWithdrawRequest {
  final String type; // 탈퇴 사유 타입
  final String? description; // 상세 설명 (최대 500자, 선택)

  MemberWithdrawRequest({
    required this.type,
    this.description,
  });

  factory MemberWithdrawRequest.fromJson(Map<String, dynamic> json) =>
      _$MemberWithdrawRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MemberWithdrawRequestToJson(this);
}

/// 탈퇴 사유 타입
enum WithdrawType {
  SCHEDULE_INCONVENIENT, // 일정 생성이 불편해요
  NO_FEATURE, // 원하는 기능이 없어요
  BUG, // 버그가 자주 발생해요
  ETC, // 기타
}

extension WithdrawTypeExtension on WithdrawType {
  /// 탈퇴 사유 한글 이름
  String get displayName {
    switch (this) {
      case WithdrawType.SCHEDULE_INCONVENIENT:
        return '일정 생성이 불편해요';
      case WithdrawType.NO_FEATURE:
        return '원하는 기능이 없어요';
      case WithdrawType.BUG:
        return '버그가 자주 발생해요';
      case WithdrawType.ETC:
        return '기타';
    }
  }

  /// Enum을 문자열로 변환
  String toJson() => name;

  /// 문자열을 Enum으로 변환
  static WithdrawType fromJson(String json) {
    return WithdrawType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => WithdrawType.ETC,
    );
  }
}
