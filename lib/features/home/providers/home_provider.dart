import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/home/data/clients/home_client.dart';
import 'package:moit/features/home/data/models/home_response.dart';

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
