// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vote_summary_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DateSummary _$DateSummaryFromJson(Map<String, dynamic> json) => DateSummary(
      topDates:
          (json['topDates'] as List<dynamic>).map((e) => e as String).toList(),
      votedDates: (json['votedDates'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DateSummaryToJson(DateSummary instance) =>
    <String, dynamic>{
      'topDates': instance.topDates,
      'votedDates': instance.votedDates,
    };

VotedTimeResponse _$VotedTimeResponseFromJson(Map<String, dynamic> json) =>
    VotedTimeResponse(
      time: json['time'] as String,
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$VotedTimeResponseToJson(VotedTimeResponse instance) =>
    <String, dynamic>{
      'time': instance.time,
      'count': instance.count,
    };

TimeSummary _$TimeSummaryFromJson(Map<String, dynamic> json) => TimeSummary(
      topTimes:
          (json['topTimes'] as List<dynamic>).map((e) => e as String).toList(),
      votedTimes: (json['votedTimes'] as List<dynamic>)
          .map((e) => VotedTimeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TimeSummaryToJson(TimeSummary instance) =>
    <String, dynamic>{
      'topTimes': instance.topTimes,
      'votedTimes': instance.votedTimes,
    };

VoteSummaryResponse _$VoteSummaryResponseFromJson(Map<String, dynamic> json) =>
    VoteSummaryResponse(
      meetingStatus: $enumDecode(_$MeetingStatusEnumMap, json['meetingStatus']),
      isHost: json['isHost'] as bool,
      confirmedDate: json['confirmedDate'] as String?,
      confirmedTime: json['confirmedTime'] as String?,
      dateSummary: json['dateSummary'] == null
          ? null
          : DateSummary.fromJson(json['dateSummary'] as Map<String, dynamic>),
      timeSummary: json['timeSummary'] == null
          ? null
          : TimeSummary.fromJson(json['timeSummary'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VoteSummaryResponseToJson(
        VoteSummaryResponse instance) =>
    <String, dynamic>{
      'meetingStatus': _$MeetingStatusEnumMap[instance.meetingStatus]!,
      'isHost': instance.isHost,
      'confirmedDate': instance.confirmedDate,
      'confirmedTime': instance.confirmedTime,
      'dateSummary': instance.dateSummary,
      'timeSummary': instance.timeSummary,
    };

const _$MeetingStatusEnumMap = {
  MeetingStatus.created: 'CREATED',
  MeetingStatus.dateVoting: 'DATE_VOTING',
  MeetingStatus.dateVoted: 'DATE_VOTED',
  MeetingStatus.timeVoting: 'TIME_VOTING',
  MeetingStatus.timeVoted: 'TIME_VOTED',
  MeetingStatus.placeVoting: 'PLACE_VOTING',
  MeetingStatus.placeVoted: 'PLACE_VOTED',
  MeetingStatus.fixed: 'FIXED',
  MeetingStatus.done: 'DONE',
};

DateVoteRequest _$DateVoteRequestFromJson(Map<String, dynamic> json) =>
    DateVoteRequest(
      dates: (json['dates'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$DateVoteRequestToJson(DateVoteRequest instance) =>
    <String, dynamic>{
      'dates': instance.dates,
    };

TimeVoteRequest _$TimeVoteRequestFromJson(Map<String, dynamic> json) =>
    TimeVoteRequest(
      times: (json['times'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TimeVoteRequestToJson(TimeVoteRequest instance) =>
    <String, dynamic>{
      'times': instance.times,
    };

VoterInfo _$VoterInfoFromJson(Map<String, dynamic> json) => VoterInfo(
      memberId: (json['memberId'] as num).toInt(),
      nickname: json['nickname'] as String,
      characterType: json['characterType'] as String,
    );

Map<String, dynamic> _$VoterInfoToJson(VoterInfo instance) => <String, dynamic>{
      'memberId': instance.memberId,
      'nickname': instance.nickname,
      'characterType': instance.characterType,
    };

VotersResponse _$VotersResponseFromJson(Map<String, dynamic> json) =>
    VotersResponse(
      voters: (json['voters'] as List<dynamic>)
          .map((e) => VoterInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$VotersResponseToJson(VotersResponse instance) =>
    <String, dynamic>{
      'voters': instance.voters,
    };
