import 'package:dio/dio.dart';
import 'package:moit/core/models/api_response.dart';
import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/auth/data/models/auth_response.dart';
import 'package:moit/features/auth/data/models/auth_tokens.dart';
import 'package:moit/features/auth/data/models/login_request.dart';
import 'package:moit/features/auth/data/models/reissue_request.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';

/// Auth API 클라이언트
///
/// https://moit.shop/v3/api-docs/auth 기반
class AuthClient {
  final DioClient _dioClient = DioClient();

  /// 로그인
  ///
  /// 소셜 로그인 정보를 받아 인증을 처리합니다.
  ///
  /// - 기존 회원: JWT 토큰 발급 (signupRequired = false)
  /// - 신규 회원: 회원가입 필요 (signupRequired = true, tokens = null)
  ///
  /// 토큰 정책:
  /// - Access Token: 15분 유효 (API 인증에 사용)
  /// - Refresh Token: 7일 유효 (Access Token 만료 시 재발급에 사용)
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    try {
      print('🌐 [AuthClient] POST /api/auth/login');
      print('🌐 [AuthClient] Request Body: ${request.toJson()}');

      final response = await _dioClient.post(
        '/api/auth/login',
        data: request.toJson(),
      );

      print('🌐 [AuthClient] Response Status: ${response.statusCode}');
      print('🌐 [AuthClient] Response Data: ${response.data}');

      return ApiResponse<AuthResponse>(
        code: response.data['code']?.toString() ?? '200',
        message: response.data['message'] ?? 'Success',
        data: AuthResponse.fromJson(response.data['data']),
      );
    } catch (e) {
      print('❌ [AuthClient] Login 에러: $e');

      // DioException인 경우 상세 정보 출력
      if (e is DioException) {
        print('❌ [AuthClient] Status Code: ${e.response?.statusCode}');
        print('❌ [AuthClient] Response Data: ${e.response?.data}');
        print('❌ [AuthClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }

  /// 회원가입
  ///
  /// 신규 회원의 회원가입을 처리합니다.
  ///
  /// 요청 구조:
  /// - login: 소셜 정보 (socialProvider, socialId, email)
  /// - nickname, birthdate, gender, characterType
  ///
  /// 응답:
  /// - signupRequired: false
  /// - tokens: 로그인 완료 후 발급된 JWT (access, refresh)
  Future<ApiResponse<AuthResponse>> signup(SignupRequest request) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/signup',
        data: request.toJson(),
      );

      return ApiResponse<AuthResponse>(
        code: response.data['code']?.toString() ?? '200',
        message: response.data['message'] ?? 'Success',
        data: AuthResponse.fromJson(response.data['data']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 토큰 재발급
  ///
  /// Refresh Token을 이용해 Access / Refresh Token을 재발급합니다.
  ///
  /// - Refresh Token 검증 및 Redis 저장값과의 일치 여부를 확인합니다.
  /// - 유효한 경우, 기존 토큰은 무효화되고 새로운 토큰 쌍이 발급됩니다.
  /// - Access Token 만료 시 호출됩니다.
  Future<ApiResponse<AuthTokens>> reissue(ReissueRequest request) async {
    try {
      final response = await _dioClient.post(
        '/api/auth/reissue',
        data: request.toJson(),
      );

      return ApiResponse<AuthTokens>(
        code: response.data['code']?.toString() ?? '200',
        message: response.data['message'] ?? 'Success',
        data: AuthTokens.fromJson(response.data['data']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃
  ///
  /// 현재 로그인된 사용자를 로그아웃 처리합니다.
  ///
  /// - Redis에 저장된 Refresh Token을 삭제합니다.
  /// - Access Token은 만료 시점까지 유효하지만,
  ///   이후 재발급은 불가능합니다.
  ///
  /// Authorization 헤더에 Access Token이 필요합니다.
  Future<ApiResponse<void>> logout() async {
    try {
      final response = await _dioClient.post('/api/auth/logout');

      return ApiResponse<void>(
        code: response.data['code']?.toString() ?? '200',
        message: response.data['message'] ?? 'Success',
        data: null,
      );
    } catch (e) {
      rethrow;
    }
  }
}
