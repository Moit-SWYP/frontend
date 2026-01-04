import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/member/data/models/character_type.dart';

part 'friend_info.g.dart';

/// 친구 정보
///
/// GET /api/members/friendships 응답의 개별 친구 정보
@JsonSerializable()
class FriendInfo {
  final int memberId; // 회원 ID
  final String nickname; // 닉네임
  @JsonKey(fromJson: _characterTypeFromJson, toJson: _characterTypeToJson)
  final CharacterType characterType; // 캐릭터 타입
  final int metCount; // 함께한 모임 횟수

  FriendInfo({
    required this.memberId,
    required this.nickname,
    required this.characterType,
    required this.metCount,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) =>
      _$FriendInfoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendInfoToJson(this);

  /// CharacterType JSON 변환 헬퍼
  static CharacterType _characterTypeFromJson(String json) =>
      CharacterTypeExtension.fromJson(json);

  static String _characterTypeToJson(CharacterType type) => type.toJson();
}

/// 친구 목록 응답
///
/// GET /api/members/friendships
@JsonSerializable()
class MyFriendsResponse {
  final List<FriendInfo> friends; // 친구 목록

  MyFriendsResponse({
    required this.friends,
  });

  factory MyFriendsResponse.fromJson(Map<String, dynamic> json) =>
      _$MyFriendsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MyFriendsResponseToJson(this);

  /// 친구 수
  int get friendCount => friends.length;

  /// 친구가 있는지 여부
  bool get hasFriends => friends.isNotEmpty;
}
