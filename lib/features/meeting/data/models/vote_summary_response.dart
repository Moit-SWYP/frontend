import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';

part 'vote_summary_response.g.dart';

/// 날짜 투표 요약
@JsonSerializable()
class DateSummary {
  final List<String> topDates; // 최다 득표 날짜 리스트
  final List<String> votedDates; // 내가 투표한 날짜 리스트

  DateSummary({
    required this.topDates,
    required this.votedDates,
  });

  factory DateSummary.fromJson(Map<String, dynamic> json) =>
      _$DateSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DateSummaryToJson(this);
}

/// 투표된 시간과 득표 수
@JsonSerializable()
class VotedTimeResponse {
  final String time; // HH:mm 형식
  final int count; // 득표 수

  VotedTimeResponse({
    required this.time,
    required this.count,
  });

  factory VotedTimeResponse.fromJson(Map<String, dynamic> json) =>
      _$VotedTimeResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VotedTimeResponseToJson(this);
}

/// 시간 투표 요약
@JsonSerializable()
class TimeSummary {
  final List<String> topTimes; // 최다 득표 시간 리스트
  final List<VotedTimeResponse> votedTimes; // 투표된 시간과 득표 수 리스트

  TimeSummary({
    required this.topTimes,
    required this.votedTimes,
  });

  factory TimeSummary.fromJson(Map<String, dynamic> json) =>
      _$TimeSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSummaryToJson(this);
}

/// 투표 요약 응답
@JsonSerializable()
class VoteSummaryResponse {
  final MeetingStatus meetingStatus; // 현재 모임 상태
  final bool isHost; // 현재 사용자가 호스트인지
  final String? confirmedDate; // 확정된 날짜 (yyyy-MM-dd)
  final String? confirmedTime; // 확정된 시간 (HH:mm)
  final DateSummary? dateSummary; // 날짜 투표 요약
  final TimeSummary? timeSummary; // 시간 투표 요약

  VoteSummaryResponse({
    required this.meetingStatus,
    required this.isHost,
    this.confirmedDate,
    this.confirmedTime,
    this.dateSummary,
    this.timeSummary,
  });

  factory VoteSummaryResponse.fromJson(Map<String, dynamic> json) =>
      _$VoteSummaryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VoteSummaryResponseToJson(this);

  /// 날짜 투표 진행 중인지
  bool get isDateVoting =>
      meetingStatus == MeetingStatus.dateVoting ||
      meetingStatus == MeetingStatus.created;

  /// 시간 투표 진행 중인지
  bool get isTimeVoting =>
      meetingStatus == MeetingStatus.timeVoting ||
      meetingStatus == MeetingStatus.dateVoted;

  /// 확정 완료되었는지
  bool get isFixed => meetingStatus == MeetingStatus.fixed;

  /// 내가 날짜 투표를 했는지
  bool get hasVotedDate => dateSummary?.votedDates.isNotEmpty ?? false;

  /// 내가 시간 투표를 했는지
  bool get hasVotedTime => timeSummary?.votedTimes.isNotEmpty ?? false;
}

/// 날짜 투표 요청
@JsonSerializable()
class DateVoteRequest {
  final List<String> dates; // yyyy-MM-dd 형식

  DateVoteRequest({required this.dates});

  factory DateVoteRequest.fromJson(Map<String, dynamic> json) =>
      _$DateVoteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$DateVoteRequestToJson(this);
}

/// 시간 투표 요청
@JsonSerializable()
class TimeVoteRequest {
  final List<String> times; // HH:mm 형식

  TimeVoteRequest({required this.times});

  factory TimeVoteRequest.fromJson(Map<String, dynamic> json) =>
      _$TimeVoteRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TimeVoteRequestToJson(this);
}

/// 특정 날짜/시간 투표자 정보
@JsonSerializable()
class VoterInfo {
  final int memberId;
  final String nickname;
  final String characterType;

  VoterInfo({
    required this.memberId,
    required this.nickname,
    required this.characterType,
  });

  factory VoterInfo.fromJson(Map<String, dynamic> json) =>
      _$VoterInfoFromJson(json);

  Map<String, dynamic> toJson() => _$VoterInfoToJson(this);
}

/// 투표자 목록 응답
@JsonSerializable()
class VotersResponse {
  final List<VoterInfo> voters;

  VotersResponse({required this.voters});

  factory VotersResponse.fromJson(Map<String, dynamic> json) =>
      _$VotersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VotersResponseToJson(this);

  /// 투표자 수
  int get voterCount => voters.length;
}
