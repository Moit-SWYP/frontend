import 'package:moit/features/auth/data/models/auth_tokens.dart';

/// 인증 상태
class AuthState {
  /// 로그인 여부
  final bool isAuthenticated;

  /// 로딩 상태
  final bool isLoading;

  /// JWT 토큰
  final AuthTokens? tokens;

  /// 카카오 사용자 정보 (회원가입 시 필요)
  final Map<String, dynamic>? kakaoUser;

  /// 에러 메시지
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.tokens,
    this.kakaoUser,
    this.errorMessage,
  });

  /// 로그인 필요 여부
  bool get requiresLogin => !isAuthenticated;

  /// 회원가입 필요 여부 (카카오 로그인은 했지만 백엔드 가입 안됨)
  bool get requiresSignup => kakaoUser != null && !isAuthenticated;

  /// copyWith 메서드
  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    AuthTokens? tokens,
    Map<String, dynamic>? kakaoUser,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      tokens: tokens ?? this.tokens,
      kakaoUser: kakaoUser ?? this.kakaoUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
