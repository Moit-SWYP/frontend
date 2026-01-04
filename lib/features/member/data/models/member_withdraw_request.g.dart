// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_withdraw_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberWithdrawRequest _$MemberWithdrawRequestFromJson(
        Map<String, dynamic> json) =>
    MemberWithdrawRequest(
      type: json['type'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$MemberWithdrawRequestToJson(
        MemberWithdrawRequest instance) =>
    <String, dynamic>{
      'type': instance.type,
      'description': instance.description,
    };
