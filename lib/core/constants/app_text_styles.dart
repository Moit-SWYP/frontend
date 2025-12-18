import 'package:flutter/material.dart';
import 'package:moit/core/constants/app_colors.dart';

/// 앱 전체에서 사용하는 텍스트 스타일 정의
/// Figma 디자인 명세 기반 (Pretendard 폰트)
class AppTextStyles {
  AppTextStyles._(); // private constructor

  static const String _fontFamily = 'Pretendard';

  // 큰 제목 (예: "로고영역")
  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // 화면 제목 (예: "모잇에서 상세 사용자정보 프로필을 입력해주세요!")
  static const TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700, // Bold
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // 섹션 제목
  static const TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // 서브타이틀 (예: "약속을 간편하게, 모잇으로 모잇!")
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // 본문 텍스트
  static const TextStyle body1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.6,
  );

  // 버튼 텍스트
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    height: 1.2,
  );

  // 입력 필드
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textHint,
    height: 1.4,
  );

  // 작은 텍스트 (예: 약관 동의 문구)
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const TextStyle captionBold = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600, // SemiBold
    color: AppColors.textSecondary,
    height: 1.6,
  );

  // 에러 텍스트
  static const TextStyle error = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: AppColors.error,
    height: 1.4,
  );
}
