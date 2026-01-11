import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/meeting/data/clients/vote_client.dart';
import 'package:moit/features/meeting/data/models/vote_summary_response.dart';

/// 투표 상태
class VoteState {
  final VoteSummaryResponse? summary;
  final bool isLoading;
  final String? errorMessage;

  const VoteState({
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  VoteState copyWith({
    VoteSummaryResponse? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return VoteState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 날짜 투표 진행 중인지
  bool get isDateVoting => summary?.isDateVoting ?? false;

  /// 시간 투표 진행 중인지
  bool get isTimeVoting => summary?.isTimeVoting ?? false;

  /// 확정 완료되었는지
  bool get isFixed => summary?.isFixed ?? false;

  /// 현재 사용자가 호스트인지
  bool get isHost => summary?.isHost ?? false;

  /// 내가 날짜 투표를 했는지
  bool get hasVotedDate => summary?.hasVotedDate ?? false;

  /// 내가 시간 투표를 했는지
  bool get hasVotedTime => summary?.hasVotedTime ?? false;
}

/// 투표 Provider
final voteProvider = StateNotifierProvider.family<VoteNotifier, VoteState, int>(
  (ref, meetingId) => VoteNotifier(meetingId: meetingId),
);

/// 투표 상태 관리 Notifier
class VoteNotifier extends StateNotifier<VoteState> {
  VoteNotifier({required this.meetingId}) : super(const VoteState());

  final int meetingId;
  final VoteClient _voteClient = VoteClient();

  /// 투표 요약 로드
  Future<void> loadVoteSummary() async {
    print('🔍 [Vote] loadVoteSummary() 진입: isLoading=${state.isLoading}');

    if (state.isLoading) {
      print('⚠️ [Vote] 이미 로딩 중입니다. (early return)');
      return;
    }

    print('🔄 [Vote] 투표 요약 로드 시작 (meetingId: $meetingId)');
    print('  - isLoading을 true로 설정');
    state = state.copyWith(isLoading: true, errorMessage: null);
    print('  - 현재 isLoading: ${state.isLoading}');

    try {
      print('🌐 [Vote] API 호출 시작: getVoteSummary($meetingId)');
      final summary = await _voteClient.getVoteSummary(meetingId);

      print('✅ [Vote] 투표 요약 로드 API 성공');
      print('  - meetingStatus: ${summary.meetingStatus}');
      print('  - isHost: ${summary.isHost}');
      print('  - confirmedDate: ${summary.confirmedDate}');
      print('  - confirmedTime: ${summary.confirmedTime}');

      print('  - isLoading을 false로 설정');
      state = state.copyWith(
        summary: summary,
        isLoading: false,
      );
      print('  - 최종 isLoading: ${state.isLoading}');
    } catch (e, stackTrace) {
      print('❌ [Vote] 투표 요약 로드 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      print('  - 에러 후 isLoading을 false로 설정');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '투표 정보를 불러오는데 실패했습니다.',
      );
      print('  - 에러 후 isLoading: ${state.isLoading}');
    }
  }

  /// 날짜 투표
  Future<bool> voteDates(List<String> dates) async {
    print('🔄 [Vote] 날짜 투표 시작');
    print('  - meetingId: $meetingId');
    print('  - dates: $dates');

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = DateVoteRequest(dates: dates);
      await _voteClient.voteDates(meetingId, request);

      print('✅ [Vote] 날짜 투표 API 성공');

      // ✨ 중요: loadVoteSummary 호출 전 isLoading 해제
      print('  - isLoading을 false로 설정 (loadVoteSummary 호출 전)');
      state = state.copyWith(isLoading: false);
      print('  - 현재 isLoading: ${state.isLoading}');

      // 투표 후 요약 다시 로드
      print('🔄 [Vote] loadVoteSummary() 호출');
      await loadVoteSummary();
      print('✅ [Vote] loadVoteSummary() 완료');

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 날짜 투표 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '날짜 투표에 실패했습니다.',
      );

      return false;
    }
  }

  /// 시간 투표
  Future<TimeSummary?> voteTimes(List<String> times) async {
    print('🔄 [Vote] 시간 투표 시작');
    print('  - meetingId: $meetingId');
    print('  - times: $times');

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final request = TimeVoteRequest(times: times);
      await _voteClient.voteTimes(meetingId, request);

      print('✅ [Vote] 시간 투표 API 성공');

      // ✨ 중요: loadVoteSummary 호출 전 isLoading 해제
      print('  - isLoading을 false로 설정 (loadVoteSummary 호출 전)');
      state = state.copyWith(isLoading: false);
      print('  - 현재 isLoading: ${state.isLoading}');

      // 투표 후 요약 다시 로드
      print('🔄 [Vote] loadVoteSummary() 호출');
      await loadVoteSummary();
      print('✅ [Vote] loadVoteSummary() 완료');

      // ✅ 변경: timeSummary 반환
      final timeSummary = state.summary?.timeSummary;
      print('  - 반환할 timeSummary: ${timeSummary != null ? "${timeSummary.votedTimes.length}개 시간" : "null"}');
      return timeSummary;
    } catch (e, stackTrace) {
      print('❌ [Vote] 시간 투표 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '시간 투표에 실패했습니다.',
      );

      return null;
    }
  }

  /// 날짜 확정 (자동 - 최다 득표)
  Future<bool> confirmDate() async {
    print('🔍 [Vote] confirmDate() 진입: isLoading=${state.isLoading}, isHost=${state.isHost}');

    if (!state.isHost) {
      print('⚠️ [Vote] 호스트만 확정할 수 있습니다.');
      state = state.copyWith(errorMessage: '호스트만 날짜를 확정할 수 있습니다.');
      return false;
    }

    print('🔄 [Vote] 날짜 확정 시작 (자동)');
    print('  - isLoading을 true로 설정');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('🌐 [Vote] API 호출 시작: confirmDate($meetingId)');
      await _voteClient.confirmDate(meetingId);
      print('✅ [Vote] 날짜 확정 API 성공');

      // ✨ 변경: loadVoteSummary 호출 전 isLoading 해제
      print('  - isLoading을 false로 설정 (loadVoteSummary 호출 전)');
      state = state.copyWith(isLoading: false);
      print('  - 현재 isLoading: ${state.isLoading}');

      // 확정 후 요약 다시 로드
      print('🔄 [Vote] loadVoteSummary() 호출');
      await loadVoteSummary();
      print('✅ [Vote] loadVoteSummary() 완료');
      print('  - 최종 isLoading: ${state.isLoading}');

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 날짜 확정 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '날짜 확정에 실패했습니다.',
      );
      print('  - 에러 후 isLoading: ${state.isLoading}');

      return false;
    }
  }

  /// 날짜 수동 확정
  Future<bool> confirmDateManual(String date) async {
    if (!state.isHost) {
      print('⚠️ [Vote] 호스트만 확정할 수 있습니다.');
      state = state.copyWith(errorMessage: '호스트만 날짜를 확정할 수 있습니다.');
      return false;
    }

    print('🔄 [Vote] 날짜 수동 확정 시작: $date');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _voteClient.confirmDateManual(meetingId, date);
      print('✅ [Vote] 날짜 수동 확정 성공');

      // 확정 후 요약 다시 로드
      await loadVoteSummary();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 날짜 수동 확정 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '날짜 확정에 실패했습니다.',
      );

      return false;
    }
  }

  /// 시간 확정 (자동 - 최다 득표)
  Future<bool> confirmTime() async {
    if (!state.isHost) {
      print('⚠️ [Vote] 호스트만 확정할 수 있습니다.');
      state = state.copyWith(errorMessage: '호스트만 시간을 확정할 수 있습니다.');
      return false;
    }

    print('🔄 [Vote] 시간 확정 시작 (자동)');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _voteClient.confirmTime(meetingId);
      print('✅ [Vote] 시간 확정 성공');

      // 확정 후 요약 다시 로드
      await loadVoteSummary();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 시간 확정 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '시간 확정에 실패했습니다.',
      );

      return false;
    }
  }

  /// 시간 수동 확정
  Future<bool> confirmTimeManual(String time) async {
    if (!state.isHost) {
      print('⚠️ [Vote] 호스트만 확정할 수 있습니다.');
      state = state.copyWith(errorMessage: '호스트만 시간을 확정할 수 있습니다.');
      return false;
    }

    print('🔄 [Vote] 시간 수동 확정 시작: $time');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _voteClient.confirmTimeManual(meetingId, time);
      print('✅ [Vote] 시간 수동 확정 성공');

      // 확정 후 요약 다시 로드
      await loadVoteSummary();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 시간 수동 확정 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '시간 확정에 실패했습니다.',
      );

      return false;
    }
  }

  /// 특정 날짜 투표자 조회
  Future<VotersResponse?> getDateVoters(String date) async {
    try {
      print('🔄 [Vote] 날짜 투표자 조회: $date');
      final voters = await _voteClient.getDateVoters(meetingId, date);
      print('✅ [Vote] 날짜 투표자 조회 성공: ${voters.voterCount}명');
      return voters;
    } catch (e) {
      print('❌ [Vote] 날짜 투표자 조회 실패: $e');
      return null;
    }
  }

  /// 특정 시간 투표자 조회
  Future<VotersResponse?> getTimeVoters(String time) async {
    try {
      print('🔄 [Vote] 시간 투표자 조회: $time');
      final voters = await _voteClient.getTimeVoters(meetingId, time);
      print('✅ [Vote] 시간 투표자 조회 성공: ${voters.voterCount}명');
      return voters;
    } catch (e) {
      print('❌ [Vote] 시간 투표자 조회 실패: $e');
      return null;
    }
  }

  /// 날짜 확정 취소
  Future<bool> cancelDateConfirm() async {
    if (!state.isHost) {
      print('⚠️ [Vote] 호스트만 확정을 취소할 수 있습니다.');
      state = state.copyWith(errorMessage: '호스트만 날짜 확정을 취소할 수 있습니다.');
      return false;
    }

    print('🔄 [Vote] 날짜 확정 취소 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _voteClient.cancelDateConfirm(meetingId);
      print('✅ [Vote] 날짜 확정 취소 성공');

      // 확정 취소 후 요약 다시 로드
      await loadVoteSummary();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 날짜 확정 취소 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '날짜 확정 취소에 실패했습니다.',
      );

      return false;
    }
  }

  /// 시간 확정 취소
  Future<bool> cancelTimeConfirm() async {
    if (!state.isHost) {
      print('⚠️ [Vote] 호스트만 확정을 취소할 수 있습니다.');
      state = state.copyWith(errorMessage: '호스트만 시간 확정을 취소할 수 있습니다.');
      return false;
    }

    print('🔄 [Vote] 시간 확정 취소 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _voteClient.cancelTimeConfirm(meetingId);
      print('✅ [Vote] 시간 확정 취소 성공');

      // 확정 취소 후 요약 다시 로드
      await loadVoteSummary();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Vote] 시간 확정 취소 실패: $e');
      print('❌ [Vote] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '시간 확정 취소에 실패했습니다.',
      );

      return false;
    }
  }

  /// 모든 투표된 날짜 조회 (limit 크게 설정)
  Future<List<String>> getAllVotedDates() async {
    try {
      print('🔄 [Vote] 모든 투표된 날짜 조회');
      // limit을 100으로 설정하여 모든 투표 날짜 가져오기
      final dates = await _voteClient.getTopDates(meetingId, limit: 100);
      print('✅ [Vote] 모든 투표된 날짜 조회 성공: ${dates.length}개');
      return dates;
    } catch (e) {
      print('❌ [Vote] 모든 투표된 날짜 조회 실패: $e');
      return [];
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
