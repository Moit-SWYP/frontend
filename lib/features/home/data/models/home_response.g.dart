// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParticipantInfo _$ParticipantInfoFromJson(Map<String, dynamic> json) =>
    ParticipantInfo(
      memberId: (json['memberId'] as num).toInt(),
      nickname: json['nickname'] as String,
      characterType:
          CharacterTypeExtension.fromJson(json['characterType'] as String),
      meetingParticipantRole: $enumDecode(
          _$MeetingParticipantRoleEnumMap, json['meetingParticipantRole']),
    );

Map<String, dynamic> _$ParticipantInfoToJson(ParticipantInfo instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'nickname': instance.nickname,
      'characterType':
          ParticipantInfo._characterTypeToJson(instance.characterType),
      'meetingParticipantRole':
          _$MeetingParticipantRoleEnumMap[instance.meetingParticipantRole]!,
    };

const _$MeetingParticipantRoleEnumMap = {
  MeetingParticipantRole.host: 'HOST',
  MeetingParticipantRole.member: 'MEMBER',
};

MeetingBriefWithParticipants _$MeetingBriefWithParticipantsFromJson(
        Map<String, dynamic> json) =>
    MeetingBriefWithParticipants(
      meetingId: (json['meetingId'] as num).toInt(),
      title: json['title'] as String,
      status: $enumDecode(_$MeetingStatusEnumMap, json['status']),
      date: json['date'] as String?,
      time: json['time'] as String?,
      participants: (json['participants'] as List<dynamic>?)
              ?.map((e) => ParticipantInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$MeetingBriefWithParticipantsToJson(
        MeetingBriefWithParticipants instance) =>
    <String, dynamic>{
      'meetingId': instance.meetingId,
      'title': instance.title,
      'status': _$MeetingStatusEnumMap[instance.status]!,
      'date': instance.date,
      'time': instance.time,
      'participants': instance.participants,
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

HomeResponse _$HomeResponseFromJson(Map<String, dynamic> json) => HomeResponse(
      homeMeetings: (json['homeMeetings'] as List<dynamic>?)
              ?.map((e) => MeetingBriefWithParticipants.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
      waitingMeetings: (json['waitingMeetings'] as List<dynamic>?)
              ?.map((e) => MeetingBrief.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$HomeResponseToJson(HomeResponse instance) =>
    <String, dynamic>{
      'homeMeetings': instance.homeMeetings,
      'waitingMeetings': instance.waitingMeetings,
    };
