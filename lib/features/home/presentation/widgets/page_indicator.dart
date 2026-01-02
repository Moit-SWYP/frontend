import 'package:flutter/material.dart';

/// 페이지 인디케이터 위젯
///
/// 최대 5개 페이지를 표시하며, 현재 페이지를 하이라이트 표시
class PageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          totalPages > 5 ? 5 : totalPages,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < (totalPages > 5 ? 4 : totalPages - 1) ? 8 : 0),
            child: _buildDot(index == currentPage),
          ),
        ),
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    if (isActive) {
      // 활성 페이지: 캡슐형 (24x8)
      return Container(
        width: 24,
        height: 8,
        decoration: ShapeDecoration(
          color: const Color(0xFF7692F7), // main030
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
    } else {
      // 비활성 페이지: 원형 (8x8)
      return Container(
        width: 8,
        height: 8,
        decoration: ShapeDecoration(
          color: const Color(0xFFE9EBEE), // grey040
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}
