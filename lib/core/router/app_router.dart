import 'package:go_router/go_router.dart';
import 'package:moit/features/auth/presentation/screens/login_screen.dart';
import 'package:moit/features/auth/presentation/screens/signup_detail_screen.dart';
import 'package:moit/features/settings/presentation/screens/home_profile.dart';

/// 앱 전체 라우팅 설정
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
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

      // TODO: 다른 화면들 추가
      // 홈 화면, 모임 목록, 스터디 상세 등
    ],
  );
}
