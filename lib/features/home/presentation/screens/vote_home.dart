import 'package:flutter/material.dart';

/// 투표 진행중인 약속 목록 화면
class VoteHomeScreen extends StatefulWidget {
  const VoteHomeScreen({super.key});

  @override
  State<VoteHomeScreen> createState() => _VoteHomeScreenState();
}

class _VoteHomeScreenState extends State<VoteHomeScreen> {
  // 선택된 필터: 'all', 'schedule', 'course'
  String _selectedFilter = 'all';

  // 더미 데이터
  final List<Map<String, String>> _allMeetings = [
    {'name': '우열님 문병안 가기', 'status': 'schedule'},
    {'name': '진희 생일파티', 'status': 'course', 'date': '12월 15일 오전 11시', 'location': '강남역 2번 출구'},
    {'name': '진희 생일파티', 'status': 'schedule'},
    {'name': '진희 생일파티', 'status': 'both'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111111)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // 제목
                const Text(
                  '친구들이 기다리고 있어요',
                  style: TextStyle(
                    color: Color(0xFF111111), // txt-primary
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),

                const SizedBox(height: 8),

                // 부제목
                const Text(
                  '일정이나 코스를 정리중인 모임들이에요',
                  style: TextStyle(
                    color: Color(0xFF505050), // txt-secondary
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),

                const SizedBox(height: 24),

                // 필터 버튼들
                _buildFilterButtons(),

                const SizedBox(height: 24),

                // 약속 목록
                _buildMeetingList(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 필터 버튼들
  Widget _buildFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildFilterButton('전체', 'all'),
        const SizedBox(width: 8),
        _buildFilterButton('일정 이야기 중', 'schedule'),
        const SizedBox(width: 8),
        _buildFilterButton('코스 이야기 중', 'course'),
      ],
    );
  }

  /// 개별 필터 버튼
  Widget _buildFilterButton(String label, String filterValue) {
    final isSelected = _selectedFilter == filterValue;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filterValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF1A49F1) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isSelected
                  ? const Color(0xFF1A49F1)
                  : const Color(0xFFE9EBEE), // grey040
            ),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF999999),
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  /// 약속 목록
  Widget _buildMeetingList() {
    // 필터링된 약속 목록
    final filteredMeetings = _allMeetings.where((meeting) {
      if (_selectedFilter == 'all') return true;
      if (_selectedFilter == 'schedule') {
        return meeting['status'] == 'schedule' || meeting['status'] == 'both';
      }
      if (_selectedFilter == 'course') {
        return meeting['status'] == 'course' || meeting['status'] == 'both';
      }
      return false;
    }).toList();

    return Column(
      children: filteredMeetings
          .map((meeting) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMeetingCard(meeting),
              ))
          .toList(),
    );
  }

  /// 약속 카드
  Widget _buildMeetingCard(Map<String, String> meeting) {
    return GestureDetector(
      onTap: () {
        // TODO: 약속 상세 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meeting['name']} 상세 화면은 추후 구현 예정입니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 좌측 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상태 칩
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE8EDFE), // main010
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Text(
                      _getStatusLabel(meeting['status']!),
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
                  Text(
                    meeting['name']!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.50,
                    ),
                  ),
                  // 날짜/장소 정보 (있는 경우만)
                  if (meeting.containsKey('date') &&
                      meeting.containsKey('location')) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          meeting['date']!,
                          style: const TextStyle(
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
                        Text(
                          meeting['location']!,
                          style: const TextStyle(
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
                ],
              ),
            ),
            // 우측 화살표 아이콘
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF999999),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// 상태 라벨 변환
  String _getStatusLabel(String status) {
    switch (status) {
      case 'schedule':
        return '일정 이야기 중';
      case 'course':
        return '코스 이야기 중';
      case 'both':
        return '일정 · 코스 이야기 중';
      default:
        return '일정 이야기 중';
    }
  }
}
