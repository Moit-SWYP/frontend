import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/meeting/data/clients/meeting_client.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/data/models/meeting_create_request.dart';
import 'package:moit/features/meeting/data/models/meeting_update_request.dart';

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
  ///
  /// 생성된 모임의 ID를 반환합니다.
  /// 서버 응답에서 ID를 받지 못한 경우, 목록을 다시 불러와서 방금 생성된 모임의 ID를 찾아 반환합니다.
  Future<int?> createMeeting(MeetingCreateRequest request) async {
    print('');
    print('══════════════════════════════════════════════════');
    print('🎯 [MeetingProvider] 모임 생성 프로세스 시작: ${request.title}');
    print('══════════════════════════════════════════════════');

    try {
      print('📤 [MeetingProvider] 1단계: POST 요청 호출 (createMeeting)');
      final meetingId = await _meetingClient.createMeeting(request);

      // 응답에서 ID를 받은 경우
      if (meetingId != null) {
        print('✅ [MeetingProvider] 2단계: POST 성공 - meetingId: $meetingId');
        print('📥 [MeetingProvider] 3단계: 목록 새로고침 호출 (loadMeetings)');

        // 생성 후 리스트 새로고침
        await loadMeetings();

        print('✅ [MeetingProvider] 모임 생성 프로세스 완료');
        print('══════════════════════════════════════════════════');
        print('');
        return meetingId;
      }

      // 응답에서 ID를 받지 못한 경우 - 목록에서 찾기
      print('⚠️ [MeetingProvider] 2단계: POST 성공했으나 응답에 ID 없음');
      print('📥 [MeetingProvider] 3단계: 목록 새로고침하여 방금 생성된 모임 찾기');

      // 생성 후 리스트 새로고침
      await loadMeetings();

      // 방법 1: 제목으로 찾기 (가장 확실)
      final createdMeeting = state.meetings.firstWhere(
        (meeting) => meeting.title == request.title,
        orElse: () => state.meetings.isNotEmpty
            ? state.meetings.first // 제목이 일치하는 게 없으면 가장 첫 번째 (최신) 모임
            : throw Exception('생성된 모임을 찾을 수 없습니다.'),
      );

      print('✅ [MeetingProvider] 방금 생성된 모임 발견!');
      print('   - meetingId: ${createdMeeting.meetingId}');
      print('   - title: ${createdMeeting.title}');
      print('   - 전체 모임 개수: ${state.meetings.length}개');
      print('✅ [MeetingProvider] 모임 생성 프로세스 완료');
      print('══════════════════════════════════════════════════');
      print('');

      return createdMeeting.meetingId;
    } catch (e, stackTrace) {
      print('❌ [MeetingProvider] 모임 생성 실패: $e');
      print('❌ [MeetingProvider] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '모임 생성에 실패했습니다.',
      );

      print('══════════════════════════════════════════════════');
      print('');
      return null;
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

  /// 모임 삭제 (HOST 전용)
  Future<bool> deleteMeeting(int meetingId) async {
    print('🔄 [Meeting] 모임 삭제 시작: $meetingId');

    try {
      await _meetingClient.deleteMeeting(meetingId);

      print('✅ [Meeting] 모임 삭제 성공');

      // 삭제 후 리스트 새로고침
      await loadMeetings();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 삭제 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '모임 삭제에 실패했습니다.',
      );

      return false;
    }
  }

  /// 모임 탈퇴 (MEMBER 전용)
  Future<bool> quitMeeting(int meetingId) async {
    print('🔄 [Meeting] 모임 탈퇴 시작: $meetingId');

    try {
      await _meetingClient.quitMeeting(meetingId);

      print('✅ [Meeting] 모임 탈퇴 성공');

      // 탈퇴 후 리스트 새로고침
      await loadMeetings();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 탈퇴 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '모임 탈퇴에 실패했습니다.',
      );

      return false;
    }
  }

  /// 초대 링크 생성 및 조회
  Future<String?> getInvitationLink(int meetingId) async {
    print('🔄 [Meeting] 초대 링크 생성: $meetingId');

    try {
      final invitationResponse = await _meetingClient.getInvitationLink(meetingId);

      print('✅ [Meeting] 초대 링크 생성 성공');
      print('  - inviteToken: ${invitationResponse.inviteToken}');
      print('  - inviteLink: ${invitationResponse.inviteLink}');

      return invitationResponse.inviteLink;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 초대 링크 생성 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '초대 링크 생성에 실패했습니다.',
      );

      return null;
    }
  }

  /// 초대 링크로 모임 참여
  Future<bool> joinMeetingFromLink(String inviteToken) async {
    print('🔄 [Meeting] 초대 링크로 모임 참여: $inviteToken');

    try {
      await _meetingClient.joinMeetingFromLink(inviteToken);

      print('✅ [Meeting] 모임 참여 성공');

      // 참여 후 리스트 새로고침
      await loadMeetings();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 참여 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      // 에러 메시지 설정
      String errorMessage = '모임 참여에 실패했습니다.';
      if (e is DioException) {
        if (e.response?.statusCode == 409) {
          errorMessage = '이미 참여중인 모임입니다.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = '존재하지 않는 모임입니다.';
        }
      }

      state = state.copyWith(errorMessage: errorMessage);

      return false;
    }
  }

  /// 대기 모임 리스트 조회
  Future<List<MeetingBrief>> getWaitingMeetings({
    int page = 0,
    int size = 20,
  }) async {
    print('🔄 [Meeting] 대기 모임 리스트 조회: page=$page, size=$size');

    try {
      final meetings = await _meetingClient.getWaitingMeetings(
        page: page,
        size: size,
      );

      print('✅ [Meeting] 대기 모임 ${meetings.length}개 조회 성공');
      for (var meeting in meetings) {
        print('  - ${meeting.title} (${meeting.statusText})');
      }

      return meetings;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 대기 모임 조회 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '대기 모임 목록을 불러오는데 실패했습니다.',
      );

      return [];
    }
  }

  /// 모임 수정
  Future<bool> updateMeeting(int meetingId, MeetingUpdateRequest request) async {
    print('🔄 [Meeting] 모임 수정 시작: $meetingId');

    try {
      await _meetingClient.updateMeeting(meetingId, request);

      print('✅ [Meeting] 모임 수정 성공');

      // 수정 후 리스트 새로고침
      await loadMeetings();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 수정 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '모임 수정에 실패했습니다.',
      );

      return false;
    }
  }

  /// 모임 날짜 확정 (HOST 전용)
  Future<bool> confirmMeeting(int meetingId) async {
    print('🔄 [Meeting] 모임 날짜 확정 시작: $meetingId');

    try {
      await _meetingClient.confirmMeeting(meetingId);

      print('✅ [Meeting] 모임 날짜 확정 성공');

      // 확정 후 리스트 새로고침
      await loadMeetings();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Meeting] 모임 날짜 확정 실패: $e');
      print('❌ [Meeting] StackTrace: $stackTrace');

      // 에러 메시지 설정
      String errorMessage = '날짜 확정에 실패했습니다.';
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          errorMessage = '호스트만 날짜를 확정할 수 있습니다.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = '투표 데이터가 없거나 모임 상태가 올바르지 않습니다.';
        }
      }

      state = state.copyWith(errorMessage: errorMessage);

      return false;
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
