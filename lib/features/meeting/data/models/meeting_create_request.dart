import 'package:json_annotation/json_annotation.dart';

part 'meeting_create_request.g.dart';

/// 모임 생성 요청
///
/// POST /api/meetings 요청 데이터
@JsonSerializable()
class MeetingCreateRequest {
  final String title; // 필수
  final String type; // 필수 - 모임 유형 (FOODIE, DRINKER, HEALER, CULTURE_LOVER, TRAVELER, ACTIVE, TREND_SETTER, STUDIER)
  final String? date; // yyyy-MM-dd 형식 (선택)
  final DateTime? dateVoteDeadline; // ISO 8601 형식 (선택)
  final DateTime? courseVoteDeadline; // ISO 8601 형식 (선택)

  MeetingCreateRequest({
    required this.title,
    this.type = 'FOODIE', // 기본값: 미식형
    this.date,
    this.dateVoteDeadline,
    this.courseVoteDeadline,
  });

  factory MeetingCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$MeetingCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingCreateRequestToJson(this);
}
