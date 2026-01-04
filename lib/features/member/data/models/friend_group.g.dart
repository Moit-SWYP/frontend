// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendBriefInfo _$FriendBriefInfoFromJson(Map<String, dynamic> json) =>
    FriendBriefInfo(
      memberId: (json['memberId'] as num).toInt(),
      characterType: FriendBriefInfo._characterTypeFromJson(
          json['characterType'] as String),
    );

Map<String, dynamic> _$FriendBriefInfoToJson(FriendBriefInfo instance) =>
    <String, dynamic>{
      'memberId': instance.memberId,
      'characterType':
          FriendBriefInfo._characterTypeToJson(instance.characterType),
    };

FriendGroupInfo _$FriendGroupInfoFromJson(Map<String, dynamic> json) =>
    FriendGroupInfo(
      groupId: (json['groupId'] as num).toInt(),
      name: json['name'] as String,
      friendsInGroup: (json['friendsInGroup'] as List<dynamic>)
          .map((e) => FriendBriefInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      countFriend: (json['countFriend'] as num).toInt(),
    );

Map<String, dynamic> _$FriendGroupInfoToJson(FriendGroupInfo instance) =>
    <String, dynamic>{
      'groupId': instance.groupId,
      'name': instance.name,
      'friendsInGroup': instance.friendsInGroup,
      'countFriend': instance.countFriend,
    };

MyFriendGroupsResponse _$MyFriendGroupsResponseFromJson(
        Map<String, dynamic> json) =>
    MyFriendGroupsResponse(
      friendGroups: (json['friendGroups'] as List<dynamic>)
          .map((e) => FriendGroupInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyFriendGroupsResponseToJson(
        MyFriendGroupsResponse instance) =>
    <String, dynamic>{
      'friendGroups': instance.friendGroups,
    };

GroupCreateRequest _$GroupCreateRequestFromJson(Map<String, dynamic> json) =>
    GroupCreateRequest(
      name: json['name'] as String,
      groupMemberIds: (json['groupMemberIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$GroupCreateRequestToJson(GroupCreateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'groupMemberIds': instance.groupMemberIds,
    };
