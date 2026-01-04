import 'package:dio/dio.dart';
import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/member/data/models/friend_info.dart';
import 'package:moit/features/member/data/models/friend_group.dart';

/// Friend API 클라이언트
class FriendClient {
  final DioClient _dioClient = DioClient();

  /// 친구 목록 조회
  ///
  /// GET /api/members/friendships
  ///
  /// 친구는 최소 한 번이라도 같은 모임에 참여한 사이가 자동으로 등록됩니다.
  /// Authorization 헤더에 Access Token 필요
  Future<MyFriendsResponse> getFriends() async {
    try {
      print('🌐 [FriendClient] GET /api/members/friendships');

      final response = await _dioClient.get('/api/members/friendships');

      print('🌐 [FriendClient] Response Status: ${response.statusCode}');
      print('🌐 [FriendClient] Response Data: ${response.data}');

      final friendsResponse = MyFriendsResponse.fromJson(response.data);

      print('✅ [FriendClient] 친구 ${friendsResponse.friendCount}명 조회 성공');
      for (var friend in friendsResponse.friends) {
        print('  - ${friend.nickname} (함께한 모임: ${friend.metCount}회)');
      }

      return friendsResponse;
    } catch (e, stackTrace) {
      print('❌ [FriendClient] getFriends 에러: $e');
      print('❌ [FriendClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [FriendClient] Status Code: ${e.response?.statusCode}');
        print('❌ [FriendClient] Response Data: ${e.response?.data}');
        print('❌ [FriendClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 친구 그룹 목록 조회
  ///
  /// GET /api/members/groups
  ///
  /// 자주 모이는 친구들을 그룹으로 묶어 관리할 수 있습니다.
  /// 그룹에 추가된 친구들에 대한 brief 정보를 제공합니다. (memberId, characterType)
  /// Authorization 헤더에 Access Token 필요
  Future<MyFriendGroupsResponse> getFriendGroups() async {
    try {
      print('🌐 [FriendClient] GET /api/members/groups');

      final response = await _dioClient.get('/api/members/groups');

      print('🌐 [FriendClient] Response Status: ${response.statusCode}');
      print('🌐 [FriendClient] Response Data: ${response.data}');

      final groupsResponse = MyFriendGroupsResponse.fromJson(response.data);

      print('✅ [FriendClient] 친구 그룹 ${groupsResponse.groupCount}개 조회 성공');
      for (var group in groupsResponse.friendGroups) {
        print('  - ${group.name} (${group.countFriend}명)');
      }

      return groupsResponse;
    } catch (e, stackTrace) {
      print('❌ [FriendClient] getFriendGroups 에러: $e');
      print('❌ [FriendClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [FriendClient] Status Code: ${e.response?.statusCode}');
        print('❌ [FriendClient] Response Data: ${e.response?.data}');
        print('❌ [FriendClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 친구 그룹 생성
  ///
  /// POST /api/members/groups
  ///
  /// 그룹 생성 요구사항:
  /// - name은 null & blank 불가능
  /// - 친구는 2명 이상이어야 등록됩니다.
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<void> createFriendGroup(GroupCreateRequest request) async {
    try {
      print('🌐 [FriendClient] POST /api/members/groups');
      print('  - name: ${request.name}');
      print('  - members: ${request.groupMemberIds.length}명');

      final response = await _dioClient.post(
        '/api/members/groups',
        data: request.toJson(),
      );

      print('🌐 [FriendClient] Response Status: ${response.statusCode}');
      print('✅ [FriendClient] 친구 그룹 생성 성공');
    } catch (e, stackTrace) {
      print('❌ [FriendClient] createFriendGroup 에러: $e');
      print('❌ [FriendClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [FriendClient] Status Code: ${e.response?.statusCode}');
        print('❌ [FriendClient] Response Data: ${e.response?.data}');
        print('❌ [FriendClient] Error Message: ${e.message}');

        // 400: 유효성 검증 실패 (그룹명 누락, 친구 2명 미만)
        if (e.response?.statusCode == 400) {
          print('⚠️ [FriendClient] 그룹명이 비어있거나 친구가 2명 미만입니다');
        }
      }

      rethrow;
    }
  }
}
