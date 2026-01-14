import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/core/utils/share_link_utils.dart';
import 'package:moit/features/home/presentation/screens/meet_09.dart';
import 'package:moit/features/home/presentation/screens/meet_17.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
import 'package:moit/features/meeting/providers/vote_provider.dart';

/// 모임 만들기 7단계 - 날짜 투표 화면
class Meet07Screen extends ConsumerStatefulWidget {
  final String meetingName;
  final int? meetingId;
  final int initialTab;
  final Set<DateTime>? initialSelectedDates;
  final bool openCalendarOnInit;

  const Meet07Screen({
    super.key,
    required this.meetingName,
    this.meetingId,
    this.initialTab = 1,
    this.initialSelectedDates,
    this.openCalendarOnInit = false,
  });

  @override
  ConsumerState<Meet07Screen> createState() => _Meet07ScreenState();
}

class _Meet07ScreenState extends ConsumerState<Meet07Screen> {
  bool _isGeneratingLink = false;
  String? _invitationLink;
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
                  onTap: () async {
                    if (_selectedDates.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('날짜를 선택해주세요'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // 로딩 표시
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    // 날짜 투표 API 호출
                    bool voteSuccess = false;
                    if (widget.meetingId != null) {
                      final dateStrings = _selectedDates
                          .map((date) =>
                            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}')
                          .toList();

                      print('📋 [Meet07] 날짜 투표 시작: $dateStrings');

                      voteSuccess = await ref
                          .read(voteProvider(widget.meetingId!).notifier)
                          .voteDates(dateStrings);
                    }

                    // 로딩 닫기
                    if (!mounted) return;
                    Navigator.pop(context);  // 로딩 다이얼로그 닫기

                    // 결과 처리
                    if (voteSuccess) {
                      // isHost 확인
                      final voteState = ref.read(voteProvider(widget.meetingId!));
                      final isHost = voteState.isHost;

                      print('✅ [Meet07] 날짜 투표 성공 (isHost: $isHost)');

                      // 바텀시트 닫기
                      Navigator.pop(context);

                      if (isHost) {
                        // HOST → Meet09 (확정하기 버튼 있음)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Meet09Screen(
                              meetingName: widget.meetingName,
                              meetingId: widget.meetingId,
                              votedDates: _selectedDates,
                            ),
                          ),
                        );
                      } else {
                        // MEMBER → Meet17 (확정하기 버튼 없음)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Meet17Screen(
                              meetingName: widget.meetingName,
                              meetingId: widget.meetingId,
                              votedDates: _selectedDates,
                            ),
                          ),
                        );
                      }
                    } else {
                      print('❌ [Meet07] 날짜 투표 실패');

                      // 에러 메시지 표시
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('투표에 실패했습니다. 다시 시도해주세요.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
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
      // 오늘 날짜의 시작 시간 (00:00:00)
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final isPastDate = date.isBefore(today);

      dayWidgets.add(
        GestureDetector(
          onTap: isPastDate ? null : () {
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
                color: isPastDate
                    ? const Color(0xFFCCCCCC) // 과거 날짜는 회색 처리
                    : isSelected
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

  /// 링크 공유 다이얼로그
  void _copyLinkToClipboard() async {
    // 모임 ID가 없으면 에러 표시
    if (widget.meetingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모임 정보를 찾을 수 없습니다.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 링크가 이미 생성되었으면 바로 다이얼로그 표시
    if (_invitationLink != null) {
      ShareLinkUtils.showLinkDialog(context, _invitationLink!);
      return;
    }

    // 링크 생성 중 표시
    setState(() {
      _isGeneratingLink = true;
    });

    try {
      print('🔗 [Meet07] 초대 링크 생성 시작: meetingId=${widget.meetingId}');

      final invitationLink = await ref
          .read(meetingProvider.notifier)
          .getInvitationLink(widget.meetingId!);

      if (!mounted) return;

      if (invitationLink != null) {
        print('✅ [Meet07] 초대 링크 생성 성공: $invitationLink');
        setState(() {
          _invitationLink = invitationLink;
          _isGeneratingLink = false;
        });
        ShareLinkUtils.showLinkDialog(context, invitationLink);
      } else {
        print('❌ [Meet07] 초대 링크 생성 실패');
        setState(() {
          _isGeneratingLink = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('초대 링크 생성에 실패했습니다.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ [Meet07] 초대 링크 생성 에러: $e');
      if (!mounted) return;

      setState(() {
        _isGeneratingLink = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('초대 링크 생성 중 오류가 발생했습니다.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

}
