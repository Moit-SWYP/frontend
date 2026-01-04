import 'package:json_annotation/json_annotation.dart';

part 'meeting_update_request.g.dart';

/// 모임 수정 요청
///
/// PATCH /api/meetings/{id} 요청 데이터
/// title은 blank 불가 (null은 가능)
@JsonSerializable()
class MeetingUpdateRequest {
  final String? title; // 선택 (null 가능, blank 불가)
  final String? date; // yyyy-MM-dd 형식 (선택)
  final DateTime? dateVoteDeadline; // ISO 8601 형식 (선택)
  final DateTime? courseVoteDeadline; // ISO 8601 형식 (선택)

  MeetingUpdateRequest({
    this.title,
    this.date,
    this.dateVoteDeadline,
    this.courseVoteDeadline,
  });

  factory MeetingUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$MeetingUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingUpdateRequestToJson(this);
}
