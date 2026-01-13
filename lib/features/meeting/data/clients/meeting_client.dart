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
      print('');
      print('───────────────────────────────────────────');
      print('📋 [FETCH] GET /api/meetings/all 호출 시작');
      print('───────────────────────────────────────────');

      final response = await _dioClient.get('/api/meetings/all');

      print('📋 [FETCH] Response Status: ${response.statusCode}');
      print('📋 [FETCH] Response Data Type: ${response.data.runtimeType}');

      // 공통 응답 형식 처리: {code, message, data}
      if (response.data is Map<String, dynamic>) {
        final dataField = response.data['data'];

        if (dataField is List) {
          final meetings = (dataField as List)
              .map((json) => MeetingBrief.fromJson(json as Map<String, dynamic>))
              .toList();

          print('✅ [FETCH] 모임 ${meetings.length}개 조회 성공');
          print('───────────────────────────────────────────');
          print('');
          return meetings;
        }
      }

      // 레거시: 응답이 직접 배열인 경우
      if (response.data is List) {
        final meetings = (response.data as List)
            .map((json) => MeetingBrief.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [FETCH] 모임 ${meetings.length}개 조회 성공 (레거시)');
        print('───────────────────────────────────────────');
        print('');
        return meetings;
      }

      print('❌ [FETCH] 예상치 못한 응답 형식');
      print('❌ [FETCH] response.data type: ${response.data.runtimeType}');
      print('───────────────────────────────────────────');
      print('');
      return [];
    } catch (e, stackTrace) {
      print('❌ [FETCH] getAllMeetings 에러: $e');
      print('❌ [FETCH] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [FETCH] Status Code: ${e.response?.statusCode}');
        print('❌ [FETCH] Response Data: ${e.response?.data}');
        print('❌ [FETCH] Error Message: ${e.message}');
      }
      print('───────────────────────────────────────────');
      print('');

      rethrow;
    }
  }

  /// 모임 생성
  ///
  /// POST /api/meetings
  ///
  /// Authorization 헤더에 Access Token 필요
  ///
  /// 생성된 모임의 ID를 반환합니다.
  Future<int?> createMeeting(MeetingCreateRequest request) async {
    try {
      print('');
      print('═══════════════════════════════════════════');
      print('🚀 [CREATE] POST /api/meetings 호출 시작');
      print('═══════════════════════════════════════════');
      print('🚀 [CREATE] Request Data: ${request.toJson()}');

      final response = await _dioClient.post(
        '/api/meetings',
        data: request.toJson(),
      );

      print('🚀 [CREATE] Response Status: ${response.statusCode}');
      print('DEBUG_RAW_DATA: ${response.data}');
      print('🚀 [CREATE] 응답 타입: ${response.data.runtimeType}');

      // 🔍 유연한 ID 추출 로직
      int? meetingId;

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 케이스 1: response.data가 Map인 경우
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      if (response.data is Map<String, dynamic>) {
        final responseMap = response.data as Map<String, dynamic>;

        // 1-1. data 필드가 숫자인 경우: {code, message, data: 123}
        if (responseMap.containsKey('data')) {
          final dataField = responseMap['data'];
          print('🔍 [CREATE] data 필드 발견: $dataField (타입: ${dataField.runtimeType})');

          if (dataField is int) {
            meetingId = dataField;
            print('✅ [CREATE] data 필드가 직접 숫자: $meetingId');
          } else if (dataField is String) {
            // 문자열이면 숫자로 변환 시도
            try {
              meetingId = int.parse(dataField);
              print('✅ [CREATE] data 문자열을 숫자로 변환: $meetingId');
            } catch (e) {
              print('⚠️ [CREATE] data 문자열 변환 실패: $dataField');
            }
          } else if (dataField is double) {
            // 1826.5 같은 경우 대비
            meetingId = dataField.toInt();
            print('✅ [CREATE] data double을 int로 변환: $meetingId');
          } else if (dataField is Map<String, dynamic>) {
            // 1-2. data 필드가 객체인 경우: {code, message, data: {id: 123}}
            final dataMap = dataField as Map<String, dynamic>;
            print('🔍 [CREATE] data 필드가 객체: ${dataMap.keys.toList()}');

            // id 키 찾기
            if (dataMap.containsKey('id')) {
              final idValue = dataMap['id'];
              if (idValue is int) {
                meetingId = idValue;
              } else if (idValue is String) {
                meetingId = int.tryParse(idValue);
              } else if (idValue is double) {
                meetingId = idValue.toInt();
              }
              print('✅ [CREATE] data.id 발견: $meetingId');
            }
            // meetingId 키 찾기
            else if (dataMap.containsKey('meetingId')) {
              final idValue = dataMap['meetingId'];
              if (idValue is int) {
                meetingId = idValue;
              } else if (idValue is String) {
                meetingId = int.tryParse(idValue);
              } else if (idValue is double) {
                meetingId = idValue.toInt();
              }
              print('✅ [CREATE] data.meetingId 발견: $meetingId');
            }
          }
        }

        // 1-3. 최상위에 id 또는 meetingId가 있는 경우
        if (meetingId == null && responseMap.containsKey('id')) {
          final idValue = responseMap['id'];
          if (idValue is int) {
            meetingId = idValue;
          } else if (idValue is String) {
            meetingId = int.tryParse(idValue);
          } else if (idValue is double) {
            meetingId = idValue.toInt();
          }
          print('✅ [CREATE] 최상위 id 발견: $meetingId');
        }

        if (meetingId == null && responseMap.containsKey('meetingId')) {
          final idValue = responseMap['meetingId'];
          if (idValue is int) {
            meetingId = idValue;
          } else if (idValue is String) {
            meetingId = int.tryParse(idValue);
          } else if (idValue is double) {
            meetingId = idValue.toInt();
          }
          print('✅ [CREATE] 최상위 meetingId 발견: $meetingId');
        }

        // 1-4. 마지막 수단: 모든 값 순회하며 'id' 포함된 키 찾기
        if (meetingId == null) {
          print('🔍 [CREATE] 모든 키를 순회하며 ID 검색 시작...');
          for (var entry in responseMap.entries) {
            final key = entry.key.toLowerCase();
            final value = entry.value;

            if (key.contains('id')) {
              print('🔍 [CREATE] id 포함 키 발견: $key = $value (${value.runtimeType})');

              if (value is int) {
                meetingId = value;
                print('✅ [CREATE] $key에서 숫자 발견: $meetingId');
                break;
              } else if (value is String) {
                meetingId = int.tryParse(value);
                if (meetingId != null) {
                  print('✅ [CREATE] $key 문자열을 숫자로 변환: $meetingId');
                  break;
                }
              } else if (value is double) {
                meetingId = value.toInt();
                print('✅ [CREATE] $key double을 int로 변환: $meetingId');
                break;
              }
            }
          }
        }
      }

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 케이스 2: response.data가 직접 숫자인 경우
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      else if (response.data is int) {
        meetingId = response.data as int;
        print('✅ [CREATE] response.data가 직접 숫자: $meetingId');
      } else if (response.data is double) {
        meetingId = (response.data as double).toInt();
        print('✅ [CREATE] response.data double을 int로 변환: $meetingId');
      } else if (response.data is String) {
        meetingId = int.tryParse(response.data as String);
        print('✅ [CREATE] response.data 문자열을 숫자로 변환: $meetingId');
      }

      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      // 최종 결과
      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      if (meetingId != null) {
        print('');
        print('✅✅✅ [CREATE] 모임 생성 성공! meetingId: $meetingId ✅✅✅');
        print('═══════════════════════════════════════════');
        print('');
        return meetingId;
      } else {
        print('');
        print('⚠️⚠️⚠️ [CREATE] 응답에서 ID를 찾을 수 없음 (서버에는 생성됨) ⚠️⚠️⚠️');
        print('📋 [CREATE] 전체 응답: ${response.data}');
        print('📋 [CREATE] Provider에서 목록 조회로 ID를 찾을 예정');
        print('═══════════════════════════════════════════');
        print('');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ [CREATE] createMeeting 에러: $e');
      print('❌ [CREATE] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [CREATE] Status Code: ${e.response?.statusCode}');
        print('❌ [CREATE] Response Data: ${e.response?.data}');
        print('❌ [CREATE] Error Message: ${e.message}');
      }
      print('═══════════════════════════════════════════');
      print('');

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
  ///
  /// 반환값: meetingId (백엔드가 응답에 포함하는 경우, 없으면 null)
  Future<int?> joinMeetingFromLink(String inviteToken) async {
    try {
      print('🌐 [MeetingClient] POST /api/meetings/invitations/join?inviteToken=$inviteToken');

      final response = await _dioClient.post(
        '/api/meetings/invitations/join',
        queryParameters: {'inviteToken': inviteToken},
      );

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');

      // 백엔드가 meetingId를 반환하는 경우 추출
      int? meetingId;
      if (response.data != null && response.data is Map) {
        final data = response.data['data'];
        if (data != null && data is Map) {
          meetingId = data['meetingId'] as int?;
          if (meetingId != null) {
            print('✅ [MeetingClient] 모임 참여 성공 - meetingId: $meetingId');
          } else {
            print('✅ [MeetingClient] 모임 참여 성공 (meetingId 없음)');
          }
        } else {
          print('✅ [MeetingClient] 모임 참여 성공 (data 없음)');
        }
      } else {
        print('✅ [MeetingClient] 모임 참여 성공');
      }

      return meetingId;
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

  /// 모임 날짜 확정
  ///
  /// PATCH /api/meetings/{id}/confirm
  ///
  /// 투표된 날짜 중 최다 득표 날짜를 확정합니다.
  /// HOST만 호출 가능
  /// Authorization 헤더에 Access Token 필요
  Future<void> confirmMeeting(int meetingId) async {
    try {
      print('🌐 [MeetingClient] PATCH /api/meetings/$meetingId/confirm');

      final response = await _dioClient.patch('/api/meetings/$meetingId/confirm');

      print('🌐 [MeetingClient] Response Status: ${response.statusCode}');
      print('🌐 [MeetingClient] Response Data: ${response.data}');
      print('✅ [MeetingClient] 모임 확정 성공');
    } catch (e, stackTrace) {
      print('❌ [MeetingClient] confirmMeeting 에러: $e');
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
