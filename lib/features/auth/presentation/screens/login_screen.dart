import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/auth/presentation/widgets/oauth_button.dart';
import 'package:moit/features/auth/providers/auth_provider.dart';

/// 로그인 화면
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // 로딩 중일 때
    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 로고 영역 (Figma 명세에 따라 배치)
            _buildLogoSection(),

            const Spacer(),

            // 에러 메시지 표시
            if (authState.errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    authState.errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.red.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // OAuth 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildOAuthButtons(context, ref),
            ),

            const SizedBox(height: 16),

            // 약관 동의 텍스트
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildTermsText(context),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 로고 섹션 (Figma 명세 적용 - 가운데 정렬)
  Widget _buildLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 로고 영역 - Layer_1.svg 사용
        Padding(
          padding: const EdgeInsets.only(top: 128),
          child: Container(
            width: 120,
            height: 43.64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(),
            child: SvgPicture.asset(
              'assets/icons/Layer_1.svg',
              width: 120,
              height: 43.64,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // 서브타이틀 - Figma 명세: 184x72px, 가운데 정렬
        Padding(
          padding: const EdgeInsets.only(top: 92.1655),
          child: SizedBox(
            width: 184,
            height: 72,
            child: Text(
              '약속을 간편하게,\n모잇으로 모엿!',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 28,
                fontWeight: FontWeight.w700, // Bold
                height: 36 / 28, // 행간 36px / 폰트 크기 28px
                letterSpacing: 0, // 자간 0%
                color: Color(0xFF000000),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  /// OAuth 로그인 버튼들
  Widget _buildOAuthButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 카카오 로그인
        OAuthButton.kakao(
          onPressed: () async {
            // 카카오 로그인 실행
            await ref.read(authProvider.notifier).loginWithKakao();

            // 로그인 후 상태 확인
            if (!context.mounted) return;
            final newState = ref.read(authProvider);

            if (newState.isAuthenticated) {
              // 기존 회원 → 홈 화면으로
              context.go('/');
            } else if (newState.requiresSignup) {
              // 신규 회원 → 회원가입 화면으로
              context.push('/signup/detail');
            }
          },
        ),
        const SizedBox(height: 12),

        // 네이버 로그인
        OAuthButton.naver(
          onPressed: () async {
            // 네이버 로그인 실행
            await ref.read(authProvider.notifier).loginWithNaver();

            // 로그인 후 상태 확인
            if (!context.mounted) return;
            final newState = ref.read(authProvider);

            if (newState.isAuthenticated) {
              // 기존 회원 → 홈 화면으로
              context.go('/');
            } else if (newState.requiresSignup) {
              // 신규 회원 → 회원가입 화면으로
              context.push('/signup/detail');
            }
          },
        ),
      ],
    );
  }

  /// 약관 동의 텍스트
  Widget _buildTermsText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textHint,
          height: 1.5,
          fontSize: 11,
        ),
        children: [
          const TextSpan(text: '가입을 진행하시면 '),
          TextSpan(
            text: '서비스약관',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: ' 및 '),
          TextSpan(
            text: '개인정보처리방침',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
          const TextSpan(text: '에\n동의 하시는 것으로 간주합니다.'),
        ],
      ),
    );
  }
}
