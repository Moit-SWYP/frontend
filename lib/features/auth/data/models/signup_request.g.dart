// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupRequest _$SignupRequestFromJson(Map<String, dynamic> json) =>
    SignupRequest(
      login: LoginRequest.fromJson(json['login'] as Map<String, dynamic>),
      nickname: json['nickname'] as String,
      birthDate: json['birthDate'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      characterType: $enumDecode(_$CharacterTypeEnumMap, json['characterType']),
    );

Map<String, dynamic> _$SignupRequestToJson(SignupRequest instance) =>
    <String, dynamic>{
      'login': instance.login,
      'nickname': instance.nickname,
      'birthDate': instance.birthDate,
      'gender': _$GenderEnumMap[instance.gender]!,
      'characterType': _$CharacterTypeEnumMap[instance.characterType]!,
    };

const _$GenderEnumMap = {
  Gender.male: 'MALE',
  Gender.female: 'FEMALE',
};

const _$CharacterTypeEnumMap = {
  CharacterType.FOODIE: 'FOODIE',
  CharacterType.DRINKER: 'DRINKER',
  CharacterType.HEALER: 'HEALER',
  CharacterType.CULTURE_LOVER: 'CULTURE_LOVER',
  CharacterType.TRAVELER: 'TRAVELER',
  CharacterType.ACTIVE: 'ACTIVE',
  CharacterType.TREND_SETTER: 'TREND_SETTER',
  CharacterType.STUDYER: 'STUDYER',
};
