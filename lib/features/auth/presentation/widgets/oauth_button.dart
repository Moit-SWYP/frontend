import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';

/// OAuth 로그인 버튼 위젯 (카카오, 네이버)
class OAuthButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget? icon;
  final VoidCallback onPressed;

  const OAuthButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.onPressed,
  });

  /// 카카오 로그인 버튼
  factory OAuthButton.kakao({
    required VoidCallback onPressed,
  }) {
    return OAuthButton(
      text: '카카오로 시작하기',
      backgroundColor: AppColors.kakaoYellow,
      textColor: Colors.black,
      icon: SvgPicture.asset(
        'assets/icons/kakao_logo.svg',
        width: 20,
        height: 20,
      ),
      onPressed: onPressed,
    );
  }

  /// 네이버 로그인 버튼
  factory OAuthButton.naver({
    required VoidCallback onPressed,
  }) {
    return OAuthButton(
      text: '네이버로 시작하기',
      backgroundColor: AppColors.naverGreen,
      textColor: Colors.white,
      icon: const Text(
        'N',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTextStyles.button.copyWith(color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
