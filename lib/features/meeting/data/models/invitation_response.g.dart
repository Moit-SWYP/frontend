// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvitationResponse _$InvitationResponseFromJson(Map<String, dynamic> json) =>
    InvitationResponse(
      meetingId: (json['meetingId'] as num).toInt(),
      inviteToken: json['inviteToken'] as String,
    );

Map<String, dynamic> _$InvitationResponseToJson(InvitationResponse instance) =>
    <String, dynamic>{
      'meetingId': instance.meetingId,
      'inviteToken': instance.inviteToken,
    };
