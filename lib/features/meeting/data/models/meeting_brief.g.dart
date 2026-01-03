// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_brief.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingBrief _$MeetingBriefFromJson(Map<String, dynamic> json) => MeetingBrief(
      meetingId: (json['meetingId'] as num).toInt(),
      title: json['title'] as String,
      status: $enumDecode(_$MeetingStatusEnumMap, json['status']),
      date: json['date'] as String?,
    );

Map<String, dynamic> _$MeetingBriefToJson(MeetingBrief instance) =>
    <String, dynamic>{
      'meetingId': instance.meetingId,
      'title': instance.title,
      'status': _$MeetingStatusEnumMap[instance.status]!,
      'date': instance.date,
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
