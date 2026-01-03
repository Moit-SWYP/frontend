import 'package:json_annotation/json_annotation.dart';

part 'meeting_brief.g.dart';

/// 모임 상태
enum MeetingStatus {
  @JsonValue('CREATED')
  created, // 생성됨
  @JsonValue('DATE_VOTING')
  dateVoting, // 날짜 투표 중
  @JsonValue('DATE_VOTED')
  dateVoted, // 날짜 투표 완료
  @JsonValue('TIME_VOTING')
  timeVoting, // 시간 투표 중
  @JsonValue('TIME_VOTED')
  timeVoted, // 시간 투표 완료
  @JsonValue('PLACE_VOTING')
  placeVoting, // 장소 투표 중
  @JsonValue('PLACE_VOTED')
  placeVoted, // 장소 투표 완료
  @JsonValue('FIXED')
  fixed, // 확정됨
  @JsonValue('DONE')
  done, // 완료됨
}

/// 모임 간략 정보 (목록용)
///
/// GET /api/meetings/all 응답 데이터
@JsonSerializable()
class MeetingBrief {
  final int meetingId;
  final String title;
  final MeetingStatus status;
  final String? date; // yyyy-MM-dd 형식 (nullable)

  MeetingBrief({
    required this.meetingId,
    required this.title,
    required this.status,
    this.date,
  });

  factory MeetingBrief.fromJson(Map<String, dynamic> json) =>
      _$MeetingBriefFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingBriefToJson(this);

  /// 상태 표시용 텍스트
  String get statusText {
    switch (status) {
      case MeetingStatus.created:
        return '생성됨';
      case MeetingStatus.dateVoting:
        return '날짜 투표 중';
      case MeetingStatus.dateVoted:
        return '날짜 결정됨';
      case MeetingStatus.timeVoting:
        return '시간 투표 중';
      case MeetingStatus.timeVoted:
        return '시간 결정됨';
      case MeetingStatus.placeVoting:
        return '장소 투표 중';
      case MeetingStatus.placeVoted:
        return '장소 결정됨';
      case MeetingStatus.fixed:
        return '확정됨';
      case MeetingStatus.done:
        return '완료됨';
    }
  }

  /// 날짜를 DateTime으로 파싱 (nullable)
  DateTime? get dateTime {
    if (date == null) return null;
    try {
      return DateTime.parse(date!);
    } catch (e) {
      print('❌ [MeetingBrief] 날짜 파싱 실패: $date');
      return null;
    }
  }
}
