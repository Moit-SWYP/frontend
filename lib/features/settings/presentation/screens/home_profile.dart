import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/auth/providers/auth_provider.dart';
import 'package:moit/features/member/providers/user_profile_provider.dart';
import 'package:moit/features/member/providers/user_profile_state.dart';
import 'package:moit/features/settings/presentation/widgets/settings_section.dart';
import 'package:moit/features/settings/presentation/widgets/settings_menu_item.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            size: 24,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '설정',
          style: AppTextStyles.heading2.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // 프로필 영역
              _buildProfileSection(userProfile),

              const SizedBox(height: 40),

              // 계정 섹션
              SettingsSection(
                title: '계정',
                children: [
                  SettingsMenuItem(
                    title: '내 정보',
                    onTap: () {
                      context.push('/profile/my');
                    },
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuItem(
                    title: '알림',
                    onTap: () {
                      context.push('/settings/notifications');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 약관 정보 및 기타 섹션
              SettingsSection(
                title: '약관 정보 및 기타',
                children: [
                  SettingsMenuItem(
                    title: '서비스 이용 약관',
                    onTap: () {
                      context.push('/settings/terms');
                    },
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuItem(
                    title: '개인정보 처리 방침',
                    onTap: () {
                      context.push('/settings/privacy');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 앱 버전 정보
              Text(
                '앱 버전 1.02 · 최신버전',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 프로필 섹션
  Widget _buildProfileSection(UserProfileState userProfile) {
    return Row(
      children: [
        // 프로필 아바타
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/icons/group_misik.svg',
              width: 40.83,
              height: 42.21,
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 프로필 정보
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 닉네임 + 카카오 로고
            Row(
              children: [
                Text(
                  userProfile.displayName,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.kakaoYellow,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/kakao_logo.svg',
                      width: 10,
                      height: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // 부제목
            Text(
              userProfile.profile?.genderText ?? '',
              style: AppTextStyles.caption.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
