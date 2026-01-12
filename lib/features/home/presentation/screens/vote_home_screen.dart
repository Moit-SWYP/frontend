import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/features/home/presentation/widgets/waiting_meeting_card.dart';
import 'package:moit/features/home/providers/home_provider.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';

/// 필터 카테고리
enum FilterCategory {
  all,      // 전체
  schedule, // 일정 이야기 중
  course,   // 코스 이야기 중
}

/// Vote Home 화면
/// 모든 waitingMeetings를 필터링 기능과 함께 표시
class VoteHomeScreen extends ConsumerStatefulWidget {
  const VoteHomeScreen({super.key});

  @override
  ConsumerState<VoteHomeScreen> createState() => _VoteHomeScreenState();
}

class _VoteHomeScreenState extends ConsumerState<VoteHomeScreen> {
  FilterCategory _selectedFilter = FilterCategory.all;

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final allMeetings = homeState.homeData?.waitingMeetings ?? [];
    final filteredMeetings = _filterMeetings(allMeetings);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildHeader(),
            _buildFilterChips(),
            Expanded(child: _buildMeetingList(filteredMeetings, homeState)),
          ],
        ),
      ),
    );
  }

  /// AppBar (뒤로가기 버튼)
  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 뒤로가기 버튼
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              'assets/icons/left.svg',
              width: 24,
              height: 24,
            ),
          ),
          // 중앙 정렬을 위한 빈 공간
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  /// Header (제목 + 설명)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '친구들이 기다리고 있어요',
            style: TextStyle(
              color: Color(0xFF111111),
              fontSize: 18,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '일정이나 코스를 정리중인 모임들이에요',
            style: TextStyle(
              color: Color(0xFF505050),
              fontSize: 14,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  /// Filter Chips (전체 / 일정 이야기 중 / 코스 이야기 중)
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildFilterChip('전체', FilterCategory.all),
          const SizedBox(width: 8),
          _buildFilterChip('일정 이야기 중', FilterCategory.schedule),
          const SizedBox(width: 8),
          _buildFilterChip('코스 이야기 중', FilterCategory.course),
        ],
      ),
    );
  }

  /// 개별 Filter Chip
  Widget _buildFilterChip(String label, FilterCategory category) {
    final isSelected = _selectedFilter == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF1A49F1) : Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected ? const Color(0xFF1A49F1) : const Color(0xFFE5E5E5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF111111),
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.43,
          ),
        ),
      ),
    );
  }

  /// Meeting List (필터링된 모임 리스트)
  Widget _buildMeetingList(List<MeetingBrief> meetings, HomeState homeState) {
    // 로딩 중일 때
    if (homeState.isLoading && homeState.homeData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 빈 상태
    if (meetings.isEmpty) {
      return Center(
        child: Text(
          _selectedFilter == FilterCategory.all
              ? '대기 중인 모임이 없어요'
              : '해당하는 모임이 없어요',
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 14,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    // 모임 리스트
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WaitingMeetingCard(meeting: meetings[index]),
        );
      },
    );
  }

  /// 필터링 로직
  List<MeetingBrief> _filterMeetings(List<MeetingBrief> meetings) {
    switch (_selectedFilter) {
      case FilterCategory.all:
        return meetings;
      case FilterCategory.schedule:
        // 일정 이야기 중: CREATED, DATE_VOTING, TIME_VOTING
        return meetings.where((m) =>
          m.status == MeetingStatus.created ||
          m.status == MeetingStatus.dateVoting ||
          m.status == MeetingStatus.timeVoting
        ).toList();
      case FilterCategory.course:
        // 코스 이야기 중: PLACE_VOTING
        return meetings.where((m) =>
          m.status == MeetingStatus.placeVoting
        ).toList();
    }
  }
}
