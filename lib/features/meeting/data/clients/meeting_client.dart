import 'package:dio/dio.dart';
import 'package:moit/core/models/api_response.dart';
import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/data/models/meeting_create_request.dart';

/// Meeting API 클라이언트
class MeetingClient {
  final DioClient _dioClient = DioClient();

  /// 전체 모임 리스트 조회
  ///
  /// GET /api/meetings/all
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<List<MeetingBrief>> getAllMeetings() async {
    try {
      print('🌐 [MeetingClient] GET /api/meetings/all');

      final response = await _dioClient.get('/api/meetings/all');

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');

      // 응답이 배열인 경우
      if (response.data is List) {
        final meetings = (response.data as List)
            .map((json) => MeetingBrief.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [MeetingClient] 모임 ${meetings.length}개 조회 성공');
        return meetings;
      }

      print('❌ [MeetingClient] 예상치 못한 응답 형식');
      return [];
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] getAllMeetings 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 모임 생성
  ///
  /// POST /api/meetings
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<void> createMeeting(MeetingCreateRequest request) async {
    try {
      print('🌐 [MeetingClient] POST /api/meetings');
      print('🌐 [MeetingClient] Request Data: ${request.toJson()}');

      final response = await _dioClient.post(
        '/api/meetings',
        data: request.toJson(),
      );

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');
      print('✅ [MeetingClient] 모임 생성 성공');
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] createMeeting 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 모임 상세 조회
  ///
  /// GET /api/meetings/{id}
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<MeetingBrief?> getMeetingById(int meetingId) async {
    try {
      print('🌐 [MeetingClient] GET /api/meetings/$meetingId');

      final response = await _dioClient.get('/api/meetings/$meetingId');

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');

      // TODO: 실제 응답 구조에 맞게 수정 필요
      final meeting = MeetingBrief.fromJson(response.data as Map<String, dynamic>);

      print('✅ [MeetingClient] 모임 상세 조회 성공');
      return meeting;
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] getMeetingById 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      return null;
    }
  }
}
