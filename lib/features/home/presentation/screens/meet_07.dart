import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/features/home/presentation/screens/meet_09.dart';

/// 모임 만들기 7단계 - 날짜 투표 화면
class Meet07Screen extends StatefulWidget {
  final String meetingName;
  final int initialTab;
  final Set<DateTime>? initialSelectedDates;
  final bool openCalendarOnInit;

  const Meet07Screen({
    super.key,
    required this.meetingName,
    this.initialTab = 1,
    this.initialSelectedDates,
    this.openCalendarOnInit = false,
  });

  @override
  State<Meet07Screen> createState() => _Meet07ScreenState();
}

class _Meet07ScreenState extends State<Meet07Screen> {
  late int _selectedTab; // 0: 초대, 1: 일정

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _currentMonth = DateTime.now();
    _initialPageIndex = 12; // 중간부터 시작 (과거 12개월)
    _pageController = PageController(initialPage: _initialPageIndex);

    // 초기 선택된 날짜가 있으면 설정
    if (widget.initialSelectedDates != null) {
      _selectedDates.addAll(widget.initialSelectedDates!);
    }

    // 캘린더를 자동으로 열어야 하는 경우
    if (widget.openCalendarOnInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCalendarBottomSheet();
      });
    }
  }

  final Set<DateTime> _selectedDates = {}; // 투표할 날짜들
  late DateTime _currentMonth;
  late PageController _pageController;
  late int _initialPageIndex;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
        title: Text(
          widget.meetingName,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.33,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/link.svg',
              width: 24,
              height: 24,
            ),
            onPressed: _copyLinkToClipboard,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 탭 바
            _buildTabBar(),

            // 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // 만나는 날짜 섹션
                      _buildDateSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 바
  Widget _buildTabBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: _buildTab('초대', 0),
          ),
          Expanded(
            child: _buildTab('일정', 1),
          ),
        ],
      ),
    );
  }

  /// 개별 탭
  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // 초대 탭 클릭 시 meet_03로 돌아가기
          Navigator.pop(context);
        } else {
          setState(() {
            _selectedTab = index;
          });
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF1A49F1) // main050
                    : const Color(0xFFC5C8CE), // grey050
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 2,
            color: isSelected
                ? const Color(0xFF1A49F1) // main050
                : const Color(0xFFC5C8CE), // grey050
          ),
        ],
      ),
    );
  }

  /// 만나는 날짜 섹션
  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '만나는 날짜',
              style: TextStyle(
                color: Color(0xFF111111), // txt-primary
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFFC5C8CE), // grey050
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '투표 전',
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
          ],
        ),

        const SizedBox(height: 16),

        // 투표 카드
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFF7F8F9), // grey030
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '아직 일정이 정해지지 않았어요',
                style: TextStyle(
                  color: Color(0xFF505050), // txt-secondary
                  fontSize: 13,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),
              const SizedBox(height: 16),

              // 투표하기 버튼
              GestureDetector(
                onTap: _showCalendarBottomSheet,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF1A49F1), // main050
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text(
                    '투표하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 캘린더 바텀시트 표시
  void _showCalendarBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '만나는 날 정하기',
                      style: TextStyle(
                        color: Color(0xFF111111), // txt-primary
                        fontSize: 18,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: const ShapeDecoration(
                            color: Color(0xFFE9EBEE), // grey040
                            shape: CircleBorder(),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 캘린더
                Container(
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFD9D9D9),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _buildCalendar(setModalState),
                ),

                const SizedBox(height: 20),

                // 완료 버튼
                GestureDetector(
                  onTap: () {
                    if (_selectedDates.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('날짜를 선택해주세요'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // meet_09로 이동
                    Navigator.pop(context); // 바텀시트 닫기
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Meet09Screen(
                          meetingName: widget.meetingName,
                          votedDates: _selectedDates,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1A49F1), // main050
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '완료',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 커스텀 캘린더 위젯
  Widget _buildCalendar(StateSetter setModalState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 월 헤더 (화살표 포함)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 이전 달 버튼
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24, color: Color(0xFF111111)),
                onPressed: () {
                  if (_pageController.hasClients) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              // 연월 표시
              Text(
                '${_currentMonth.year}년 ${_currentMonth.month}월',
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
              // 다음 달 버튼
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 24, color: Color(0xFF111111)),
                onPressed: () {
                  if (_pageController.hasClients) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // 요일 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              return SizedBox(
                width: 40,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.38,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // 캘린더 PageView (스와이프 가능)
        SizedBox(
          height: 280, // 캘린더 그리드 높이
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setModalState(() {
                // 현재 달 기준으로 오프셋 계산
                final monthOffset = index - _initialPageIndex;
                _currentMonth = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + monthOffset,
                  1,
                );
              });
            },
            itemBuilder: (context, index) {
              // 현재 달 기준으로 오프셋 계산
              final monthOffset = index - _initialPageIndex;
              final displayMonth = DateTime(
                DateTime.now().year,
                DateTime.now().month + monthOffset,
                1,
              );
              return _buildCalendarGrid(setModalState, displayMonth);
            },
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  /// 캘린더 그리드 빌드
  Widget _buildCalendarGrid(StateSetter setModalState, DateTime displayMonth) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 0 = 일요일

    List<Widget> dayWidgets = [];

    // 빈 칸 추가 (월 시작 전)
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // 날짜 추가
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isSelected = _selectedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day
      );
      final isToday = _isSameDay(date, DateTime.now());

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setModalState(() {
              if (isSelected) {
                _selectedDates.removeWhere((d) =>
                  d.year == date.year && d.month == date.month && d.day == date.day
                );
              } else {
                _selectedDates.add(date);
              }
            });
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1A49F1) : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !isSelected
                  ? Border.all(color: const Color(0xFF1A49F1), width: 1)
                  : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : isToday
                        ? const Color(0xFF1A49F1)
                        : const Color(0xFF111111),
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
    }

    // 주 단위로 나누기
    List<Widget> weeks = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      final weekEnd = (i + 7 < dayWidgets.length) ? i + 7 : dayWidgets.length;
      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayWidgets.sublist(i, weekEnd),
          ),
        ),
      );
    }

    return Column(children: weeks);
  }

  /// 같은 날짜인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 클립보드에 링크 복사
  void _copyLinkToClipboard() {
    const linkUrl = 'http://약속링크 주소 url';
    Clipboard.setData(const ClipboardData(text: linkUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('링크가 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

}
