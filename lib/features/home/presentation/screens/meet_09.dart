import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/features/home/presentation/screens/meet_07.dart';

/// 모임 만들기 9단계 - 날짜 투표 확인 화면
class Meet09Screen extends StatefulWidget {
  final String meetingName;
  final Set<DateTime> votedDates;

  const Meet09Screen({
    super.key,
    required this.meetingName,
    required this.votedDates,
  });

  @override
  State<Meet09Screen> createState() => _Meet09ScreenState();
}

class _Meet09ScreenState extends State<Meet09Screen> {
  int _selectedTab = 1; // 0: 초대, 1: 일정
  bool _isCalendarExpanded = false;
  bool _isDateConfirmed = false; // 날짜가 확정되었는지 여부
  late PageController _pageController;
  late int _initialPageIndex;
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  DateTime? _confirmedDate; // 확정된 날짜

  // 하드코딩된 날짜 후보 (백엔드에서 받을 데이터)
  final Set<DateTime> _candidateDates = {
    DateTime(2025, 11, 19),
    DateTime(2025, 12, 1),
    DateTime(2025, 12, 7),
    DateTime(2025, 12, 9),
    DateTime(2025, 12, 10),
    DateTime(2025, 12, 16),
    DateTime(2025, 12, 23),
  };

  // 하드코딩된 유력한 날짜 (백엔드에서 받을 데이터)
  final Set<DateTime> _likelyDates = {
    DateTime(2025, 11, 19),
    DateTime(2025, 12, 1),
    DateTime(2025, 12, 9),
  };

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _initialPageIndex = 12;
    _pageController = PageController(initialPage: _initialPageIndex);
  }

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

                      const SizedBox(height: 24),

                      // 만나는 시간 섹션 (날짜가 확정된 경우에만 표시)
                      if (_isDateConfirmed) _buildTimeSection(),
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
                    ? const Color(0xFF1A49F1)
                    : const Color(0xFFC5C8CE),
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
                ? const Color(0xFF1A49F1)
                : const Color(0xFFC5C8CE),
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
                color: Color(0xFF111111),
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: ShapeDecoration(
                color: _isDateConfirmed
                    ? const Color(0xFF0A1D60) // main080 (투표 완료)
                    : const Color(0xFFE8EDFE), // main010 (투표 중)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isDateConfirmed ? '투표 완료' : '투표 중',
                style: TextStyle(
                  color: _isDateConfirmed
                      ? Colors.white
                      : const Color(0xFF1A49F1),
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

        // 투표 결과 카드 또는 확정된 날짜 카드
        _isDateConfirmed ? _buildConfirmedDateCard() : _buildVoteResultCard(),
      ],
    );
  }

  /// 투표 결과 카드
  Widget _buildVoteResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8F9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 유력한 날짜 표시 및 드롭다운
          GestureDetector(
            onTap: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _buildLikelyDatesText()),
                Icon(
                  _isCalendarExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: const Color(0xFF111111),
                ),
              ],
            ),
          ),

          // 캘린더 (드롭다운 시 표시)
          if (_isCalendarExpanded) ...[
            const SizedBox(height: 16),
            _buildExpandedCalendar(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 24),
            _buildAvailablePeople(),
          ],

          const SizedBox(height: 16),

          // 버튼들
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 날짜 확정
                    setState(() {
                      _isDateConfirmed = true;
                      _confirmedDate = DateTime(2025, 12, 9);
                      _isCalendarExpanded = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1.5,
                          color: Color(0xFF1A49F1),
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '확정하기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF1A49F1),
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // meet_07로 돌아가면서 캘린더 자동으로 열기
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Meet07Screen(
                          meetingName: widget.meetingName,
                          initialTab: 1,
                          initialSelectedDates: widget.votedDates,
                          openCalendarOnInit: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1A49F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      '수정하기',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 유력한 날짜 텍스트 생성
  Widget _buildLikelyDatesText() {
    final sortedDates = _likelyDates.toList()..sort();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 4,
      runSpacing: 4,
      children: [
        // 월별로 그룹화
        ...sortedDates.fold<Map<int, List<int>>>({}, (map, date) {
          map.putIfAbsent(date.month, () => []).add(date.day);
          return map;
        }).entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.key}월',
                style: const TextStyle(
                  color: Color(0xFF020101),
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              const SizedBox(width: 4),
              ...entry.value.map((day) => Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFF486DF4), // main040
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  '$day',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              )),
              const SizedBox(width: 8),
            ],
          );
        }),
        const Text(
          '유력해요!',
          style: TextStyle(
            color: Color(0xFF505050),
            fontSize: 13,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            height: 1.38,
          ),
        ),
      ],
    );
  }

  /// 확장된 캘린더
  Widget _buildExpandedCalendar() {
    return Container(
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
      child: Column(
        children: [
          // 월 헤더 (화살표 포함)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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

          // 캘린더 PageView
          SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  final monthOffset = index - _initialPageIndex;
                  _currentMonth = DateTime(
                    DateTime.now().year,
                    DateTime.now().month + monthOffset,
                    1,
                  );
                });
              },
              itemBuilder: (context, index) {
                final monthOffset = index - _initialPageIndex;
                final displayMonth = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + monthOffset,
                  1,
                );
                return _buildCalendarGrid(displayMonth);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 캘린더 그리드
  Widget _buildCalendarGrid(DateTime displayMonth) {
    final firstDayOfMonth = DateTime(displayMonth.year, displayMonth.month, 1);
    final lastDayOfMonth = DateTime(displayMonth.year, displayMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // 빈 칸 추가
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox(width: 40, height: 40));
    }

    // 날짜 추가
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(displayMonth.year, displayMonth.month, day);
      final isCandidate = _candidateDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day
      );
      final isLikely = _likelyDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day
      );
      final isSelected = _selectedDate != null &&
        _selectedDate!.year == date.year &&
        _selectedDate!.month == date.month &&
        _selectedDate!.day == date.day;
      final isToday = _isSameDay(date, DateTime.now());

      Color? backgroundColor;
      Color? borderColor;
      Color textColor = const Color(0xFF111111);

      if (isSelected) {
        backgroundColor = const Color(0xFFE8EDFE); // main010 (현재 선택한 날짜)
        textColor = const Color(0xFF1A49F1);
      } else if (isLikely) {
        backgroundColor = const Color(0xFF486DF4); // main040 (유력한 날짜)
        textColor = Colors.white;
      } else if (isCandidate) {
        backgroundColor = Colors.transparent; // 날짜 후보 (배경 없음)
        borderColor = const Color(0xFFB0C4F8); // main020
        textColor = const Color(0xFF486DF4);
      }

      if (isToday && !isSelected && !isLikely) {
        borderColor = const Color(0xFF1A49F1);
      }

      dayWidgets.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1)
                  : null,
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: isLikely || isSelected ? FontWeight.w700 : FontWeight.w400,
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

  /// 범례
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          const Color(0xFFE8EDFE),
          '현재 선택한 날짜',
          const Color(0xFF1A49F1),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          const Color(0xFF486DF4),
          '유력한 날짜',
          Colors.white,
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          Colors.transparent,
          '날짜 후보',
          const Color(0xFF486DF4),
          borderColor: const Color(0xFFB0C4F8),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color bgColor, String label, Color textColor, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1)
                : null,
          ),
          child: Text(
            '7',
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF505050),
            fontSize: 11,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 만날 수 있는 사람 섹션
  Widget _buildAvailablePeople() {
    // 하드코딩된 더미 데이터
    final List<Map<String, String>> people = [
      {'name': '남수빈', 'icon': 'food_S'},
      {'name': '양우열', 'icon': 'exhibit_S'},
      {'name': '김여명', 'icon': 'study_S'},
    ];

    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '만날 수 있는 사람',
                style: TextStyle(
                  color: Color(0xFF111111), // txt-primary
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${people.length}',
                style: const TextStyle(
                  color: Color(0xFF505050), // txt-secondary
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 사람 목록
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: people.map((person) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SVG 아이콘
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            'assets/icons/${person['icon']}.svg',
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 이름
                      Text(
                        person['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF111111), // txt-primary
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 확정된 날짜 카드
  Widget _buildConfirmedDateCard() {
    // 하드코딩: 12월 9일로 확정
    final confirmedDate = _confirmedDate ?? DateTime(2025, 12, 9);

    return Container(
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
          // 확정된 날짜 표시 및 드롭다운
          GestureDetector(
            onTap: () {
              setState(() {
                _isCalendarExpanded = !_isCalendarExpanded;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 날짜 표시
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${confirmedDate.month}월',
                      style: const TextStyle(
                        color: Color(0xFF020101),
                        fontSize: 18,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF102C91), // main070
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        '${confirmedDate.day}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          height: 1.43,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '만나요',
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
                // 드롭다운 아이콘
                Icon(
                  _isCalendarExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 24,
                  color: const Color(0xFF111111),
                ),
              ],
            ),
          ),

          // 캘린더 (드롭다운 시 표시)
          if (_isCalendarExpanded) ...[
            const SizedBox(height: 16),
            _buildExpandedCalendar(),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 24),
            _buildAvailablePeople(),
          ],

          const SizedBox(height: 16),

          // 다시 정하기 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                _isDateConfirmed = false;
                _confirmedDate = null;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: const Color(0xFF0A1D60), // main080
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                '다시 정하기',
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
    );
  }

  /// 만나는 시간 섹션
  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '만나는 시간',
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
                  color: Colors.white,
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
                onTap: () {
                  // TODO: 시간 투표 화면으로 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('시간 투표 화면은 추후 구현 예정입니다'),
                      duration: Duration(seconds: 2),
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
