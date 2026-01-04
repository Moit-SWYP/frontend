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
