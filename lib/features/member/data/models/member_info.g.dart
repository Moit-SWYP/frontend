// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberInfo _$MemberInfoFromJson(Map<String, dynamic> json) => MemberInfo(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      birthDate: json['birthDate'] as String,
      gender: json['gender'] as String,
      socialAccounts: (json['socialAccounts'] as List<dynamic>)
          .map((e) => SocialAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MemberInfoToJson(MemberInfo instance) =>
    <String, dynamic>{
      'email': instance.email,
      'nickname': instance.nickname,
      'birthDate': instance.birthDate,
      'gender': instance.gender,
      'socialAccounts': instance.socialAccounts,
    };
