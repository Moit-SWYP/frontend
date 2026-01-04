import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/member/data/models/character_type.dart';

part 'friend_group.g.dart';

/// 친구 간단 정보 (그룹 내)
@JsonSerializable()
class FriendBriefInfo {
  final int memberId; // 회원 ID
  @JsonKey(fromJson: _characterTypeFromJson, toJson: _characterTypeToJson)
  final CharacterType characterType; // 캐릭터 타입

  FriendBriefInfo({
    required this.memberId,
    required this.characterType,
  });

  factory FriendBriefInfo.fromJson(Map<String, dynamic> json) =>
      _$FriendBriefInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendBriefInfoToJson(this);

  /// CharacterType JSON 변환 헬퍼
  static CharacterType _characterTypeFromJson(String json) =>
      CharacterTypeExtension.fromJson(json);

  static String _characterTypeToJson(CharacterType type) => type.toJson();
}

/// 친구 그룹 정보
@JsonSerializable()
class FriendGroupInfo {
  final int groupId; // 그룹 ID
  final String name; // 그룹 이름
  final List<FriendBriefInfo> friendsInGroup; // 그룹 내 친구 목록
  final int countFriend; // 친구 수

  FriendGroupInfo({
    required this.groupId,
    required this.name,
    required this.friendsInGroup,
    required this.countFriend,
  });

  factory FriendGroupInfo.fromJson(Map<String, dynamic> json) =>
      _$FriendGroupInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendGroupInfoToJson(this);
}

/// 내 친구 그룹 목록 응답
///
/// GET /api/members/groups
@JsonSerializable()
class MyFriendGroupsResponse {
  final List<FriendGroupInfo> friendGroups; // 친구 그룹 목록

  MyFriendGroupsResponse({
    required this.friendGroups,
  });

  factory MyFriendGroupsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyFriendGroupsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyFriendGroupsResponseToJson(this);

  /// 그룹 수
  int get groupCount => friendGroups.length;

  /// 그룹이 있는지 여부
  bool get hasGroups => friendGroups.isNotEmpty;
}

/// 친구 그룹 생성 요청
///
/// POST /api/members/groups
@JsonSerializable()
class GroupCreateRequest {
  final String name; // 그룹 이름 (blank 불가)
  final List<int> groupMemberIds; // 그룹 멤버 ID 목록 (최소 2명)

  GroupCreateRequest({
    required this.name,
    required this.groupMemberIds,
  });

  factory GroupCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$GroupCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GroupCreateRequestToJson(this);
}
