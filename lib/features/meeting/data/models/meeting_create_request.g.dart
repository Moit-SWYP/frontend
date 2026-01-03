// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_create_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingCreateRequest _$MeetingCreateRequestFromJson(
        Map<String, dynamic> json) =>
    MeetingCreateRequest(
      title: json['title'] as String,
      date: json['date'] as String?,
      dateVoteDeadline: json['dateVoteDeadline'] == null
          ? null
          : DateTime.parse(json['dateVoteDeadline'] as String),
      courseVoteDeadline: json['courseVoteDeadline'] == null
          ? null
          : DateTime.parse(json['courseVoteDeadline'] as String),
    );

Map<String, dynamic> _$MeetingCreateRequestToJson(
        MeetingCreateRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'date': instance.date,
      'dateVoteDeadline': instance.dateVoteDeadline?.toIso8601String(),
      'courseVoteDeadline': instance.courseVoteDeadline?.toIso8601String(),
    };
