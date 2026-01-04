// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_link_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SocialLinkRequest _$SocialLinkRequestFromJson(Map<String, dynamic> json) =>
    SocialLinkRequest(
      socialProvider: json['socialProvider'] as String,
      socialId: json['socialId'] as String,
    );

Map<String, dynamic> _$SocialLinkRequestToJson(SocialLinkRequest instance) =>
    <String, dynamic>{
      'socialProvider': instance.socialProvider,
      'socialId': instance.socialId,
    };
