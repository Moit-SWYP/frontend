import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/core/storage/token_storage.dart';
import 'package:moit/features/auth/data/models/auth_tokens.dart';
import 'package:moit/features/auth/data/models/signup_request.dart';
import 'package:moit/features/auth/providers/auth_state.dart';
import 'package:moit/features/auth/services/social_login_service.dart';
import 'package:moit/features/home/providers/home_provider.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
import 'package:moit/features/member/data/models/character_type.dart';
import 'package:moit/features/member/providers/user_profile_provider.dart';

/// 인증 상태 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref: ref);
});

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({required Ref ref})
      : _ref = ref,
        super(const AuthState()) {
    _checkLoginStatus();
  }

  final Ref _ref;
  final SocialLoginService _socialLoginService = SocialLoginService();
  final TokenStorage _tokenStorage = TokenStorage();

  /// 앱 시작 시 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    print('🔍 [Auth] 로그인 상태 확인 시작');

    final isLoggedIn = await _socialLoginService.isLoggedIn();
    if (!isLoggedIn) {
      print('❌ [Auth] 소셜 로그인 상태 없음 - 토큰 삭제');
      await _tokenStorage.clearTokens();
      state = const AuthState();
      return;
    }

    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();

    // 토큰이 없으면 깔끔하게 초기화
    if (accessToken == null || refreshToken == null) {
      print('❌ [Auth] 저장된 토큰 없음 - 상태 초기화');
      await _tokenStorage.clearTokens();
      state = const AuthState();
      return;
    }

    print('✅ [Auth] 저장된 토큰 발견 - 인증 상태로 설정');
    state = state.copyWith(
      isAuthenticated: true,
      tokens: AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );

    // 🔄 프로필 로드로 토큰 유효성 검증
    print('🔄 [Auth] 프로필 로드로 토큰 유효성 검증 시작');
    await _ref.read(userProfileProvider.notifier).loadProfile();

    // 프로필 로드 결과 확인
    final profileState = _ref.read(userProfileProvider);

    // AUTH_EXPIRED 에러 발생 시 - 토큰 무효화 및 로그아웃 처리
    if (profileState.errorMessage == 'AUTH_EXPIRED') {
      print('🚨 [Auth] 토큰 만료 감지 - 강제 로그아웃 처리');
      await _tokenStorage.clearTokens();
      _ref.read(userProfileProvider.notifier).clearProfile();
      state = const AuthState();
      print('✅ [Auth] 강제 로그아웃 완료 - 로그인 화면으로 이동');
    } else if (profileState.hasProfile) {
      print('✅ [Auth] 토큰 유효 - 프로필 로드 성공');
    } else if (profileState.errorMessage != null) {
      print('⚠️ [Auth] 프로필 로드 실패: ${profileState.errorMessage}');
    }
  }

  /// 카카오 로그인
  Future<void> loginWithKakao() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final authResponse = await _socialLoginService.loginWithKakao();

      if (authResponse.signupRequired) {
        // 신규 회원 - 회원가입 필요
        // SocialLoginService에 캐시된 카카오 사용자 정보 가져오기
        final cachedKakaoUser = _socialLoginService.cachedKakaoUser;

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          kakaoUser: cachedKakaoUser,
        );
      } else {
        // 기존 회원 - 로그인 완료
        print('✅ [Auth] 기존 회원 로그인 성공');
        print('✅ [Auth] AccessToken: ${authResponse.tokens?.accessToken.substring(0, 20)}...');

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          tokens: authResponse.tokens,
          kakaoUser: null,
        );

        print('🔄 [Auth] 인증 상태 업데이트 완료 - isAuthenticated: ${state.isAuthenticated}');
        print('🔄 [Auth] 프로필 자동 로드 시작...');

        await _ref.read(userProfileProvider.notifier).loadProfile();

        print('🔄 [Auth] 프로필 자동 로드 완료');
        final profileState = _ref.read(userProfileProvider);
        print('🔄 [Auth] 현재 프로필 상태 - hasProfile: ${profileState.hasProfile}, displayName: ${profileState.displayName}');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 회원가입
  Future<void> signup({
    required String nickname,
    required String birthDate,
    required Gender gender,
    required CharacterType characterType,
  }) async {
    // state.kakaoUser 또는 SocialLoginService에 캐시된 정보 확인
    final kakaoUser = state.kakaoUser ?? _socialLoginService.cachedKakaoUser;

    if (kakaoUser == null) {
      state = state.copyWith(
        errorMessage: '카카오 로그인 정보가 없습니다. 다시 로그인해주세요.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      print('📝 [회원가입] 요청 데이터:');
      print('  - nickname: $nickname');
      print('  - birthDate: $birthDate');
      print('  - gender: $gender');
      print('  - characterType: $characterType');
      print('  - kakaoUser: $kakaoUser');

      final authResponse = await _socialLoginService.signupWithKakao(
        kakaoUser: kakaoUser,
        nickname: nickname,
        birthDate: birthDate,
        gender: gender,
        characterType: characterType,
      );

      print('✅ [회원가입] 성공');

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        tokens: authResponse.tokens,
        kakaoUser: null,
      );

      // 🔄 회원가입 성공 → 프로필 자동 로드
      print('🔄 [Auth] 회원가입 성공 → 프로필 자동 로드');
      await _ref.read(userProfileProvider.notifier).loadProfile();
    } catch (e) {
      print('❌ [회원가입] 에러: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    print('🔄 [Auth] 로그아웃 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // 소셜 로그인 로그아웃
      await _socialLoginService.logout();

      // 토큰 삭제
      await _tokenStorage.clearTokens();
      print('✅ [Auth] 토큰 삭제 완료');

      // 모든 전역 상태 초기화
      _ref.read(userProfileProvider.notifier).clearProfile();
      _ref.read(meetingProvider.notifier).clearMeetings();
      _ref.read(homeProvider.notifier).clearHomeData();
      print('✅ [Auth] 전역 상태 초기화 완료');

      state = const AuthState();
      print('✅ [Auth] 로그아웃 완료');
    } catch (e) {
      print('❌ [Auth] 로그아웃 에러: $e');
      // 에러가 발생해도 로컬 상태는 초기화
      await _tokenStorage.clearTokens();
      _ref.read(userProfileProvider.notifier).clearProfile();
      _ref.read(meetingProvider.notifier).clearMeetings();
      _ref.read(homeProvider.notifier).clearHomeData();
      state = const AuthState(errorMessage: '로그아웃 중 에러가 발생했습니다');
    }
  }

  /// 회원 탈퇴
  Future<void> withdraw() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _socialLoginService.withdraw();

      // 프로필 초기화
      _ref.read(userProfileProvider.notifier).clearProfile();

      state = const AuthState();
    } catch (e) {
      // 에러가 발생해도 로컬 상태는 초기화
      _ref.read(userProfileProvider.notifier).clearProfile();
      state = const AuthState(errorMessage: '회원 탈퇴 중 에러가 발생했습니다');
    }
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
