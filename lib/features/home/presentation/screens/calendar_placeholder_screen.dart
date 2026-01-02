import 'package:flutter/material.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';

/// 캘린더 플레이스홀더 화면 (추후 구현 예정)
class CalendarPlaceholderScreen extends StatelessWidget {
  const CalendarPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '캘린더 화면',
              style: AppTextStyles.heading2.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '추후 구현 예정입니다',
              style: AppTextStyles.body1.copyWith(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
