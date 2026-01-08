import 'package:moit/core/models/api_response.dart';
import 'package:moit/core/services/kakao_login_service.dart';
import 'package:moit/core/services/naver_login_service.dart';
import 'package:moit/core/storage/token_storage.dart';
import 'package:moit/features/auth/data/clients/auth_client.dart';
import 'package:moit/features/auth/data/models/auth_response.dart';
import 'package:moit/features/auth/data/models/login_request.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';
import 'package:moit/features/member/data/models/character_type.dart';

/// 소셜 로그인 통합 서비스
///
/// 카카오/네이버 SDK와 백엔드 API를 연결하는 서비스
///
/// 흐름:
/// 1. 소셜 SDK로 로그인 → User 객체 획득
/// 2. User 정보를 LoginRequest로 변환 (카카오) 또는 액세스 토큰 전송 (네이버)
/// 3. AuthClient.login() 또는 AuthClient.naverLogin() 호출
/// 4. signupRequired 체크
///    - false: 토큰 저장 후 로그인 완료
///    - true: 회원가입 필요
class SocialLoginService {
  final AuthClient _authClient = AuthClient();
  final TokenStorage _tokenStorage = TokenStorage();

  // 카카오 사용자 정보 캐싱 (회원가입 시 재사용)
  Map<String, dynamic>? _cachedKakaoUser;

  // 네이버 사용자 정보 캐싱 (회원가입 시 재사용)
  Map<String, dynamic>? _cachedNaverUser;

  /// 카카오 로그인 및 백엔드 인증
  ///
  /// 반환값:
  /// - AuthResponse: 백엔드 로그인 응답
  ///   - signupRequired = false: 기존 회원, 토큰 자동 저장됨
  ///   - signupRequired = true: 신규 회원, 회원가입 필요
  Future<AuthResponse> loginWithKakao() async {
    try {
      // 1. 카카오 SDK로 로그인
      final kakaoUser = await KakaoLoginService.login();

      // 카카오 사용자 정보 캐싱 (회원가입 시 사용)
      _cachedKakaoUser = kakaoUser;

      // 2. LoginRequest 생성
      final loginRequest = LoginRequest(
        socialProvider: SocialProvider.kakao,
        socialId: kakaoUser['socialId'] as String,
        email: kakaoUser['email'] as String,
      );

      // 🔍 디버깅: 백엔드로 보낼 LoginRequest 출력
      print('📤 [백엔드 로그인] 요청 데이터: ${loginRequest.toJson()}');

      // 3. 백엔드 로그인 API 호출
      final ApiResponse<AuthResponse> response =
          await _authClient.login(loginRequest);

      print('📥 [백엔드 로그인] 응답 코드: ${response.code}');
      print('📥 [백엔드 로그인] 응답 메시지: ${response.message}');

      final authResponse = response.data!;

      // 4. 기존 회원인 경우 토큰 저장
      if (!authResponse.signupRequired && authResponse.tokens != null) {
        await _tokenStorage.saveTokens(
          accessToken: authResponse.tokens!.accessToken,
          refreshToken: authResponse.tokens!.refreshToken,
        );
        print('✅ [백엔드 로그인] 기존 회원 - 토큰 저장 완료');
        // 토큰 저장 후 캐시 삭제
        _cachedKakaoUser = null;
      } else if (authResponse.signupRequired) {
        print('ℹ️ [백엔드 로그인] 신규 회원 - 회원가입 필요');
      }

      return authResponse;
    } catch (e) {
      print('❌ [백엔드 로그인] 에러: $e');
      _cachedKakaoUser = null;
      rethrow;
    }
  }

  /// 네이버 로그인 및 백엔드 인증
  ///
  /// 반환값:
  /// - AuthResponse: 백엔드 로그인 응답
  ///   - signupRequired = false: 기존 회원, 토큰 자동 저장됨
  ///   - signupRequired = true: 신규 회원, 회원가입 필요
  Future<AuthResponse> loginWithNaver() async {
    try {
      // 1. 네이버 SDK로 로그인
      final naverUser = await NaverLoginService.login();

      // 네이버 사용자 정보 캐싱 (회원가입 시 사용)
      _cachedNaverUser = naverUser;

      // 2. 액세스 토큰 추출
      final accessToken = naverUser['accessToken'] as String;

      // 🔍 디버깅: 백엔드로 보낼 액세스 토큰 출력
      print('📤 [네이버 백엔드 로그인] 액세스 토큰 전송');

      // 3. 백엔드 네이버 로그인 API 호출
      final ApiResponse<AuthResponse> response =
          await _authClient.naverLogin(accessToken);

      print('📥 [네이버 백엔드 로그인] 응답 코드: ${response.code}');
      print('📥 [네이버 백엔드 로그인] 응답 메시지: ${response.message}');

      final authResponse = response.data!;

      // 4. 기존 회원인 경우 토큰 저장
      if (!authResponse.signupRequired && authResponse.tokens != null) {
        await _tokenStorage.saveTokens(
          accessToken: authResponse.tokens!.accessToken,
          refreshToken: authResponse.tokens!.refreshToken,
        );
        print('✅ [네이버 백엔드 로그인] 기존 회원 - 토큰 저장 완료');
        // 토큰 저장 후 캐시 삭제
        _cachedNaverUser = null;
      } else if (authResponse.signupRequired) {
        print('ℹ️ [네이버 백엔드 로그인] 신규 회원 - 회원가입 필요');
      }

      return authResponse;
    } catch (e) {
      print('❌ [네이버 백엔드 로그인] 에러: $e');
      _cachedNaverUser = null;
      rethrow;
    }
  }

  /// 회원가입 후 로그인
  ///
  /// 카카오 로그인 후 signupRequired = true인 경우 호출
  ///
  /// [kakaoUser]: 카카오 사용자 정보 (선택적, 없으면 캐시 사용)
  /// [nickname]: 사용자 닉네임
  /// [birthDate]: 생년월일 (yyyy-MM-dd)
  /// [gender]: 성별
  /// [characterType]: 캐릭터 타입
  Future<AuthResponse> signupWithKakao({
    Map<String, dynamic>? kakaoUser,
    required String nickname,
    required String birthDate,
    required Gender gender,
    required CharacterType characterType,
  }) async {
    try {
      // 캐시된 카카오 정보 사용 (없으면 파라미터 사용)
      final userInfo = kakaoUser ?? _cachedKakaoUser;

      if (userInfo == null) {
        throw Exception('카카오 로그인 정보가 없습니다. 다시 로그인해주세요.');
      }

      // 1. LoginRequest 생성
      final loginRequest = LoginRequest(
        socialProvider: SocialProvider.kakao,
        socialId: userInfo['socialId'] as String,
        email: userInfo['email'] as String,
      );

      // 2. SignupRequest 생성
      final signupRequest = SignupRequest(
        login: loginRequest,
        nickname: nickname,
        birthDate: birthDate,
        gender: gender,
        characterType: characterType,
      );

      // 3. 회원가입 API 호출
      final ApiResponse<AuthResponse> response =
          await _authClient.signup(signupRequest);

      final authResponse = response.data!;

      // 4. 토큰 저장
      if (authResponse.tokens != null) {
        await _tokenStorage.saveTokens(
          accessToken: authResponse.tokens!.accessToken,
          refreshToken: authResponse.tokens!.refreshToken,
        );
      }

      // 캐시 삭제
      _cachedKakaoUser = null;

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// 로그아웃
  ///
  /// 1. 백엔드 로그아웃 (Refresh Token 삭제)
  /// 2. 로컬 토큰 삭제
  /// 3. 소셜 SDK 로그아웃 (카카오, 네이버)
  /// 4. 캐시 삭제
  Future<void> logout() async {
    try {
      // 1. 백엔드 로그아웃
      await _authClient.logout();

      // 2. 로컬 토큰 삭제
      await _tokenStorage.clearTokens();

      // 3. 소셜 SDK 로그아웃
      try {
        await KakaoLoginService.logout();
      } catch (e) {
        print('⚠️ [로그아웃] 카카오 로그아웃 실패 (무시): $e');
      }

      try {
        await NaverLoginService.logout();
      } catch (e) {
        print('⚠️ [로그아웃] 네이버 로그아웃 실패 (무시): $e');
      }

      // 4. 캐시 삭제
      _cachedKakaoUser = null;
      _cachedNaverUser = null;
    } catch (e) {
      // 에러가 발생해도 로컬 토큰과 캐시는 삭제
      await _tokenStorage.clearTokens();
      _cachedKakaoUser = null;
      _cachedNaverUser = null;
      rethrow;
    }
  }

  /// 회원 탈퇴
  ///
  /// 1. 백엔드 회원 탈퇴
  /// 2. 로컬 토큰 삭제
  /// 3. 카카오 SDK 연결 해제
  /// 4. 캐시 삭제
  Future<void> withdraw() async {
    try {
      // 1. 백엔드 회원 탈퇴는 별도 API 필요 (현재 AuthClient에 없음)
      // TODO: MemberClient 구현 후 추가

      // 2. 로컬 토큰 삭제
      await _tokenStorage.clearTokens();

      // 3. 카카오 SDK 연결 해제
      await KakaoLoginService.unlink();

      // 4. 캐시 삭제
      _cachedKakaoUser = null;
    } catch (e) {
      // 에러가 발생해도 로컬 토큰과 캐시는 삭제
      await _tokenStorage.clearTokens();
      _cachedKakaoUser = null;
      rethrow;
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    return await _tokenStorage.hasTokens();
  }

  /// 캐시된 카카오 사용자 정보 반환
  Map<String, dynamic>? get cachedKakaoUser => _cachedKakaoUser;
}
