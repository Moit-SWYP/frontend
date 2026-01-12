import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/features/auth/presentation/screens/login_screen.dart';
import 'package:moit/features/auth/presentation/screens/signup_detail_screen.dart';
import 'package:moit/features/auth/providers/auth_provider.dart';
import 'package:moit/features/home/presentation/screens/main_tab_screen.dart';
import 'package:moit/features/home/presentation/screens/vote_home_screen.dart';
import 'package:moit/features/settings/presentation/screens/home_profile.dart';
import 'package:moit/features/settings/presentation/screens/home_profile_my.dart';
import 'package:moit/features/settings/presentation/screens/home_profile_my_account.dart';
import 'package:moit/features/settings/presentation/screens/terms_of_service_screen.dart';
import 'package:moit/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:moit/features/settings/presentation/screens/notification_settings_screen.dart';

/// 앱 전체 라우팅 설정
class AppRouter {
  static GoRouter router(WidgetRef ref) => GoRouter(
        initialLocation: '/login',
        redirect: (context, state) {
          final authState = ref.read(authProvider);
          final isAuthenticated = authState.isAuthenticated;
          final isLoginPage = state.matchedLocation == '/login';
          final isSignupPage = state.matchedLocation.startsWith('/signup');

          // 로그인 안 된 상태에서 보호된 페이지 접근 시 로그인 페이지로
          if (!isAuthenticated && !isLoginPage && !isSignupPage) {
            return '/login';
          }

          // 로그인 된 상태에서 로그인/회원가입 페이지 접근 시 홈으로
          if (isAuthenticated && (isLoginPage || isSignupPage)) {
            return '/';
          }

          return null; // 리다이렉트 없음
        },
        routes: [
          // 홈 화면 (메인 탭 네비게이션)
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const MainTabScreen(),
          ),

      // 로그인 화면
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 회원가입 상세 정보 입력
      GoRoute(
        path: '/signup/detail',
        name: 'signup-detail',
        builder: (context, state) => const SignupDetailScreen(),
      ),

      // 설정 화면
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // 내 정보 화면
      GoRoute(
        path: '/profile/my',
        name: 'profile-my',
        builder: (context, state) => const MyProfileScreen(),
      ),

      // 회원탈퇴 화면
      GoRoute(
        path: '/profile/my/withdraw',
        name: 'profile-withdraw',
        builder: (context, state) => const WithdrawAccountScreen(),
      ),

      // 서비스 이용 약관 화면
      GoRoute(
        path: '/settings/terms',
        name: 'terms',
        builder: (context, state) => const TermsOfServiceScreen(),
      ),

      // 개인정보 처리 방침 화면
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // 알림 설정 화면
      GoRoute(
        path: '/settings/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // Vote Home 화면 (대기 중인 모임 전체 목록)
      GoRoute(
        path: '/vote-home',
        name: 'vote-home',
        builder: (context, state) => const VoteHomeScreen(),
      ),

      // TODO: 다른 화면들 추가
      // 홈 화면, 모임 목록, 스터디 상세 등
    ],
  );
}
