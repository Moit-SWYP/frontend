import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/core/services/kakao_login_service.dart';

/// 내 정보 화면
class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56, // 24px top padding + 32px content height
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 24,
            color: AppColors.textPrimary,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '내정보',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 24 / 18, // lineHeight 24px / fontSize 18px = 1.333
            color: Color(0xFF000000),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // 프로필 아바타
              Center(
                child: _buildProfileAvatar(),
              ),

              const SizedBox(height: 16),

              // 이름
              _buildSectionTitle('이름'),
              const SizedBox(height: 16),
              _buildReadOnlyField('남수빈'),

              const SizedBox(height: 16),

              // 생년월일
              _buildSectionTitle('생년월일'),
              const SizedBox(height: 16),
              _buildReadOnlyField('1999.06.16'),

              const SizedBox(height: 16),

              // 성별
              _buildSectionTitle('성별'),
              const SizedBox(height: 16),
              _buildReadOnlyField('여성'),

              const SizedBox(height: 16),

              // SNS 연동
              _buildSectionTitle('SNS 연동'),
              const SizedBox(height: 16),
              _buildSNSIcons(),

              const SizedBox(height: 16),

              // 로그인 버튼
              _buildLoginButton(),

              const SizedBox(height: 16),

              // 탈퇴하기
              Center(
                child: TextButton(
                  onPressed: () {
                    context.push('/profile/my/withdraw');
                  },
                  child: Text(
                    '탈퇴하기',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 프로필 아바타
  Widget _buildProfileAvatar() {
    return Stack(
      children: [
        // 아바타 원형 컨테이너
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/group_misik.svg',
              width: 72.9,
              height: 75.4,
            ),
          ),
        ),
        // 편집 아이콘
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.grey040,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.edit,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 섹션 타이틀
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.subtitle1.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  /// 읽기 전용 필드
  Widget _buildReadOnlyField(String value) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey040,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        value,
        style: AppTextStyles.body1.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// SNS 아이콘
  Widget _buildSNSIcons() {
    return Row(
      children: [
        // 카카오 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.kakaoYellow,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/kakao_logo.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 네이버 아이콘
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.grey040,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/naver_logo.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// 로그인 버튼
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          try {
            // 카카오 로그인
            final userInfo = await KakaoLoginService.login();

            debugPrint('카카오 로그인 성공!');
            debugPrint('소셜 ID: ${userInfo['socialId']}');
            debugPrint('이메일: ${userInfo['email']}');
            debugPrint('닉네임: ${userInfo['nickname']}');

            // TODO: 백엔드로 사용자 정보 전송
            // AuthService.signup() 또는 AuthService.login() 호출

          } catch (e) {
            debugPrint('카카오 로그인 실패: $e');
            // TODO: 사용자에게 에러 메시지 표시
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // 완전 둥근 모양
          ),
          elevation: 0,
        ),
        child: Text(
          '카카오 로그인',
          style: AppTextStyles.button.copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
