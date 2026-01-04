import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';

part 'home_response.g.dart';

/// 참여자 역할
enum MeetingParticipantRole {
  @JsonValue('HOST') host,
  @JsonValue('MEMBER') member,
}

/// 참여자 정보
@JsonSerializable()
class ParticipantInfo {
  final int memberId;
  final String nickname;
  final CharacterType characterType;
  final MeetingParticipantRole meetingParticipantRole;

  ParticipantInfo({
    required this.memberId,
    required this.nickname,
    required this.characterType,
    required this.meetingParticipantRole,
  });

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) =>
      _$ParticipantInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantInfoToJson(this);

  /// 역할 텍스트
  String get roleText {
    switch (meetingParticipantRole) {
      case MeetingParticipantRole.host:
        return '방장';
      case MeetingParticipantRole.member:
        return '멤버';
    }
  }

  /// 캐릭터 아이콘 경로
  String get characterIcon {
    switch (characterType) {
      case CharacterType.foodie:
        return 'assets/icons/food_S.svg';
      case CharacterType.drinker:
        return 'assets/icons/alcohol_S.svg';
      case CharacterType.healer:
        return 'assets/icons/healer.svg';
      case CharacterType.cultureLover:
        return 'assets/icons/exhibit_S.svg';
      case CharacterType.traveler:
        return 'assets/icons/traveler.svg';
      case CharacterType.active:
        return 'assets/icons/active.svg';
      case CharacterType.trendSetter:
        return 'assets/icons/trend.svg';
      case CharacterType.studyer:
        return 'assets/icons/study_S.svg';
    }
  }
}

/// 참여자가 포함된 모임 정보
@JsonSerializable()
class MeetingBriefWithParticipants {
  final int meetingId;
  final String title;
  final MeetingStatus status;
  final String? date; // yyyy-MM-dd format
  @JsonKey(defaultValue: [])
  final List<ParticipantInfo> participants;

  MeetingBriefWithParticipants({
    required this.meetingId,
    required this.title,
    required this.status,
    this.date,
    required this.participants,
  });

  factory MeetingBriefWithParticipants.fromJson(Map<String, dynamic> json) =>
      _$MeetingBriefWithParticipantsFromJson(json);

  Map<String, dynamic> toJson() => _$MeetingBriefWithParticipantsToJson(this);

  /// 상태 텍스트 (MeetingBrief와 동일한 로직)
  String get statusText {
    switch (status) {
      case MeetingStatus.created:
        return '생성됨';
      case MeetingStatus.dateVoting:
        return '날짜 투표 중';
      case MeetingStatus.dateVoted:
        return '날짜 투표 완료';
      case MeetingStatus.timeVoting:
        return '시간 투표 중';
      case MeetingStatus.timeVoted:
        return '시간 투표 완료';
      case MeetingStatus.placeVoting:
        return '장소 투표 중';
      case MeetingStatus.placeVoted:
        return '장소 투표 완료';
      case MeetingStatus.fixed:
        return '확정됨';
      case MeetingStatus.done:
        return '완료됨';
    }
  }

  /// 참여자 수
  int get participantCount => participants.length;

  /// 방장 정보
  ParticipantInfo? get host {
    try {
      return participants.firstWhere(
        (p) => p.meetingParticipantRole == MeetingParticipantRole.host,
      );
    } catch (e) {
      return null;
    }
  }
}

/// 홈 화면 응답
@JsonSerializable()
class HomeResponse {
  @JsonKey(defaultValue: [])
  final List<MeetingBriefWithParticipants> homeMeetings;
  @JsonKey(defaultValue: [])
  final List<MeetingBrief> waitingMeetings;

  HomeResponse({
    required this.homeMeetings,
    required this.waitingMeetings,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) =>
      _$HomeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$HomeResponseToJson(this);

  /// 전체 모임 개수
  int get totalMeetingCount => homeMeetings.length + waitingMeetings.length;

  /// 홈 모임이 비어있는지
  bool get hasHomeMeetings => homeMeetings.isNotEmpty;

  /// 대기 중인 모임이 있는지
  bool get hasWaitingMeetings => waitingMeetings.isNotEmpty;
}
