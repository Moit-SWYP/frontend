import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/meeting/data/models/vote_summary_response.dart';

/// 투표 API 클라이언트
class VoteClient {
  final DioClient _dioClient = DioClient();

  /// 투표 요약 조회
  /// GET /api/meetings/{meetingId}/votes/summary
  Future<VoteSummaryResponse> getVoteSummary(int meetingId) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/summary');
      final response = await _dioClient.get('/api/meetings/$meetingId/votes/summary');

      print('✅ [VoteClient] 투표 요약 조회 성공');
      print('  - meetingStatus: ${response.data['data']['meetingStatus']}');
      print('  - isHost: ${response.data['data']['isHost']}');

      return VoteSummaryResponse.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getVoteSummary 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 날짜 투표
  /// POST /api/meetings/{meetingId}/votes/dates
  Future<void> voteDates(int meetingId, DateVoteRequest request) async {
    try {
      print('🌐 [VoteClient] POST /api/meetings/$meetingId/votes/dates');
      print('  - dates: ${request.dates}');

      await _dioClient.post(
        '/api/meetings/$meetingId/votes/dates',
        data: request.toJson(),
      );

      print('✅ [VoteClient] 날짜 투표 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] voteDates 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 내가 투표한 날짜 조회
  /// GET /api/meetings/{meetingId}/votes/dates
  Future<List<String>> getVotedDates(int meetingId) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/dates');
      final response = await _dioClient.get('/api/meetings/$meetingId/votes/dates');

      final dates = (response.data['data']['dates'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      print('✅ [VoteClient] 투표한 날짜 조회 성공: $dates');
      return dates;
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getVotedDates 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 상위 날짜 조회
  /// GET /api/meetings/{meetingId}/votes/dates/top?limit=3
  Future<List<String>> getTopDates(int meetingId, {int limit = 3}) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/dates/top?limit=$limit');
      final response = await _dioClient.get(
        '/api/meetings/$meetingId/votes/dates/top',
        queryParameters: {'limit': limit},
      );

      final dates = (response.data['data']['dates'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      print('✅ [VoteClient] 상위 날짜 조회 성공: $dates');
      return dates;
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getTopDates 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 특정 날짜 투표자 조회
  /// GET /api/meetings/{meetingId}/votes/dates/{date}/voters
  Future<VotersResponse> getDateVoters(int meetingId, String date) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/dates/$date/voters');
      final response = await _dioClient.get(
        '/api/meetings/$meetingId/votes/dates/$date/voters',
      );

      print('✅ [VoteClient] 날짜 투표자 조회 성공');
      return VotersResponse.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getDateVoters 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 날짜 확정 (자동 - 최다 득표)
  /// POST /api/meetings/{meetingId}/votes/date/confirm
  Future<void> confirmDate(int meetingId) async {
    try {
      print('🌐 [VoteClient] POST /api/meetings/$meetingId/votes/date/confirm');
      await _dioClient.post('/api/meetings/$meetingId/votes/date/confirm');
      print('✅ [VoteClient] 날짜 확정 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] confirmDate 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 날짜 수동 확정
  /// POST /api/meetings/{meetingId}/votes/date/confirm/manual?date=2025-12-20
  Future<void> confirmDateManual(int meetingId, String date) async {
    try {
      print('🌐 [VoteClient] POST /api/meetings/$meetingId/votes/date/confirm/manual?date=$date');
      await _dioClient.post(
        '/api/meetings/$meetingId/votes/date/confirm/manual',
        queryParameters: {'date': date},
      );
      print('✅ [VoteClient] 날짜 수동 확정 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] confirmDateManual 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 날짜 확정 취소
  /// DELETE /api/meetings/{meetingId}/votes/date/confirm
  Future<void> cancelDateConfirm(int meetingId) async {
    try {
      print('🌐 [VoteClient] DELETE /api/meetings/$meetingId/votes/date/confirm');
      await _dioClient.delete('/api/meetings/$meetingId/votes/date/confirm');
      print('✅ [VoteClient] 날짜 확정 취소 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] cancelDateConfirm 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 시간 투표
  /// POST /api/meetings/{meetingId}/votes/times
  Future<void> voteTimes(int meetingId, TimeVoteRequest request) async {
    try {
      final jsonData = request.toJson();
      print('🌐 [VoteClient] POST /api/meetings/$meetingId/votes/times');
      print('  - times: ${request.times}');
      print('  - JSON data: $jsonData');

      await _dioClient.post(
        '/api/meetings/$meetingId/votes/times',
        data: jsonData,
      );

      print('✅ [VoteClient] 시간 투표 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] voteTimes 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 내가 투표한 시간 조회
  /// GET /api/meetings/{meetingId}/votes/times
  Future<List<String>> getVotedTimes(int meetingId) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/times');
      final response = await _dioClient.get('/api/meetings/$meetingId/votes/times');

      final times = (response.data['data']['times'] as List<dynamic>)
          .map((e) => e['time'].toString())
          .toList();

      print('✅ [VoteClient] 투표한 시간 조회 성공: $times');
      return times;
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getVotedTimes 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 상위 시간 조회
  /// GET /api/meetings/{meetingId}/votes/times/top?limit=3
  Future<List<String>> getTopTimes(int meetingId, {int limit = 3}) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/times/top?limit=$limit');
      final response = await _dioClient.get(
        '/api/meetings/$meetingId/votes/times/top',
        queryParameters: {'limit': limit},
      );

      final times = (response.data['data']['time'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();

      print('✅ [VoteClient] 상위 시간 조회 성공: $times');
      return times;
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getTopTimes 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 특정 시간 투표자 조회
  /// GET /api/meetings/{meetingId}/votes/times/{time}/voters
  Future<VotersResponse> getTimeVoters(int meetingId, String time) async {
    try {
      print('🌐 [VoteClient] GET /api/meetings/$meetingId/votes/times/$time/voters');
      final response = await _dioClient.get(
        '/api/meetings/$meetingId/votes/times/$time/voters',
      );

      print('✅ [VoteClient] 시간 투표자 조회 성공');
      return VotersResponse.fromJson(response.data['data']);
    } catch (e, stackTrace) {
      print('❌ [VoteClient] getTimeVoters 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 시간 확정 (자동 - 최다 득표)
  /// POST /api/meetings/{meetingId}/votes/time/confirm
  Future<void> confirmTime(int meetingId) async {
    try {
      print('🌐 [VoteClient] POST /api/meetings/$meetingId/votes/time/confirm');
      await _dioClient.post('/api/meetings/$meetingId/votes/time/confirm');
      print('✅ [VoteClient] 시간 확정 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] confirmTime 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 시간 수동 확정
  /// POST /api/meetings/{meetingId}/votes/time/confirm/manual?time=15:00
  Future<void> confirmTimeManual(int meetingId, String time) async {
    try {
      print('🌐 [VoteClient] POST /api/meetings/$meetingId/votes/time/confirm/manual?time=$time');
      await _dioClient.post(
        '/api/meetings/$meetingId/votes/time/confirm/manual',
        queryParameters: {'time': time},
      );
      print('✅ [VoteClient] 시간 수동 확정 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] confirmTimeManual 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// 시간 확정 취소
  /// DELETE /api/meetings/{meetingId}/votes/time/confirm
  Future<void> cancelTimeConfirm(int meetingId) async {
    try {
      print('🌐 [VoteClient] DELETE /api/meetings/$meetingId/votes/time/confirm');
      await _dioClient.delete('/api/meetings/$meetingId/votes/time/confirm');
      print('✅ [VoteClient] 시간 확정 취소 성공');
    } catch (e, stackTrace) {
      print('❌ [VoteClient] cancelTimeConfirm 에러: $e');
      print('❌ [VoteClient] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
