import 'package:dio/dio.dart';
import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/member/data/models/member_info.dart';
import 'package:moit/features/member/data/models/member_withdraw_request.dart';
import 'package:moit/features/member/data/models/social_link_request.dart';

/// Member API 클라이언트
class MemberClient {
  final DioClient _dioClient = DioClient();

  /// 내 정보 조회
  ///
  /// GET /api/members/me
  ///
  /// 조회 내용:
  /// - 이메일
  /// - 닉네임
  /// - 생년월일
  /// - 성별
  /// - 연동된 소셜 계정 목록
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<MemberInfo> getMyInfo() async {
    try {
      print('🌐 [MemberClient] GET /api/members/me');

      final response = await _dioClient.get('/api/members/me');

      print('🌐 [MemberClient] Response Status: ${response.statusCode}');
      print('🌐 [MemberClient] Response Data: ${response.data}');

      final memberInfo = MemberInfo.fromJson(response.data['data']);

      print('✅ [MemberClient] 내 정보 조회 성공');
      print('  - email: ${memberInfo.email}');
      print('  - nickname: ${memberInfo.nickname}');
      print('  - 연동 계정: ${memberInfo.socialAccountCount}개');

      return memberInfo;
    } catch (e, stackTrace) {
      print('❌ [MemberClient] getMyInfo 에러: $e');
      print('❌ [MemberClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MemberClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MemberClient] Response Data: ${e.response?.data}');
        print('❌ [MemberClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 내 캐릭터 변경
  ///
  /// PATCH /api/members/me/character/{character}
  ///
  /// 사용 가능한 캐릭터 타입:
  /// - FOODIE (미식가)
  /// - DRINKER (애주가)
  /// - HEALER (휴식가)
  /// - CULTURE_LOVER (관람형)
  /// - TRAVELER (모험가)
  /// - ACTIVE (활동가)
  /// - TREND_SETTER (주도가)
  /// - STUDYER (독습가)
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<void> updateCharacter(String character) async {
    try {
      print('🌐 [MemberClient] PATCH /api/members/me/character/$character');

      final response = await _dioClient.patch('/api/members/me/character/$character');

      print('🌐 [MemberClient] Response Status: ${response.statusCode}');
      print('✅ [MemberClient] 캐릭터 변경 성공: $character');
    } catch (e, stackTrace) {
      print('❌ [MemberClient] updateCharacter 에러: $e');
      print('❌ [MemberClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MemberClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MemberClient] Response Data: ${e.response?.data}');
        print('❌ [MemberClient] Error Message: ${e.message}');

        // 400: 유효하지 않은 캐릭터 타입
        if (e.response?.statusCode == 400) {
          print('⚠️ [MemberClient] 유효하지 않은 캐릭터 타입입니다');
        }
      }

      rethrow;
    }
  }

  /// 소셜 계정 연동
  ///
  /// POST /api/members/me/social-accounts
  ///
  /// 현재 로그인된 회원 계정에 소셜 계정을 연동합니다.
  /// Authorization 헤더에 Access Token 필요
  Future<void> linkSocialAccount(SocialLinkRequest request) async {
    try {
      print('🌐 [MemberClient] POST /api/members/me/social-accounts');
      print('  - provider: ${request.socialProvider}');

      final response = await _dioClient.post(
        '/api/members/me/social-accounts',
        data: request.toJson(),
      );

      print('🌐 [MemberClient] Response Status: ${response.statusCode}');
      print('✅ [MemberClient] 소셜 계정 연동 성공');
    } catch (e, stackTrace) {
      print('❌ [MemberClient] linkSocialAccount 에러: $e');
      print('❌ [MemberClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MemberClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MemberClient] Response Data: ${e.response?.data}');
        print('❌ [MemberClient] Error Message: ${e.message}');

        // 409: 이미 연동된 소셜 계정
        if (e.response?.statusCode == 409) {
          print('⚠️ [MemberClient] 이미 연동된 소셜 계정입니다');
        }
      }

      rethrow;
    }
  }

  /// 소셜 계정 연동 해제
  ///
  /// DELETE /api/members/me/social-accounts/{provider}
  ///
  /// provider: KAKAO 또는 NAVER
  /// Authorization 헤더에 Access Token 필요
  Future<void> unlinkSocialAccount(String provider) async {
    try {
      print('🌐 [MemberClient] DELETE /api/members/me/social-accounts/$provider');

      final response = await _dioClient.delete('/api/members/me/social-accounts/$provider');

      print('🌐 [MemberClient] Response Status: ${response.statusCode}');
      print('✅ [MemberClient] 소셜 계정 연동 해제 성공');
    } catch (e, stackTrace) {
      print('❌ [MemberClient] unlinkSocialAccount 에러: $e');
      print('❌ [MemberClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MemberClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MemberClient] Response Data: ${e.response?.data}');
        print('❌ [MemberClient] Error Message: ${e.message}');

        // 404: 연동된 소셜 계정이 없음
        if (e.response?.statusCode == 404) {
          print('⚠️ [MemberClient] 연동된 소셜 계정이 없습니다');
        }
      }

      rethrow;
    }
  }

  /// 회원 탈퇴
  ///
  /// POST /api/members/me/withdraw
  ///
  /// 회원 탈퇴 처리:
  /// - 회원은 즉시 삭제 처리됩니다.
  /// - 탈퇴 사유가 기록됩니다.
  /// - 연동된 소셜 계정은 비활성화됩니다.
  /// - Redis에 저장된 Refresh Token이 삭제되어 즉시 로그아웃 처리됩니다.
  ///
  /// 탈퇴 사유:
  /// 1. 일정 생성이 불편해요. (SCHEDULE_INCONVENIENT)
  /// 2. 원하는 기능이 없어요. (NO_FEATURE)
  /// 3. 버그가 자주 발생해요. (BUG)
  /// 4. 기타 (직접 입력) (ETC)
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<void> withdraw(MemberWithdrawRequest request) async {
    try {
      print('🌐 [MemberClient] POST /api/members/me/withdraw');
      print('  - type: ${request.type}');
      if (request.description != null) {
        print('  - description: ${request.description}');
      }

      final response = await _dioClient.post(
        '/api/members/me/withdraw',
        data: request.toJson(),
      );

      print('🌐 [MemberClient] Response Status: ${response.statusCode}');
      print('✅ [MemberClient] 회원 탈퇴 성공');
    } catch (e, stackTrace) {
      print('❌ [MemberClient] withdraw 에러: $e');
      print('❌ [MemberClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MemberClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MemberClient] Response Data: ${e.response?.data}');
        print('❌ [MemberClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }
}
