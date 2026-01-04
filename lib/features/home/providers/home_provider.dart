import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/home/data/clients/home_client.dart';
import 'package:moit/features/home/data/models/home_response.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';

/// Home 데이터 상태
class HomeState {
  final HomeResponse? homeData;
  final bool isLoading;
  final String? errorMessage;

  const HomeState({
    this.homeData,
    this.isLoading = false,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeResponse? homeData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeState(
      homeData: homeData ?? this.homeData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 홈 모임이 있는지
  bool get hasHomeMeetings => homeData?.hasHomeMeetings ?? false;

  /// 대기 중인 모임이 있는지
  bool get hasWaitingMeetings => homeData?.hasWaitingMeetings ?? false;

  /// 전체 모임 개수
  int get totalMeetingCount => homeData?.totalMeetingCount ?? 0;

  /// 우선순위에 따른 동적 메시지 반환
  String get topMessage {
    if (homeData == null) return '모임을 만들어볼까요?';

    final allMeetings = homeData!.homeMeetings;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // 1순위: 오늘 확정된 모임이 있는지 확인
    final todayMeeting = allMeetings.where((meeting) {
      if (meeting.date == null || meeting.status != MeetingStatus.fixed) {
        return false;
      }

      try {
        final meetingDate = DateTime.parse(meeting.date!);
        final meetingMidnight = DateTime(meetingDate.year, meetingDate.month, meetingDate.day);
        return meetingMidnight.isAtSameMomentAs(todayMidnight);
      } catch (e) {
        return false;
      }
    }).toList();

    if (todayMeeting.isNotEmpty) {
      return '오늘은 모임이 있어요';
    }

    // 2순위: 진행 중인 투표가 있는지 확인 (가장 먼저 생성된 것 기준)
    final votingMeetings = allMeetings.where((meeting) {
      return meeting.status == MeetingStatus.dateVoting ||
          meeting.status == MeetingStatus.timeVoting ||
          meeting.status == MeetingStatus.placeVoting ||
          meeting.status == MeetingStatus.created;
    }).toList();

    if (votingMeetings.isNotEmpty) {
      // 가장 먼저 생성된 것 (meetingId가 가장 작은 것으로 추정)
      final firstVotingMeeting = votingMeetings.reduce((a, b) =>
        a.meetingId < b.meetingId ? a : b
      );
      return '${firstVotingMeeting.title}에 대해 친구들이 이야기하고 있어요';
    }

    // 3순위: 7일 이내 확정된 모임이 있는지 확인 (가장 가까운 날짜 기준)
    final upcomingMeetings = allMeetings.where((meeting) {
      if (meeting.date == null || meeting.status != MeetingStatus.fixed) {
        return false;
      }

      try {
        final meetingDate = DateTime.parse(meeting.date!);
        final meetingMidnight = DateTime(meetingDate.year, meetingDate.month, meetingDate.day);
        final daysUntil = meetingMidnight.difference(todayMidnight).inDays;

        // 오늘 이후 7일 이내
        return daysUntil > 0 && daysUntil <= 7;
      } catch (e) {
        return false;
      }
    }).toList();

    if (upcomingMeetings.isNotEmpty) {
      return '곧 모임이 있어요';
    }

    // 4순위: 기본 메시지
    return '모임을 만들어볼까요?';
  }
}

/// Home Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

/// Home StateNotifier
class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  final HomeClient _homeClient = HomeClient();

  /// 홈 데이터 로드
  Future<void> loadHomeData() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (state.isLoading) {
      print('⚠️ [Home] 이미 로딩 중입니다.');
      return;
    }

    print('🔄 [Home] 홈 데이터 로드 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final homeData = await _homeClient.getHomeData();

      print('✅ [Home] 홈 데이터 로드 성공');
      print('  - 홈 모임: ${homeData.homeMeetings.length}개');
      print('  - 대기 모임: ${homeData.waitingMeetings.length}개');

      state = state.copyWith(
        homeData: homeData,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      print('❌ [Home] 홈 데이터 로드 실패: $e');
      print('❌ [Home] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '홈 데이터를 불러오는데 실패했습니다.',
      );
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// 홈 데이터 초기화 (로그아웃 시 사용)
  void clearHomeData() {
    print('🔄 [Home] 홈 데이터 초기화');
    state = const HomeState();
  }
}
