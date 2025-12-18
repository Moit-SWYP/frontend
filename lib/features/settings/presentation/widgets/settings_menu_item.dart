import 'package:flutter/material.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';

/// 설정 메뉴 항목 위젯
class SettingsMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SettingsMenuItem({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey040,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.body1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
