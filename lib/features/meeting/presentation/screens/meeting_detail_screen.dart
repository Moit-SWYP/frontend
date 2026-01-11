import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/core/utils/date_formatter.dart';
import 'package:moit/core/utils/share_link_utils.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/data/models/vote_summary_response.dart';
import 'package:moit/features/meeting/providers/vote_provider.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
import 'package:moit/features/home/presentation/screens/meet_03.dart';
import 'package:moit/features/member/data/models/character_type.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

/// 모임 상세 화면
/// MeetingBrief 기본 정보 + 투표 요약 정보 + 캘린더 + 날짜별 투표자 표시
class MeetingDetailScreen extends ConsumerStatefulWidget {
  final MeetingBrief meeting;

  const MeetingDetailScreen({
    super.key,
    required this.meeting,
  });

  @override
  ConsumerState<MeetingDetailScreen> createState() =>
      _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime; // 선택된 시간
  VotersResponse? _selectedDateVoters;
  VotersResponse? _selectedTimeVoters; // 선택된 시간의 투표자
  bool _isLoadingVoters = false;
  bool _isGeneratingLink = false;
  String? _invitationLink;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 투표 요약 로드 (캐시된 데이터가 없을 때만)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(voteProvider(widget.meeting.meetingId));

      // 이미 데이터가 있으면 다시 로드하지 않음 (상태 유지)
      if (currentState.summary == null && !currentState.isLoading) {
        print('📋 [MeetingDetail] 투표 요약 로드 시작: ${widget.meeting.meetingId}');
        ref
            .read(voteProvider(widget.meeting.meetingId).notifier)
            .loadVoteSummary();
      } else {
        print('✅ [MeetingDetail] 캐시된 투표 데이터 사용 (meetingId: ${widget.meeting.meetingId})');
      }
    });
  }

  /// 날짜 선택 시 해당 날짜의 투표자 목록 조회
  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _isLoadingVoters = true;
    });

    print('📅 [MeetingDetail] 날짜 선택: ${DateFormat('yyyy-MM-dd').format(selectedDay)}');

    try {
      // 선택된 날짜의 투표자 조회
      final dateString = DateFormat('yyyy-MM-dd').format(selectedDay);
      final voters = await ref
          .read(voteProvider(widget.meeting.meetingId).notifier)
          .getDateVoters(dateString);

      if (mounted) {
        setState(() {
          _selectedDateVoters = voters;
          _isLoadingVoters = false;
        });
      }
    } catch (e) {
      print('❌ [MeetingDetail] 투표자 조회 실패: $e');
      if (mounted) {
        setState(() {
          _selectedDateVoters = null;
          _isLoadingVoters = false;
        });
      }
    }
  }

  /// 시간 선택 시 해당 시간의 투표자 목록 조회
  Future<void> _onTimeSelected(String time) async {
    setState(() {
      _selectedTime = time;
      _isLoadingVoters = true;
    });

    print('🕐 [MeetingDetail] 시간 선택: $time');

    try {
      // 선택된 시간의 투표자 조회
      final voters = await ref
          .read(voteProvider(widget.meeting.meetingId).notifier)
          .getTimeVoters(time);

      if (mounted) {
        setState(() {
          _selectedTimeVoters = voters;
          _isLoadingVoters = false;
        });
      }
    } catch (e) {
      print('❌ [MeetingDetail] 시간 투표자 조회 실패: $e');
      if (mounted) {
        setState(() {
          _selectedTimeVoters = null;
          _isLoadingVoters = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수 호출

    final voteState = ref.watch(voteProvider(widget.meeting.meetingId));

    // 에러 메시지 표시
    if (voteState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(voteState.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        ref
            .read(voteProvider(widget.meeting.meetingId).notifier)
            .clearError();
      });
    }

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
          widget.meeting.title,
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
          // 초대 링크 버튼
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/link.svg',
              width: 24,
              height: 24,
            ),
            onPressed: _showLinkShareDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 탭 (초대 / 일정)
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE9EBEE),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // 초대 탭 클릭 시 Meet03Screen으로 이동
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Meet03Screen(
                                meetingName: widget.meeting.title,
                                meetingId: widget.meeting.meetingId,
                                initialTab: 0, // 초대 탭
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: const Text(
                            '초대',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFC5C8CE),
                              fontSize: 16,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF1A49F1),
                              width: 2,
                            ),
                          ),
                        ),
                        child: const Text(
                          '일정',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1A49F1),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 만나는 날짜 섹션
                    const Text(
                      '만나는 날짜',
                      style: TextStyle(
                        color: Color(0xFF111111),
                        fontSize: 18,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔥 투표 여부에 따라 UI 분기
                    if (voteState.hasVotedDate) ...[
                      // meet09: 투표 완료 상태 - 투표한 날짜 칩 표시
                      const Text(
                        '내가 투표한 날짜',
                        style: TextStyle(
                          color: Color(0xFF111111),
                          fontSize: 14,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (voteState.summary?.dateSummary?.votedDates ?? [])
                            .map((dateStr) {
                          // yyyy-MM-dd 형식을 M월 d일로 변환
                          final parts = dateStr.split('-');
                          final month = int.parse(parts[1]);
                          final day = int.parse(parts[2]);
                          final displayText = '$month월 $day일';

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8EDFE), // main010
                              border: Border.all(
                                color: const Color(0xFF1A49F1), // main050
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                color: Color(0xFF1A49F1), // main050
                                fontSize: 14,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      // meet07: 투표 전 상태 - 캘린더 표시
                      // 투표 종료 안내
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1A49F1),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '유력해요!',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 14,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 캘린더
                      Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE9EBEE),
                          width: 1,
                        ),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: _onDaySelected,
                        locale: 'ko_KR',
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                          ),
                          leftChevronIcon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF111111),
                          ),
                          rightChevronIcon: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF111111),
                          ),
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: const Color(0xFF1A49F1).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF1A49F1),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(
                            color: Color(0xFF1A49F1),
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                          selectedTextStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                          defaultTextStyle: const TextStyle(
                            color: Color(0xFF111111),
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                          weekendTextStyle: const TextStyle(
                            color: Color(0xFF111111),
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            color: Color(0xFF999999),
                            fontSize: 12,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 투표 현황 표시 (하단)
                    Row(
                      children: [
                        // 현재 선택한 날짜
                        _buildVoteStatusBadge(
                          icon: Icons.calendar_today,
                          color: const Color(0xFF1A49F1),
                          label: '현재 선택한 날짜',
                          count: 7,
                        ),
                        const SizedBox(width: 12),
                        // 유력한 날짜
                        _buildVoteStatusBadge(
                          icon: Icons.calendar_today,
                          color: const Color(0xFF1A49F1),
                          label: '유력한 날짜',
                          count: 7,
                        ),
                      ],
                    ),
                    ], // else 블록 닫기

                    const SizedBox(height: 32),

                    // 만날 수 있는 사람 섹션
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '만날 수 있는 사람',
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 18,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A49F1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '투표 중',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 선택된 날짜가 없는 경우
                    if (_selectedDay == null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '날짜를 선택해주세요',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    // 투표자 목록 로딩 중
                    if (_selectedDay != null && _isLoadingVoters)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),

                    // 투표자 목록 표시
                    if (_selectedDay != null &&
                        !_isLoadingVoters &&
                        _selectedDateVoters != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '만날 수 있는 사람 ${_selectedDateVoters!.voterCount}',
                            style: const TextStyle(
                              color: Color(0xFF111111),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 투표자 아이콘 + 이름 리스트
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: _selectedDateVoters!.voters.map((voter) {
                              // String characterType을 CharacterType enum으로 변환
                              final characterType = CharacterTypeExtension.fromJson(voter.characterType);

                              return Column(
                                children: [
                                  // 캐릭터 아이콘
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF7F8F9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        characterType.getIconPath('S'),
                                        width: 32,
                                        height: 32,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // 이름
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      voter.nickname,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF111111),
                                        fontSize: 12,
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                    // 투표자 없음
                    if (_selectedDay != null &&
                        !_isLoadingVoters &&
                        (_selectedDateVoters == null ||
                            _selectedDateVoters!.voters.isEmpty))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '해당 날짜에 투표한 멤버가 없습니다',
                            style: TextStyle(
                              color: Color(0xFF999999),
                              fontSize: 14,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // 시간 투표 섹션 (날짜 확정 후 표시)
                    if (voteState.summary?.confirmedDate != null &&
                        voteState.summary?.confirmedTime == null)
                      ..._buildTimeVotingSection(voteState),

                    // 시간 확정 후 섹션
                    if (voteState.summary?.confirmedTime != null)
                      ..._buildTimeConfirmedSection(voteState),

                    const SizedBox(height: 32),

                    // 하단 버튼 (확정하기 / 수정하기)
                    // 날짜 투표 중일 때만 표시
                    if (voteState.summary?.confirmedDate == null)
                      Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              print('📝 [MeetingDetail] 확정하기 클릭');

                              // 권한 및 상태 검증
                              if (!voteState.isHost) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('호스트만 날짜를 확정할 수 있습니다.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // 투표 데이터가 있는지 확인
                              if (voteState.summary?.dateSummary == null ||
                                  voteState.summary!.dateSummary!.topDates.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('투표 데이터가 없습니다. 먼저 날짜 투표를 진행해주세요.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              // 확정 확인 다이얼로그
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('날짜 확정'),
                                  content: const Text('최다 득표 날짜로 확정하시겠습니까?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('취소'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('확정'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && mounted) {
                                // 확정 API 호출
                                final success = await ref
                                    .read(meetingProvider.notifier)
                                    .confirmMeeting(widget.meeting.meetingId);

                                if (success && mounted) {
                                  // 투표 요약 다시 로드
                                  await ref
                                      .read(voteProvider(widget.meeting.meetingId).notifier)
                                      .loadVoteSummary();

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('날짜가 확정되었습니다.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF1A49F1),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Center(
                                child: Text(
                                  '확정하기',
                                  style: TextStyle(
                                    color: Color(0xFF1A49F1),
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              print('📝 [MeetingDetail] 수정하기 클릭');
                              // TODO: 수정 로직
                            },
                            child: Container(
                              height: 56,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A49F1),
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: const Center(
                                child: Text(
                                  '수정하기',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 투표 현황 배지 위젯
  Widget _buildVoteStatusBadge({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE9EBEE)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF999999),
                fontSize: 10,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 시간 선택 바텀시트 표시
  Future<void> _showTimeSelectionBottomSheet(BuildContext context) async {
    final selectedTime = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TimeSelectionBottomSheet(),
    );

    if (selectedTime != null && mounted) {
      print('🕐 [MeetingDetail] 선택된 시간: $selectedTime');

      // 시간 투표 API 호출
      final timeSummary = await ref
          .read(voteProvider(widget.meeting.meetingId).notifier)
          .voteTimes([selectedTime]);

      if (timeSummary != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('시간 투표가 완료되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// 시간 투표 섹션 (날짜 확정 후)
  List<Widget> _buildTimeVotingSection(VoteState voteState) {
    final timeSummary = voteState.summary?.timeSummary;
    final topTime = timeSummary?.topTimes.isNotEmpty == true
        ? timeSummary!.topTimes.first
        : null;
    final hasVotedTime = voteState.hasVotedTime;
    final isHost = voteState.isHost;

    return [
      const SizedBox(height: 24),

      // 제목 및 투표 상태 배지
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '만나는 시간',
            style: TextStyle(
              color: Color(0xFF111111),
              fontSize: 18,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: hasVotedTime ? const Color(0xFF1A49F1) : const Color(0xFFE9EBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              hasVotedTime ? '투표 완료' : '투표 전',
              style: TextStyle(
                color: hasVotedTime ? Colors.white : const Color(0xFF999999),
                fontSize: 12,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),

      // 모임원: 투표 전 안내 메시지 또는 투표하기 버튼
      if (!isHost && !hasVotedTime)
        Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  '아직 일정이 정해지지 않았어요',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => _showTimeSelectionBottomSheet(context),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A49F1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Center(
                  child: Text(
                    '투표하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

      // 유력 시간 안내 (투표 후)
      if (hasVotedTime && topTime != null)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A49F1),
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$topTime 유력해요!',
                  style: const TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

      if (hasVotedTime && topTime != null) const SizedBox(height: 16),

      // 시간대 칩 리스트 (투표 후 - 상위 3개, meet22 스타일)
      if (!isHost && hasVotedTime && timeSummary?.votedTimes.isNotEmpty == true)
        Row(
          children: timeSummary!.votedTimes.take(3).map((votedTime) {
            final isSelected = _selectedTime == votedTime.time;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onTimeSelected(votedTime.time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE8EEFF) : Colors.white,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1A49F1) : const Color(0xFFE9EBEE),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          votedTime.time,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF1A49F1) : const Color(0xFF111111),
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${votedTime.count}',
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF1A49F1) : const Color(0xFF666666),
                            fontSize: 14,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

      // 방장용: 전체 시간대 리스트
      if (isHost && timeSummary?.votedTimes.isNotEmpty == true)
        ...timeSummary!.votedTimes.map((votedTime) {
          final isSelected = _selectedTime == votedTime.time;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => _onTimeSelected(votedTime.time),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFE8EEFF) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A49F1) : const Color(0xFFE9EBEE),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      votedTime.time,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF1A49F1) : const Color(0xFF111111),
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1A49F1)
                            : const Color(0xFFF7F8F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${votedTime.count}명',
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF666666),
                          fontSize: 13,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),

      if (hasVotedTime) const SizedBox(height: 24),

      // 만날 수 있는 사람 (시간 투표자) - 투표 후에만 표시
      if (hasVotedTime)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '만날 수 있는 사람',
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_selectedTime != null && _selectedTimeVoters != null)
              Text(
                '${_selectedTimeVoters!.voterCount}',
                style: const TextStyle(
                  color: Color(0xFF111111),
                  fontSize: 18,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),

      if (hasVotedTime) const SizedBox(height: 16),

      // 시간 선택 안 됨 (투표 후에만 표시)
      if (hasVotedTime && _selectedTime == null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              '시간을 선택해주세요',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

      // 투표자 목록 로딩 중 (투표 후에만 표시)
      if (hasVotedTime && _selectedTime != null && _isLoadingVoters)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),

      // 투표자 목록 표시 (투표 후에만 표시)
      if (hasVotedTime &&
          _selectedTime != null &&
          !_isLoadingVoters &&
          _selectedTimeVoters != null)
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _selectedTimeVoters!.voters.map((voter) {
            // String characterType을 CharacterType enum으로 변환
            final characterType = CharacterTypeExtension.fromJson(voter.characterType);

            return Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      characterType.getIconPath('S'),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 60,
                  child: Text(
                    voter.nickname,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),

      // 투표자 없음 (투표 후에만 표시)
      if (hasVotedTime &&
          _selectedTime != null &&
          !_isLoadingVoters &&
          (_selectedTimeVoters == null || _selectedTimeVoters!.voters.isEmpty))
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              '해당 시간에 투표한 멤버가 없습니다',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

      const SizedBox(height: 32),

      // 시간 확정 버튼 (방장만)
      if (voteState.isHost)
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  print('📝 [MeetingDetail] 시간 확정하기 클릭');

                  // 투표 데이터가 있는지 확인
                  if (timeSummary?.topTimes.isEmpty ?? true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('시간 투표 데이터가 없습니다.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // 확정 확인 다이얼로그
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('시간 확정'),
                      content: const Text('최다 득표 시간으로 확정하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('확정'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    final success = await ref
                        .read(voteProvider(widget.meeting.meetingId).notifier)
                        .confirmTime();

                    if (success && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('시간이 확정되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF1A49F1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Text(
                      '확정하기',
                      style: TextStyle(
                        color: Color(0xFF1A49F1),
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  print('📝 [MeetingDetail] 시간 수정하기 클릭');
                  // TODO: 시간 수정 로직
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A49F1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Text(
                      '수정하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
    ];
  }

  /// 시간 확정 후 섹션
  List<Widget> _buildTimeConfirmedSection(VoteState voteState) {
    final confirmedTime = voteState.summary?.confirmedTime;

    return [
      const SizedBox(height: 24),

      // 제목
      const Text(
        '만나는 시간',
        style: TextStyle(
          color: Color(0xFF111111),
          fontSize: 18,
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),

      // 확정된 시간 표시
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEFF),
          border: Border.all(
            color: const Color(0xFF1A49F1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF1A49F1),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  confirmedTime ?? '',
                  style: const TextStyle(
                    color: Color(0xFF1A49F1),
                    fontSize: 20,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A49F1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '투표 완료',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 24),

      // 방장 전용: 다시 정하기 버튼
      if (voteState.isHost)
        GestureDetector(
          onTap: () async {
            print('📝 [MeetingDetail] 시간 다시 정하기 클릭');

            // 확인 다이얼로그
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('시간 다시 정하기'),
                content: const Text('확정된 시간을 취소하고 다시 투표하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('확인'),
                  ),
                ],
              ),
            );

            if (confirmed == true && mounted) {
              final success = await ref
                  .read(voteProvider(widget.meeting.meetingId).notifier)
                  .cancelTimeConfirm();

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('시간 확정이 취소되었습니다.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF1A49F1),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Center(
              child: Text(
                '다시 정하기',
                style: TextStyle(
                  color: Color(0xFF1A49F1),
                  fontSize: 16,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
    ];
  }

  /// 링크 공유 다이얼로그
  void _showLinkShareDialog() async {
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
      print('🔗 [MeetingDetail] 초대 링크 생성 시작: meetingId=${widget.meeting.meetingId}');

      final invitationLink = await ref
          .read(meetingProvider.notifier)
          .getInvitationLink(widget.meeting.meetingId);

      if (!mounted) return;

      if (invitationLink != null) {
        print('✅ [MeetingDetail] 초대 링크 생성 성공: $invitationLink');
        setState(() {
          _invitationLink = invitationLink;
          _isGeneratingLink = false;
        });
        ShareLinkUtils.showLinkDialog(context, invitationLink);
      } else {
        print('❌ [MeetingDetail] 초대 링크 생성 실패');
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
      print('❌ [MeetingDetail] 초대 링크 생성 에러: $e');
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

/// 시간 선택 바텀시트 위젯
class _TimeSelectionBottomSheet extends StatefulWidget {
  @override
  State<_TimeSelectionBottomSheet> createState() => _TimeSelectionBottomSheetState();
}

class _TimeSelectionBottomSheetState extends State<_TimeSelectionBottomSheet> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late FixedExtentScrollController _periodController;

  int _selectedHour = 0; // 0-11 (12시간제)
  int _selectedMinute = 0; // 0 or 30
  int _selectedPeriod = 0; // 0: 오전, 1: 오후

  final List<String> _hours = List.generate(12, (i) => '${i + 1}');
  final List<String> _minutes = ['00', '30'];
  final List<String> _periods = ['오전', '오후'];

  @override
  void initState() {
    super.initState();
    // 기본값: 오후 1시 (13:00)
    _selectedHour = 0; // 1시
    _selectedMinute = 0; // 00분
    _selectedPeriod = 1; // 오후

    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
    _periodController = FixedExtentScrollController(initialItem: _selectedPeriod);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _periodController.dispose();
    super.dispose();
  }

  String _getFormattedTime() {
    final hour = _selectedHour + 1; // 1-12
    final minute = _minutes[_selectedMinute];
    final period = _periods[_selectedPeriod];

    // 24시간 형식으로 변환 (HH:mm)
    int hour24;
    if (period == '오전') {
      hour24 = hour == 12 ? 0 : hour;
    } else {
      hour24 = hour == 12 ? 12 : hour + 12;
    }

    return '${hour24.toString().padLeft(2, '0')}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE9EBEE),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '시간 정하기',
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF111111),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // 시간 선택 휠
            SizedBox(
              height: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 오전/오후
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _periodController,
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedPeriod = index;
                        });
                      },
                      children: _periods
                          .map((period) => Center(
                                child: Text(
                                  period,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // 시
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _hourController,
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedHour = index;
                        });
                      },
                      children: _hours
                          .map((hour) => Center(
                                child: Text(
                                  '$hour시',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // 분
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _minuteController,
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedMinute = index;
                        });
                      },
                      children: _minutes
                          .map((minute) => Center(
                                child: Text(
                                  '$minute분',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // 완료 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: GestureDetector(
                onTap: () {
                  final formattedTime = _getFormattedTime();
                  Navigator.pop(context, formattedTime);
                },
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A49F1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Center(
                    child: Text(
                      '완료',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
