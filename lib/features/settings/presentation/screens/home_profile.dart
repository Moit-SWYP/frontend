import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/settings/presentation/widgets/settings_section.dart';
import 'package:moit/features/settings/presentation/widgets/settings_menu_item.dart';

/// 설정 화면
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _buildProfileSection(),

              const SizedBox(height: 40),

              // 계정 섹션
              SettingsSection(
                title: '계정',
                children: [
                  SettingsMenuItem(
                    title: '내 정보',
                    onTap: () {
                      // TODO: 내 정보 화면으로 이동
                      debugPrint('내 정보 클릭');
                    },
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuItem(
                    title: '알림',
                    onTap: () {
                      // TODO: 알림 설정 화면으로 이동
                      debugPrint('알림 클릭');
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
                    title: '약관 및 개인정보 처리 동의',
                    onTap: () {
                      // TODO: 약관 화면으로 이동
                      debugPrint('약관 및 개인정보 처리 동의 클릭');
                    },
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuItem(
                    title: '개인정보 처리 방침',
                    onTap: () {
                      // TODO: 개인정보 처리 방침 화면으로 이동
                      debugPrint('개인정보 처리 방침 클릭');
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
  Widget _buildProfileSection() {
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
                  '남수빈',
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
              '미식형 · 여성',
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
