// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendInfo _$FriendInfoFromJson(Map<String, dynamic> json) => FriendInfo(
      memberId: (json['memberId'] as num).toInt(),
      nickname: json['nickname'] as String,
      characterType:
          FriendInfo._characterTypeFromJson(json['characterType'] as String),
      metCount: (json['metCount'] as num).toInt(),
    );

Map<String, dynamic> _$FriendInfoToJson(FriendInfo instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'nickname': instance.nickname,
      'characterType': FriendInfo._characterTypeToJson(instance.characterType),
      'metCount': instance.metCount,
    };

MyFriendsResponse _$MyFriendsResponseFromJson(Map<String, dynamic> json) =>
    MyFriendsResponse(
      friends: (json['friends'] as List<dynamic>)
          .map((e) => FriendInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyFriendsResponseToJson(MyFriendsResponse instance) =>
    <String, dynamic>{
      'friends': instance.friends,
    };
