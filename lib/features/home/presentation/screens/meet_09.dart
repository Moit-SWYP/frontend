import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/core/utils/share_link_utils.dart';
import 'package:moit/features/home/presentation/screens/meet_03.dart';
import 'package:moit/features/home/presentation/screens/meet_07.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
import 'package:moit/features/meeting/providers/vote_provider.dart';

/// 모임 만들기 9단계 - 날짜 투표 확인 화면
class Meet09Screen extends ConsumerStatefulWidget {
  final int? meetingId; // nullable: 모임 생성 중에는 null
  final String meetingName;
  final Set<DateTime> votedDates;

  const Meet09Screen({
    super.key,
    this.meetingId, // optional
    required this.meetingName,
    required this.votedDates,
  });

  @override
  ConsumerState<Meet09Screen> createState() => _Meet09ScreenState();
}

class _Meet09ScreenState extends ConsumerState<Meet09Screen> {
  int _selectedTab = 1; // 0: 초대, 1: 일정
  bool _isCalendarExpanded = false;
  late PageController _pageController;
  late int _initialPageIndex;
  late DateTime _currentMonth;
  DateTime? _selectedDate;
  bool _isGeneratingLink = false;
  String? _invitationLink;
  Set<DateTime> _allVotedDates = {}; // 모든 투표된 날짜 (날짜 후보)
  Set<DateTime> _selectedDates = {}; // 수정하기에서 선택한 날짜들
  bool _isTimeExpanded = false; // 시간 섹션 드롭다운 상태
  String? _selectedTimeSlot; // 선택된 시간 슬롯 (투표자 정보 표시용)

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    _initialPageIndex = 12;
    _pageController = PageController(initialPage: _initialPageIndex);

    // 화면 진입 시 투표 요약 로드 (meetingId가 있을 때만)
    if (widget.meetingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('📋 [Meet09] 투표 요약 로드 시작: ${widget.meetingId}');
        ref.read(voteProvider(widget.meetingId!).notifier).loadVoteSummary();
        _loadAllVotedDates();
      });
    }
  }

  /// 모든 투표된 날짜 로드 (날짜 후보)
  Future<void> _loadAllVotedDates() async {
    if (widget.meetingId == null) return;

    try {
      final dates = await ref
          .read(voteProvider(widget.meetingId!).notifier)
          .getAllVotedDates();

      if (mounted) {
        setState(() {
          _allVotedDates = dates.map((dateStr) {
            try {
              return DateTime.parse(dateStr);
            } catch (e) {
              print('⚠️ [Meet09] 날짜 파싱 실패: $dateStr');
              return null;
            }
          }).whereType<DateTime>().toSet();
        });
        print('✅ [Meet09] 모든 투표 날짜 로드 완료: ${_allVotedDates.length}개');
      }
    } catch (e) {
      print('❌ [Meet09] 모든 투표 날짜 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // meetingId가 있을 때만 voteProvider 사용
    final voteState = widget.meetingId != null
        ? ref.watch(voteProvider(widget.meetingId!))
        : null;

    // 에러 메시지 표시
    if (voteState?.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(voteState!.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        ref.read(voteProvider(widget.meetingId!).notifier).clearError();
      });
    }

    // API 데이터에서 날짜 정보 추출 (meetingId가 있을 때만)
    final candidateDates = voteState != null ? _getCandidateDates(voteState) : <DateTime>{};
    final likelyDates = voteState != null ? _getLikelyDates(voteState) : <DateTime>{};
    final isDateConfirmed = voteState?.summary?.confirmedDate != null;
    final confirmedDate = voteState?.summary?.confirmedDate != null
        ? DateTime.parse(voteState!.summary!.confirmedDate!)
        : null;

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

                      // 로딩 중 (meetingId가 있을 때만)
                      if (voteState != null && voteState.isLoading && voteState.summary == null)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else ...[
                        // 만나는 날짜 섹션
                        _buildDateSection(isDateConfirmed, confirmedDate, candidateDates, likelyDates),

                        const SizedBox(height: 24),

                        // 만나는 시간 섹션 (날짜가 확정된 경우에만 표시)
                        if (isDateConfirmed) _buildTimeSection(),
                      ],
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
          // 초대 탭 클릭 시 meet_03으로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Meet03Screen(
                meetingName: widget.meetingName,
                meetingId: widget.meetingId,
                initialTab: 0,
              ),
            ),
          );
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
  Widget _buildDateSection(
    bool isDateConfirmed,
    DateTime? confirmedDate,
    Set<DateTime> candidateDates,
    Set<DateTime> likelyDates,
  ) {
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
                color: isDateConfirmed
                    ? const Color(0xFF0A1D60) // main080 (투표 완료)
                    : const Color(0xFFE8EDFE), // main010 (투표 중)
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isDateConfirmed ? '투표 완료' : '투표 중',
                style: TextStyle(
                  color: isDateConfirmed
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
        isDateConfirmed
            ? _buildConfirmedDateCard(confirmedDate, candidateDates, likelyDates)
            : _buildVoteResultCard(candidateDates, likelyDates),
      ],
    );
  }

  /// 투표 결과 카드
  Widget _buildVoteResultCard(Set<DateTime> candidateDates, Set<DateTime> likelyDates) {
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
                Expanded(child: _buildLikelyDatesText(likelyDates)),
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
            _buildExpandedCalendar(candidateDates, likelyDates), // 날짜 투표 상태: confirmedDate 없음
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
                  onTap: () async {
                    // meetingId가 없으면 (모임 생성 중) 아무것도 안 함
                    print('🔍 [Meet09] 확정하기 버튼 클릭: meetingId=${widget.meetingId}');
                    if (widget.meetingId == null) {
                      print('❌ [Meet09] meetingId가 null입니다!');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('모임 생성을 완료한 후 날짜를 확정할 수 있습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      return;
                    }

                    // ✨ 추가: isLoading 체크 (중복 클릭 방지)
                    final voteState = ref.read(voteProvider(widget.meetingId!));
                    if (voteState.isLoading) {
                      print('⚠️ [Meet09] 이미 확정 처리 중입니다.');
                      return;
                    }

                    // 날짜 확정 API 호출
                    final success = await ref
                        .read(voteProvider(widget.meetingId!).notifier)
                        .confirmDate();

                    if (success && mounted) {
                      setState(() {
                        _isCalendarExpanded = false;
                      });
                    }
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
                    // 캘린더 바텀시트 열기
                    _showCalendarBottomSheet();
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
  Widget _buildLikelyDatesText(Set<DateTime> likelyDates) {
    final sortedDates = likelyDates.toList()..sort();

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
  Widget _buildExpandedCalendar(Set<DateTime> candidateDates, Set<DateTime> likelyDates, {DateTime? confirmedDate}) {
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
                return _buildCalendarGrid(displayMonth, candidateDates, likelyDates, confirmedDate: confirmedDate);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 캘린더 그리드
  Widget _buildCalendarGrid(DateTime displayMonth, Set<DateTime> candidateDates, Set<DateTime> likelyDates, {DateTime? confirmedDate}) {
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
      final isCandidate = candidateDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day
      );
      final isLikely = likelyDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day
      );
      final isSelected = _selectedDate != null &&
        _selectedDate!.year == date.year &&
        _selectedDate!.month == date.month &&
        _selectedDate!.day == date.day;
      final isToday = _isSameDay(date, DateTime.now());
      final isConfirmed = confirmedDate != null &&
        confirmedDate.year == date.year &&
        confirmedDate.month == date.month &&
        confirmedDate.day == date.day;

      Color? backgroundColor;
      Color? borderColor;
      Color textColor = const Color(0xFF111111);

      if (isConfirmed) {
        backgroundColor = const Color(0xFF102C91); // main070 (확정된 날짜)
        textColor = Colors.white;
      } else if (isSelected) {
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

  /// API 데이터에서 날짜 후보 추출 (모든 투표된 날짜)
  Set<DateTime> _getCandidateDates(VoteState voteState) {
    // _allVotedDates에 이미 모든 투표 날짜가 로드되어 있음
    // getAllVotedDates() API로 가져온 모든 투표 날짜 반환
    return _allVotedDates;
  }

  /// API 데이터에서 유력한 날짜 추출 (최다 득표 날짜)
  Set<DateTime> _getLikelyDates(VoteState voteState) {
    final dates = <DateTime>{};

    if (voteState.summary?.dateSummary?.topDates != null) {
      for (final dateStr in voteState.summary!.dateSummary!.topDates) {
        try {
          dates.add(DateTime.parse(dateStr));
        } catch (e) {
          print('⚠️ [Meet09] 날짜 파싱 실패: $dateStr');
        }
      }
    }

    return dates;
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
  Widget _buildConfirmedDateCard(DateTime? confirmedDate, Set<DateTime> candidateDates, Set<DateTime> likelyDates) {
    if (confirmedDate == null) {
      return const SizedBox.shrink();
    }

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
            _buildExpandedCalendar(candidateDates, likelyDates, confirmedDate: confirmedDate),
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 24),
            _buildAvailablePeople(),
          ],

          const SizedBox(height: 16),

          // 다시 정하기 버튼 (날짜 확정 취소)
          GestureDetector(
            onTap: () async {
              // meetingId가 없으면 아무것도 안 함
              if (widget.meetingId == null) return;

              final success = await ref
                  .read(voteProvider(widget.meetingId!).notifier)
                  .cancelDateConfirm();

              if (success && mounted) {
                setState(() {
                  _isCalendarExpanded = false;
                });
              }
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
    // meetingId가 있을 때만 voteState 사용
    final voteState = widget.meetingId != null
        ? ref.watch(voteProvider(widget.meetingId!))
        : null;

    // 시간 투표 완료 여부 확인
    final hasVotedTime = voteState?.summary?.timeSummary != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (투표 완료 시 드롭다운 추가)
        GestureDetector(
          onTap: hasVotedTime
              ? () {
                  setState(() {
                    _isTimeExpanded = !_isTimeExpanded;
                  });
                }
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: hasVotedTime
                          ? const Color(0xFF102C91) // main070 (투표 완료)
                          : const Color(0xFFC5C8CE), // grey050 (투표 전)
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      hasVotedTime ? '투표 완료' : '투표 전',
                      style: const TextStyle(
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
              if (hasVotedTime)
                Icon(
                  _isTimeExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: const Color(0xFF111111),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 투표 전 상태: 투표하기 버튼
        if (!hasVotedTime)
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
                  onTap: () async {
                    // meetingId가 없으면 아무것도 안 함
                    if (widget.meetingId == null) return;

                    // Bottom Sheet 표시 및 선택된 시간들 받기
                    final selectedTimes = await _showTimePickerBottomSheet();

                    if (selectedTimes != null && selectedTimes.isNotEmpty && mounted) {
                      // VoteProvider를 통해 시간 투표 제출
                      final success = await ref
                          .read(voteProvider(widget.meetingId!).notifier)
                          .voteTimes(selectedTimes.toList());

                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('시간 투표가 완료되었습니다'),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        // 투표 완료 후 첫 번째 시간 카드 자동 선택
                        final timeSummary = voteState?.summary?.timeSummary;
                        if (timeSummary != null && timeSummary.votedTimes.isNotEmpty) {
                          final sortedTimes = [...timeSummary.votedTimes]
                            ..sort((a, b) => b.count.compareTo(a.count));
                          setState(() {
                            _selectedTimeSlot = sortedTimes.first.time;
                            _isTimeExpanded = true;
                          });
                        }
                      }
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

        // 투표 완료 상태: 드롭다운으로 투표 결과 표시
        if (hasVotedTime && _isTimeExpanded && voteState?.summary?.timeSummary != null)
          _buildTimeVoteResult(voteState!.summary!.timeSummary!),
      ],
    );
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
      print('🔗 [Meet09] 초대 링크 생성 시작: meetingId=${widget.meetingId}');

      final invitationLink = await ref
          .read(meetingProvider.notifier)
          .getInvitationLink(widget.meetingId!);

      if (!mounted) return;

      if (invitationLink != null) {
        print('✅ [Meet09] 초대 링크 생성 성공: $invitationLink');
        setState(() {
          _invitationLink = invitationLink;
          _isGeneratingLink = false;
        });
        ShareLinkUtils.showLinkDialog(context, invitationLink);
      } else {
        print('❌ [Meet09] 초대 링크 생성 실패');
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
      print('❌ [Meet09] 초대 링크 생성 에러: $e');
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

  /// 날짜 수정을 위한 캘린더 바텀시트
  void _showCalendarBottomSheet() {
    // 기존 투표한 날짜로 초기화
    setState(() {
      _selectedDates = Set.from(widget.votedDates);
    });

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
                      '만나는 날 수정하기',
                      style: TextStyle(
                        color: Color(0xFF111111),
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
                            color: Color(0xFFE9EBEE),
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

                      print('📋 [Meet09] 날짜 재투표 시작: $dateStrings');

                      voteSuccess = await ref
                          .read(voteProvider(widget.meetingId!).notifier)
                          .voteDates(dateStrings);
                    }

                    // 로딩 닫기
                    if (!mounted) return;
                    Navigator.pop(context);  // 로딩 다이얼로그 닫기

                    // 결과 처리
                    if (voteSuccess) {
                      print('✅ [Meet09] 날짜 재투표 성공');

                      // 바텀시트 닫기
                      Navigator.pop(context);

                      // 투표 요약 다시 로드
                      await ref
                          .read(voteProvider(widget.meetingId!).notifier)
                          .loadVoteSummary();

                      // 모든 투표된 날짜 다시 로드
                      await _loadAllVotedDates();

                      // 성공 메시지
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('투표가 수정되었습니다'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      print('❌ [Meet09] 날짜 재투표 실패');

                      // 에러 메시지 표시
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('투표 수정에 실패했습니다. 다시 시도해주세요.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFF1A49F1),
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

  /// 캘린더 위젯 (바텀시트용)
  Widget _buildCalendar(StateSetter setModalState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 월 헤더
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
              // 현재 월 표시
              Text(
                '${_currentMonth.year}년 ${_currentMonth.month}월',
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
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

        // 요일 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: day == '일'
                          ? const Color(0xFFFF4545)
                          : day == '토'
                              ? const Color(0xFF1A49F1)
                              : const Color(0xFF666666),
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // 날짜 그리드 (PageView)
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setModalState(() {
                final offset = index - _initialPageIndex;
                _currentMonth = DateTime(
                  DateTime.now().year,
                  DateTime.now().month + offset,
                );
              });
            },
            itemBuilder: (context, pageIndex) {
              final offset = pageIndex - _initialPageIndex;
              final displayMonth = DateTime(
                DateTime.now().year,
                DateTime.now().month + offset,
              );
              return _buildMonthGrid(displayMonth, setModalState);
            },
          ),
        ),
      ],
    );
  }

  /// 월별 날짜 그리드
  Widget _buildMonthGrid(DateTime month, StateSetter setModalState) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final startWeekday = firstDay.weekday % 7;
    final totalDays = lastDay.day;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    List<Widget> dayWidgets = [];

    // 빈 공간 추가
    for (int i = 0; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // 날짜 추가
    for (int day = 1; day <= totalDays; day++) {
      final date = DateTime(month.year, month.month, day);
      final dateOnly = DateTime(date.year, date.month, date.day);
      final isSelected = _selectedDates.any((d) =>
          d.year == dateOnly.year &&
          d.month == dateOnly.month &&
          d.day == dateOnly.day);
      final isPast = dateOnly.isBefore(todayDate);

      dayWidgets.add(
        GestureDetector(
          onTap: isPast
              ? null
              : () {
                  setModalState(() {
                    if (isSelected) {
                      _selectedDates.removeWhere((d) =>
                          d.year == dateOnly.year &&
                          d.month == dateOnly.month &&
                          d.day == dateOnly.day);
                    } else {
                      _selectedDates.add(dateOnly);
                    }
                  });
                },
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1A49F1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isPast
                      ? const Color(0xFFD9D9D9)
                      : isSelected
                          ? Colors.white
                          : date.weekday == 7
                              ? const Color(0xFFFF4545)
                              : date.weekday == 6
                                  ? const Color(0xFF1A49F1)
                                  : const Color(0xFF111111),
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: dayWidgets,
      ),
    );
  }

  /// 30분 간격 시간 목록 생성 (00:00 ~ 23:30)
  List<String> _generateTimeSlots() {
    final times = <String>[];
    for (int hour = 0; hour < 24; hour++) {
      times.add('${hour.toString().padLeft(2, '0')}:00');
      times.add('${hour.toString().padLeft(2, '0')}:30');
    }
    return times;
  }

  /// HH:mm 형식을 12시간 형식으로 변환 (예: "14:30" → "오후 02:30")
  String _formatTimeToDisplay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];

    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$period ${displayHour.toString().padLeft(2, '0')}:$minute';
  }

  /// 시간 투표 결과 표시
  Widget _buildTimeVoteResult(timeSummary) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 최다 득표 시간 표시
          _buildTopTimeDisplay(timeSummary.topTimes),

          const SizedBox(height: 16),

          // 2. Top 3 시간 카드 (수평 스크롤)
          _buildTimeCards(timeSummary.votedTimes),

          const SizedBox(height: 16),

          // 3. 선택된 시간의 투표자 정보
          if (_selectedTimeSlot != null) _buildAvailablePeopleForTime(_selectedTimeSlot!),

          if (_selectedTimeSlot != null) const SizedBox(height: 26),

          // 4. 수정하기 버튼
          _buildEditButton(),
        ],
      ),
    );
  }

  /// 최다 득표 시간 표시
  Widget _buildTopTimeDisplay(List<String> topTimes) {
    if (topTimes.isEmpty) return const SizedBox.shrink();

    final topTime = topTimes.first;
    final displayTime = _formatTimeToDisplay(topTime);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              displayTime,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF020101),
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '유력해요!',
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
    );
  }

  /// Top 3 시간 카드를 수평 스크롤로 표시
  Widget _buildTimeCards(List votedTimes) {
    // votedTimes를 count 기준으로 내림차순 정렬
    final sortedTimes = [...votedTimes]..sort((a, b) => b.count.compareTo(a.count));

    // 상위 3개만 표시
    final topThree = sortedTimes.take(3).toList();

    // 자동 선택: 첫 번째 카드가 선택되지 않았으면 자동 선택
    if (_selectedTimeSlot == null && topThree.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedTimeSlot = topThree.first.time;
          });
        }
      });
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: topThree.asMap().entries.map((entry) {
          final index = entry.key;
          final votedTime = entry.value;
          final isSelected = _selectedTimeSlot == votedTime.time;

          return Padding(
            padding: EdgeInsets.only(right: index < topThree.length - 1 ? 12 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeSlot = votedTime.time;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: ShapeDecoration(
                  color: isSelected
                      ? const Color(0xFFA3B6F9) // main020
                      : const Color(0xFFFDFDFD),
                  shape: RoundedRectangleBorder(
                    side: isSelected
                        ? BorderSide.none
                        : const BorderSide(width: 1, color: Color(0xFFC5C8CE)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatTimeToDisplay(votedTime.time),
                      style: const TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.50,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${votedTime.count}',
                      style: const TextStyle(
                        color: Color(0xFF505050),
                        fontSize: 14,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 특정 시간에 투표한 사람들 표시
  Widget _buildAvailablePeopleForTime(String time) {
    if (widget.meetingId == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: ref.read(voteProvider(widget.meetingId!).notifier).getTimeVoters(time),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final voters = snapshot.data!.voters;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  '${voters.length}',
                  style: const TextStyle(
                    color: Color(0xFF505050), // color-secondary
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: voters.map((voter) {
                  return Container(
                    width: 40,
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        // 캐릭터 아이콘
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: SvgPicture.asset(
                            _getCharacterIconPath(voter.characterType),
                            width: 32,
                            height: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 닉네임
                        Text(
                          voter.nickname,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            height: 1.43,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 캐릭터 타입을 아이콘 경로로 변환
  String _getCharacterIconPath(String characterType) {
    final type = characterType.toLowerCase();
    return 'assets/icons/character/${type}_S.svg';
  }

  /// 수정하기 버튼
  Widget _buildEditButton() {
    return GestureDetector(
      onTap: () async {
        if (widget.meetingId == null) return;

        final selectedTimes = await _showTimePickerBottomSheet();

        if (selectedTimes != null && selectedTimes.isNotEmpty && mounted) {
          final success = await ref
              .read(voteProvider(widget.meetingId!).notifier)
              .voteTimes(selectedTimes.toList());

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('시간 투표가 수정되었습니다')),
            );
          }
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
    );
  }

  /// 시간 선택 Bottom Sheet 표시
  Future<Set<String>?> _showTimePickerBottomSheet() async {
    final timeSlots = _generateTimeSlots();
    final selectedTimes = <String>{};

    return showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 헤더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '시간 정하기',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 18,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1.33,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 시간 목록 (스크롤 가능 - 단일 열)
                  Expanded(
                    child: ListView.separated(
                      itemCount: timeSlots.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final time = timeSlots[index];
                        final isSelected = selectedTimes.contains(time);
                        final displayTime = _formatTimeToDisplay(time);
                        final parts = displayTime.split(' ');
                        final period = parts[0]; // "오전" or "오후"
                        final timeStr = parts[1]; // "12:00"

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedTimes.remove(time);
                              } else {
                                selectedTimes.add(time);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              border: isSelected
                                  ? Border.all(
                                      color: const Color(0xFF486DF4), // main040
                                      width: 1,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      timeStr,
                                      style: const TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 13,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 1.50,
                                        letterSpacing: -0.33,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      period == '오전' ? 'AM' : 'PM',
                                      style: const TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 13,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                        height: 1.50,
                                        letterSpacing: -0.33,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isSelected)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF486DF4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 24, height: 24),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 완료 버튼
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, selectedTimes);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: const Color(0xFF1A49F1),
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
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
