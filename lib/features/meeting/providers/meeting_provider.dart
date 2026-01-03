import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/meeting/data/clients/meeting_client.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/data/models/meeting_create_request.dart';

/// Meeting 리스트 상태
class MeetingState {
  final List<MeetingBrief> meetings;
  final bool isLoading;
  final String? errorMessage;

  const MeetingState({
    this.meetings = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  MeetingState copyWith({
    List<MeetingBrief>? meetings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MeetingState(
      meetings: meetings ?? this.meetings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 모임이 비어있는지 확인
  bool get isEmpty => meetings.isEmpty;

  /// 모임 개수
  int get count => meetings.length;
}

/// Meeting Provider
final meetingProvider =
    StateNotifierProvider<MeetingNotifier, MeetingState>((ref) {
  return MeetingNotifier();
});

/// Meeting StateNotifier
class MeetingNotifier extends StateNotifier<MeetingState> {
  MeetingNotifier() : super(const MeetingState());

  final MeetingClient _meetingClient = MeetingClient();

  /// 모임 리스트 조회
  Future<void> loadMeetings() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (state.isLoading) {
      print('⚠️ [Meeting] 이미 로딩 중입니다.');
      return;
    }

    print('🔄 [Meeting] 모임 리스트 로드 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final meetings = await _meetingClient.getAllMeetings();

      print('✅ [Meeting] 모임 ${meetings.length}개 로드 성공');
      for (var meeting in meetings) {
        print('  - ${meeting.title} (${meeting.statusText})');
      }

      state = state.copyWith(
        meetings: meetings,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 리스트 로드 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '모임 목록을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 모임 생성
  Future<bool> createMeeting(MeetingCreateRequest request) async {
    print('🔄 [Meeting] 모임 생성 시작: ${request.title}');

    try {
      await _meetingClient.createMeeting(request);

      print('✅ [Meeting] 모임 생성 성공');

      // 생성 후 리스트 새로고침
      await loadMeetings();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 생성 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '모임 생성에 실패했습니다.',
      );

      return false;
    }
  }

  /// 모임 상세 조회
  Future<MeetingBrief?> getMeetingDetail(int meetingId) async {
    print('🔄 [Meeting] 모임 상세 조회: $meetingId');

    try {
      final meeting = await _meetingClient.getMeetingById(meetingId);

      if (meeting != null) {
        print('✅ [Meeting] 모임 상세 조회 성공: ${meeting.title}');
      } else {
        print('⚠️ [Meeting] 모임을 찾을 수 없습니다: $meetingId');
      }

      return meeting;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 상세 조회 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');
      return null;
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// 모임 리스트 초기화 (로그아웃 시 사용)
  void clearMeetings() {
    print('🔄 [Meeting] 모임 리스트 초기화');
    state = const MeetingState();
  }
}
