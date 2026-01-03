// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
      socialProvider:
          $enumDecode(_$SocialProviderEnumMap, json['socialProvider']),
      socialId: json['socialId'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'socialProvider': _$SocialProviderEnumMap[instance.socialProvider]!,
      'socialId': instance.socialId,
      'email': instance.email,
    };

const _$SocialProviderEnumMap = {
  SocialProvider.kakao: 'KAKAO',
  SocialProvider.naver: 'NAVER',
};
