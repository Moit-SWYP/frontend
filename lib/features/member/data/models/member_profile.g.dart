// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialAccount _$SocialAccountFromJson(Map<String, dynamic> json) =>
    SocialAccount(
      provider: json['socialProvider'] as String,
    );

Map<String, dynamic> _$SocialAccountToJson(SocialAccount instance) =>
    <String, dynamic>{
      'socialProvider': instance.provider,
    };

MemberProfile _$MemberProfileFromJson(Map<String, dynamic> json) =>
    MemberProfile(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      birthDate: json['birthDate'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      socialAccounts: (json['socialAccounts'] as List<dynamic>)
          .map((e) => SocialAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MemberProfileToJson(MemberProfile instance) =>
    <String, dynamic>{
      'email': instance.email,
      'nickname': instance.nickname,
      'birthDate': instance.birthDate,
      'gender': _$GenderEnumMap[instance.gender]!,
      'socialAccounts': instance.socialAccounts,
    };

const _$GenderEnumMap = {
  Gender.male: 'MALE',
  Gender.female: 'FEMALE',
};
