import 'package:flutter/material.dart';

/// 투표 진행중인 약속 카드 위젯
///
/// "일정 이야기 중" 칩과 약속명을 표시
class VotingMeetingCard extends StatelessWidget {
  final String meetingName;
  final String status; // "일정 이야기 중" or "코스 이야기 중"

  const VotingMeetingCard({
    super.key,
    required this.meetingName,
    this.status = '일정 이야기 중',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8F9), // grey030
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 좌측 콘텐츠
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상태 칩
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE8EDFE), // main010
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Color(0xFF1A49F1), // main050
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                      letterSpacing: -0.33,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 약속 이름
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    meetingName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 우측 화살표 아이콘
          Container(
            width: 24,
            height: 24,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: const Icon(
              Icons.chevron_right,
              size: 24,
              color: Color(0xFF505050),
            ),
          ),
        ],
      ),
    );
  }
}
