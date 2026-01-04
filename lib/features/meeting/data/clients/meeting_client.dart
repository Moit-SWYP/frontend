import 'package:dio/dio.dart';
import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/data/models/meeting_create_request.dart';
import 'package:moit/features/meeting/data/models/meeting_update_request.dart';
import 'package:moit/features/meeting/data/models/invitation_response.dart';

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

  /// 모임 삭제 (HOST 전용)
  ///
  /// DELETE /api/meetings/{id}
  ///
  /// 해당 모임의 HOST만 정상 처리
  /// Authorization 헤더에 Access Token 필요
  Future<void> deleteMeeting(int meetingId) async {
    try {
      print('🌐 [MeetingClient] DELETE /api/meetings/$meetingId');

      final response = await _dioClient.delete('/api/meetings/$meetingId');

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('✅ [MeetingClient] 모임 삭제 성공');
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] deleteMeeting 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 모임 탈퇴 (MEMBER 전용)
  ///
  /// DELETE /api/meetings/quit/{id}
  ///
  /// 해당 모임의 MEMBER만 정상 처리
  /// Authorization 헤더에 Access Token 필요
  Future<void> quitMeeting(int meetingId) async {
    try {
      print('🌐 [MeetingClient] DELETE /api/meetings/quit/$meetingId');

      final response = await _dioClient.delete('/api/meetings/quit/$meetingId');

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('✅ [MeetingClient] 모임 탈퇴 성공');
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] quitMeeting 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 초대 링크 생성 및 토큰 조회
  ///
  /// GET /api/meetings/{meetingId}/invitations/link
  ///
  /// Meeting의 UUID 형태의 public_id를 반환
  /// Authorization 헤더에 Access Token 필요
  Future<InvitationResponse> getInvitationLink(int meetingId) async {
    try {
      print('🌐 [MeetingClient] GET /api/meetings/$meetingId/invitations/link');

      final response = await _dioClient.get('/api/meetings/$meetingId/invitations/link');

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');

      final invitationResponse = InvitationResponse.fromJson(response.data['data']);

      print('✅ [MeetingClient] 초대 링크 조회 성공');
      print('  - meetingId: ${invitationResponse.meetingId}');
      print('  - inviteToken: ${invitationResponse.inviteToken}');

      return invitationResponse;
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] getInvitationLink 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 초대 링크로 모임 참여
  ///
  /// POST /api/meetings/invitations/join?inviteToken={token}
  ///
  /// String 형태의 토큰을 UUID로 변환하고 해당 meeting에 참여
  /// 이미 참여중이거나 유효하지 않은 meeting이면 에러 반환
  /// Authorization 헤더에 Access Token 필요
  Future<void> joinMeetingFromLink(String inviteToken) async {
    try {
      print('🌐 [MeetingClient] POST /api/meetings/invitations/join?inviteToken=$inviteToken');

      final response = await _dioClient.post(
        '/api/meetings/invitations/join',
        queryParameters: {'inviteToken': inviteToken},
      );

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('✅ [MeetingClient] 모임 참여 성공');
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] joinMeetingFromLink 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');

        // 409: 이미 참여중인 모임
        if (e.response?.statusCode == 409) {
          print('⚠️ [MeetingClient] 이미 참여중인 모임입니다');
        }
        // 404: 모임을 찾을 수 없음
        else if (e.response?.statusCode == 404) {
          print('⚠️ [MeetingClient] 존재하지 않는 모임입니다');
        }
      }

      rethrow;
    }
  }

  /// 대기 모임 리스트 조회
  ///
  /// GET /api/meetings/waiting
  ///
  /// '친구가 기다려요' - 아직 보내기 전 또는 요청된 모임 리스트 조회
  /// Meeting.Status가 CREATED, DATE_VOTING, PLACE_VOTING인 경우만 반환
  /// Authorization 헤더에 Access Token 필요
  Future<List<MeetingBrief>> getWaitingMeetings({
    int page = 0,
    int size = 20,
  }) async {
    try {
      print('🌐 [MeetingClient] GET /api/meetings/waiting?page=$page&size=$size');

      final response = await _dioClient.get(
        '/api/meetings/waiting',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');

      // 응답이 배열인 경우
      if (response.data is List) {
        final meetings = (response.data as List)
            .map((json) => MeetingBrief.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [MeetingClient] 대기 모임 ${meetings.length}개 조회 성공');
        return meetings;
      }

      print('❌ [MeetingClient] 예상치 못한 응답 형식');
      return [];
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] getWaitingMeetings 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 모임 수정
  ///
  /// PATCH /api/meetings/{id}
  ///
  /// 모임의 제목, 날짜, 마감 시간 등을 수정
  /// title은 blank 불가 (null은 가능)
  /// Authorization 헤더에 Access Token 필요
  Future<void> updateMeeting(int meetingId, MeetingUpdateRequest request) async {
    try {
      print('🌐 [MeetingClient] PATCH /api/meetings/$meetingId');
      print('🌐 [MeetingClient] Request Data: ${request.toJson()}');

      final response = await _dioClient.patch(
        '/api/meetings/$meetingId',
        data: request.toJson(),
      );

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');
      print('✅ [MeetingClient] 모임 수정 성공');
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] updateMeeting 에러: $e');
      print('❌ [MeetingClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MeetingClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MeetingClient] Response Data: ${e.response?.data}');
        print('❌ [MeetingClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }
}
