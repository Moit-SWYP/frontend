import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/auth/presentation/widgets/oauth_button.dart';

/// 로그인 화면
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 로고 영역 (Figma 명세에 따라 배치)
            _buildLogoSection(),

            const Spacer(),

            // OAuth 버튼들
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildOAuthButtons(context),
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
        // 로고 영역 - Figma 명세: 200x100px, 상단 128px, 가운데 정렬
        Padding(
          padding: const EdgeInsets.only(top: 128),
          child: Container(
            width: 200,
            height: 100,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5), // Grey Color/grey030
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '로고영역',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
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
  Widget _buildOAuthButtons(BuildContext context) {
    return Column(
      children: [
        // 임시 테스트 버튼 - 설정 화면으로 이동
        GestureDetector(
          onTap: () {
            context.push('/settings');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'HOME_PROFILE',
              style: AppTextStyles.button.copyWith(
                color: AppColors.primaryBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 카카오 로그인
        OAuthButton.kakao(
          onPressed: () {
            // TODO: 카카오 로그인 로직 구현
            print('카카오 로그인 클릭');
            // 임시로 회원가입 화면으로 이동
            context.push('/signup/detail');
          },
        ),
        const SizedBox(height: 12),

        // 네이버 로그인
        OAuthButton.naver(
          onPressed: () {
            // TODO: 네이버 로그인 로직 구현
            print('네이버 로그인 클릭');
            // 임시로 회원가입 화면으로 이동
            context.push('/signup/detail');
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
