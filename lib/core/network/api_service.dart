import 'package:dio/dio.dart';
import 'package:moit/core/network/dio_client.dart';

/// API 서비스
///
/// https://moit.shop/swagger-ui/index.html 기반 API 정의
class ApiService {
  final DioClient _dioClient = DioClient();

  Dio get dio => _dioClient.dio;

  // ==================== Auth API ====================

  /// 로그인
  Future<Response> login(Map<String, dynamic> request) async {
    return await _dioClient.post('/api/auth/login', data: request);
  }

  /// 회원가입
  Future<Response> signup(Map<String, dynamic> request) async {
    return await _dioClient.post('/api/auth/signup', data: request);
  }

  /// 로그아웃
  Future<Response> logout() async {
    return await _dioClient.post('/api/auth/logout');
  }

  /// 토큰 재발급
  Future<Response> reissueToken(Map<String, dynamic> request) async {
    return await _dioClient.post('/api/auth/reissue', data: request);
  }

  // ==================== Member API ====================

  /// 내 정보 조회
  Future<Response> getMemberMe() async {
    return await _dioClient.get('/api/members/me');
  }

  /// 회원 탈퇴
  Future<Response> withdrawMember() async {
    return await _dioClient.delete('/api/members/me/withdraw');
  }

  /// 소셜 계정 연동 정보 조회
  Future<Response> getSocialAccounts() async {
    return await _dioClient.get('/api/members/me/social-accounts');
  }

  // ==================== Meeting API ====================

  /// 모임 생성
  Future<Response> createMeeting(Map<String, dynamic> request) async {
    return await _dioClient.post('/api/meetings', data: request);
  }

  /// 모임 목록 조회
  Future<Response> getMeetings({int page = 0, int size = 10}) async {
    return await _dioClient.get(
      '/api/meetings',
      queryParameters: {'page': page, 'size': size},
    );
  }

  /// 모임 상세 조회
  Future<Response> getMeetingDetail(int meetingId) async {
    return await _dioClient.get('/api/meetings/$meetingId');
  }

  /// 모임 수정
  Future<Response> updateMeeting(
    int meetingId,
    Map<String, dynamic> request,
  ) async {
    return await _dioClient.put('/api/meetings/$meetingId', data: request);
  }

  /// 모임 삭제
  Future<Response> deleteMeeting(int meetingId) async {
    return await _dioClient.delete('/api/meetings/$meetingId');
  }

  // ==================== Vote API ====================

  /// 날짜 투표 생성
  Future<Response> createDateVote(
    int meetingId,
    Map<String, dynamic> request,
  ) async {
    return await _dioClient.post(
      '/api/meetings/$meetingId/votes/date',
      data: request,
    );
  }

  /// 시간 투표 생성
  Future<Response> createTimeVote(
    int meetingId,
    Map<String, dynamic> request,
  ) async {
    return await _dioClient.post(
      '/api/meetings/$meetingId/votes/time',
      data: request,
    );
  }

  /// 투표 결과 조회
  Future<Response> getVoteResults(int meetingId) async {
    return await _dioClient.get('/api/meetings/$meetingId/votes/results');
  }

  /// 투표 확정
  Future<Response> confirmVote(
    int meetingId,
    Map<String, dynamic> request,
  ) async {
    return await _dioClient.post(
      '/api/meetings/$meetingId/votes/confirm',
      data: request,
    );
  }

  // ==================== Invitation API ====================

  /// 초대 링크 생성
  Future<Response> createInvitation(int meetingId) async {
    return await _dioClient.post('/api/meetings/$meetingId/invitations');
  }

  /// 초대 수락
  Future<Response> acceptInvitation(String invitationCode) async {
    return await _dioClient.post(
      '/api/meetings/invitations/$invitationCode/accept',
    );
  }

  // ==================== Notification API ====================

  /// 알림 목록 조회
  Future<Response> getNotifications({int page = 0, int size = 10}) async {
    return await _dioClient.get(
      '/api/notifications',
      queryParameters: {'page': page, 'size': size},
    );
  }

  /// 알림 읽음 처리
  Future<Response> markNotificationAsRead(int notificationId) async {
    return await _dioClient.put('/api/notifications/$notificationId/read');
  }

  /// 알림 설정 조회
  Future<Response> getNotificationSettings() async {
    return await _dioClient.get('/api/notifications/settings');
  }

  /// 알림 설정 변경
  Future<Response> updateNotificationSettings(
    Map<String, dynamic> request,
  ) async {
    return await _dioClient.put(
      '/api/notifications/settings',
      data: request,
    );
  }
}
