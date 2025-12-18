import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 정의
/// Figma 디자인 명세 기반
class AppColors {
  AppColors._(); // private constructor

  // Primary Colors
  static const Color kakaoYellow = Color(0xFFFEE500);
  static const Color naverGreen = Color(0xFF03C75A);
  static const Color primaryBlue = Color(0xFF4374F5); // 다음 버튼 색상

  // Background
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAFAFA);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF454545);
  static const Color textHint = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // Grey Scale (Figma 명세)
  static const Color grey030 = Color(0xFFF5F5F5);
  static const Color grey040 = Color(0xFFEFEFEF);
  static const Color grey070 = Color(0xFF666666);

  // Border & Divider
  static const Color border = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFEEEEEE);

  // Input Field
  static const Color inputFill = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFDDDDDD);
  static const Color inputFocused = Color(0xFF4374F5);

  // Button
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonTextDisabled = Color(0xFFAAAAAA);

  // Status Colors
  static const Color success = Color(0xFF00C73C);
  static const Color error = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFFBB00);
  static const Color info = Color(0xFF4374F5);

  // Gender Selection
  static const Color genderSelected = Color(0xFFE8E8E8);
  static const Color genderUnselected = Color(0xFFF5F5F5);

  // Shadow
  static const Color shadow = Color(0x1A000000);
}
