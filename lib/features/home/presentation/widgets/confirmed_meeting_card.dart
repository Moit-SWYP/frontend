import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 확정된 약속 카드 위젯
///
/// D-day 칩, 약속명, 날짜/장소, 참여자 아이콘, 코스보기 버튼을 표시
class ConfirmedMeetingCard extends StatelessWidget {
  const ConfirmedMeetingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 328,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8F9), // grey030
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 영역 (D-day + 약속명)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // D-day 칩
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE8EDFE), // main010
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: const Text(
                  'D-day',
                  style: TextStyle(
                    color: Color(0xFF1A49F1), // main050
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                    letterSpacing: -0.33,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // 약속 이름
              const Text(
                '스위프 모임',
                style: TextStyle(
                  color: Color(0xFF111111), // txt-primary
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              const SizedBox(height: 2),
              // 날짜 + 장소
              Row(
                children: [
                  const Text(
                    '12월 11일 오전 2시',
                    style: TextStyle(
                      color: Color(0xFF505050), // txt-secondary
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 구분점
                  Container(
                    width: 2,
                    height: 2,
                    decoration: const ShapeDecoration(
                      color: Color(0xFF505050),
                      shape: CircleBorder(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '강남역 2번 출구',
                    style: TextStyle(
                      color: Color(0xFF505050), // txt-secondary
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 참여자 아이콘들 (겹쳐서 표시)
          SizedBox(
            width: 80,
            height: 32,
            child: Stack(
              children: [
                // 맨 오른쪽 (맨 아래 레이어)
                Positioned(
                  left: 48,
                  child: SvgPicture.asset(
                    'assets/icons/insta_S.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
                Positioned(
                  left: 32,
                  child: SvgPicture.asset(
                    'assets/icons/study_S.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
                Positioned(
                  left: 16,
                  child: SvgPicture.asset(
                    'assets/icons/food_S.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
                // 맨 왼쪽 (맨 위 레이어)
                Positioned(
                  left: 0,
                  child: SvgPicture.asset(
                    'assets/icons/alcohol_S.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 코스보기 버튼
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                // TODO: 코스 상세 화면으로 이동
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A49F1), // main050
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                '코스보기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
