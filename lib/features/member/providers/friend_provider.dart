import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/member/data/clients/friend_client.dart';
import 'package:moit/features/member/data/models/friend_info.dart';
import 'package:moit/features/member/data/models/friend_group.dart';

/// Friend 상태
class FriendState {
  final List<FriendInfo> friends; // 친구 목록
  final List<FriendGroupInfo> groups; // 친구 그룹 목록
  final bool isLoading; // 로딩 상태
  final String? errorMessage; // 에러 메시지

  const FriendState({
    this.friends = const [],
    this.groups = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FriendState copyWith({
    List<FriendInfo>? friends,
    List<FriendGroupInfo>? groups,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FriendState(
      friends: friends ?? this.friends,
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 친구 수
  int get friendCount => friends.length;

  /// 친구가 있는지 여부
  bool get hasFriends => friends.isNotEmpty;

  /// 그룹 수
  int get groupCount => groups.length;

  /// 그룹이 있는지 여부
  bool get hasGroups => groups.isNotEmpty;
}

/// Friend Provider
final friendProvider = StateNotifierProvider<FriendNotifier, FriendState>((ref) {
  return FriendNotifier();
});

/// Friend StateNotifier
class FriendNotifier extends StateNotifier<FriendState> {
  FriendNotifier() : super(const FriendState());

  final FriendClient _friendClient = FriendClient();

  /// 친구 목록 조회
  Future<void> loadFriends() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (state.isLoading) {
      print('⚠️ [Friend] 이미 로딩 중입니다.');
      return;
    }

    print('🔄 [Friend] 친구 목록 로드 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _friendClient.getFriends();

      print('✅ [Friend] 친구 ${response.friendCount}명 로드 성공');
      for (var friend in response.friends) {
        print('  - ${friend.nickname} (함께한 모임: ${friend.metCount}회)');
      }

      state = state.copyWith(
        friends: response.friends,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      print('❌ [Friend] 친구 목록 로드 실패: $e');
      print('❌ [Friend] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '친구 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 친구 그룹 목록 조회
  Future<void> loadFriendGroups() async {
    print('🔄 [Friend] 친구 그룹 목록 로드 시작');

    try {
      final response = await _friendClient.getFriendGroups();

      print('✅ [Friend] 친구 그룹 ${response.groupCount}개 로드 성공');
      for (var group in response.friendGroups) {
        print('  - ${group.name} (${group.countFriend}명)');
      }

      state = state.copyWith(
        groups: response.friendGroups,
      );
    } catch (e, stackTrace) {
      print('❌ [Friend] 친구 그룹 목록 로드 실패: $e');
      print('❌ [Friend] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '친구 그룹 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 친구 그룹 생성
  Future<bool> createFriendGroup(String name, List<int> memberIds) async {
    print('🔄 [Friend] 친구 그룹 생성 시작: $name');
    print('  - 멤버: ${memberIds.length}명');

    try {
      final request = GroupCreateRequest(
        name: name,
        groupMemberIds: memberIds,
      );

      await _friendClient.createFriendGroup(request);

      print('✅ [Friend] 친구 그룹 생성 성공');

      // 생성 후 그룹 목록 새로고침
      await loadFriendGroups();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Friend] 친구 그룹 생성 실패: $e');
      print('❌ [Friend] StackTrace: $stackTrace');

      String errorMessage = '친구 그룹 생성에 실패했습니다.';
      if (e is DioException && e.response?.statusCode == 400) {
        errorMessage = '그룹명이 비어있거나 친구가 2명 미만입니다.';
      }

      state = state.copyWith(errorMessage: errorMessage);

      return false;
    }
  }

  /// 친구와 함께한 모임 횟수로 정렬된 친구 목록
  List<FriendInfo> get friendsSortedByMetCount {
    final sortedList = [...state.friends];
    sortedList.sort((a, b) => b.metCount.compareTo(a.metCount));
    return sortedList;
  }

  /// 특정 캐릭터 타입의 친구 필터링
  List<FriendInfo> getFriendsByCharacterType(String characterType) {
    return state.friends
        .where((friend) => friend.characterType.name == characterType)
        .toList();
  }

  /// 특정 그룹의 친구 목록
  List<FriendBriefInfo>? getFriendsInGroup(int groupId) {
    final group = state.groups.firstWhere(
      (g) => g.groupId == groupId,
      orElse: () => FriendGroupInfo(
        groupId: -1,
        name: '',
        friendsInGroup: [],
        countFriend: 0,
      ),
    );

    return group.groupId == -1 ? null : group.friendsInGroup;
  }

  /// 에러 메시지 클리어
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// 친구 정보 초기화 (로그아웃 시 사용)
  void clearFriends() {
    print('🔄 [Friend] 친구 정보 초기화');
    state = const FriendState();
  }
}
