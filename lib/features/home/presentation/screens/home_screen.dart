import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/utils/date_formatter.dart';
import 'package:moit/features/home/data/models/home_response.dart';
import 'package:moit/features/home/presentation/screens/meet_01.dart';
import 'package:moit/features/home/providers/home_provider.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/presentation/screens/meeting_detail_screen.dart';
import 'package:moit/features/member/data/models/character_type.dart';
import 'package:moit/features/member/providers/user_profile_provider.dart';

/// 메인 홈 화면 (모임 리스트 표시)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 홈 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 [Home] 화면 진입 → 홈 데이터 로드');
      ref.read(homeProvider.notifier).loadHomeData();
    });
  }

  /// Pull-to-refresh 핸들러
  Future<void> _handleRefresh() async {
    print('🔄 [Home] Pull-to-refresh 시작');
    await ref.read(homeProvider.notifier).loadHomeData();
    print('✅ [Home] Pull-to-refresh 완료');
  }

  /// 오늘 날짜와 비교하여 D-day 계산
  int? _calculateDaysUntilMeeting(String? dateStr) {
    if (dateStr == null) return null;

    try {
      final meetingDate = DateTime.parse(dateStr);
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      final meetingMidnight =
          DateTime(meetingDate.year, meetingDate.month, meetingDate.day);

      return meetingMidnight.difference(todayMidnight).inDays;
    } catch (e) {
      print('❌ [HomeScreen] 날짜 파싱 실패: $dateStr');
      return null;
    }
  }

  /// 우선순위 기반 모임 선택 (D-day 카드용)
  /// 1순위: 오늘 확정된 모임
  /// 2순위: 투표 중인 모임 (가장 먼저 생성된 것)
  /// 3순위: 7일 이내 확정된 모임 (가장 가까운 것)
  MeetingBriefWithParticipants? _findPriorityMeeting(List<MeetingBriefWithParticipants> meetings) {
    if (meetings.isEmpty) return null;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // 1순위: 오늘 확정된 모임
    for (final meeting in meetings) {
      if (meeting.date == null || meeting.status != MeetingStatus.fixed) continue;

      try {
        final meetingDate = DateTime.parse(meeting.date!);
        final meetingMidnight = DateTime(meetingDate.year, meetingDate.month, meetingDate.day);
        if (meetingMidnight.isAtSameMomentAs(todayMidnight)) {
          return meeting;
        }
      } catch (e) {
        continue;
      }
    }

    // 2순위: 투표 중인 모임 (가장 먼저 생성된 것)
    final votingMeetings = meetings.where((meeting) {
      return meeting.status == MeetingStatus.dateVoting ||
          meeting.status == MeetingStatus.timeVoting ||
          meeting.status == MeetingStatus.placeVoting ||
          meeting.status == MeetingStatus.created;
    }).toList();

    if (votingMeetings.isNotEmpty) {
      return votingMeetings.reduce((a, b) => a.meetingId < b.meetingId ? a : b);
    }

    // 3순위: 7일 이내 확정된 모임 (가장 가까운 것)
    MeetingBriefWithParticipants? closestMeeting;
    int? smallestDays;

    for (final meeting in meetings) {
      if (meeting.date == null || meeting.status != MeetingStatus.fixed) continue;

      final daysUntil = _calculateDaysUntilMeeting(meeting.date);
      if (daysUntil == null || daysUntil < 0 || daysUntil > 7) continue;

      if (smallestDays == null || daysUntil < smallestDays) {
        smallestDays = daysUntil;
        closestMeeting = meeting;
      }
    }

    return closestMeeting;
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final userProfile = ref.watch(userProfileProvider);

    print('🏠 [Home] 빌드 시작');
    print('🏠 [Home] homeMeetings.length: ${homeState.homeData?.homeMeetings.length ?? 0}');
    print('🏠 [Home] waitingMeetings.length: ${homeState.homeData?.waitingMeetings.length ?? 0}');
    print('🏠 [Home] isLoading: ${homeState.isLoading}');

    // 에러 메시지가 있으면 SnackBar 표시
    if (homeState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(homeState.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // 에러 메시지 표시 후 클리어
        ref.read(homeProvider.notifier).clearError();
      });
    }

    // 우선순위 기반 모임 찾기 (D-day 카드용)
    final priorityMeeting = homeState.homeData != null
        ? _findPriorityMeeting(homeState.homeData!.homeMeetings)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(), // Pull-to-refresh 항상 활성화
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 상단 바 (로고 + 알림/설정 아이콘)
                      _buildTopBar(context),

                      const SizedBox(height: 24),

                      // 인사말 섹션 (동적 메시지 사용)
                      _buildGreetingSection(
                        userProfile.displayName,
                        homeState.topMessage,
                      ),

                      const SizedBox(height: 24),

                      // 로딩 중일 때
                      if (homeState.isLoading && homeState.homeData == null)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )

                      // 모임이 없을 때
                      else if (!homeState.hasHomeMeetings && !homeState.hasWaitingMeetings)
                        _buildEmptyStateBox(context)

                      // 모임이 있을 때
                      else
                        ..._buildMeetingContent(homeState, priorityMeeting),

                      const SizedBox(height: 100), // 플로팅 버튼 공간 확보
                    ],
                  ),
                ),
              ),
            ),

            // 플로팅 액션 버튼
            _buildFloatingActionButton(context),
          ],
        ),
      ),
    );
  }

  /// 상단 바 (로고 + 알림/설정 아이콘)
  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 좌측 로고
        SvgPicture.asset(
          'assets/icons/logo.svg',
          height: 24,
          fit: BoxFit.contain,
        ),

        // 우측 아이콘 (알림 + 프로필)
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 알림 아이콘
            GestureDetector(
              onTap: () {
                context.push('/settings/notifications');
              },
              child: Container(
                width: 24,
                height: 24,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: SvgPicture.asset(
                  'assets/icons/alram.svg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 프로필 아이콘
            GestureDetector(
              onTap: () {
                context.push('/settings');
              },
              child: Container(
                width: 24,
                height: 24,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: SvgPicture.asset(
                  'assets/icons/profile.svg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 인사말 섹션
  Widget _buildGreetingSection(String userName, String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 좌측 인사말 텍스트
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "수빈님,"
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        color: Color(0xFF111111), // txt-primary
                        fontSize: 18,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        height: 1.33,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text(
                    '님,',
                    style: TextStyle(
                      color: Color(0xFF111111), // txt-primary
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // 동적 메시지
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF111111), // txt-primary
                  fontSize: 24,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // 우측 캐릭터 아이콘
        Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(3.14159), // 수평 반전
          child: Container(
            width: 100,
            height: 100,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: SvgPicture.asset(
              'assets/icons/group_misik.svg',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  /// 빈 상태 박스
  Widget _buildEmptyStateBox(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 222,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8F9), // grey030
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 텍스트 영역
          const SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 296,
                  child: Text(
                    '아직 만들어진 모임이 없어요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF505050), // txt-secondary
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                SizedBox(
                  width: 296,
                  child: Text(
                    '아래 버튼을 눌러 첫 모임을 시작해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF999999), // color-disable
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // 모임 만들기 버튼
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Meet01Screen(),
                ),
              );
            },
            child: Container(
              width: 296,
              padding: const EdgeInsets.all(12),
              decoration: ShapeDecoration(
                color: const Color(0xFF1A49F1), // main050
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '모임 만들기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.43,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 모임 콘텐츠 (D-day 카드 + 친구들 모임)
  List<Widget> _buildMeetingContent(HomeState homeState, MeetingBriefWithParticipants? closestMeeting) {
    final widgets = <Widget>[];

    // D-day 카드 (가장 가까운 모임)
    if (closestMeeting != null) {
      widgets.add(_buildDDayCard(closestMeeting));
      widgets.add(const SizedBox(height: 24));
    }

    // 친구들이 기다려요 섹션 (homeMeetings)
    if (homeState.hasHomeMeetings) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '친구들이 기다려요',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: 전체 모임 목록 화면으로 이동
                print('📋 [Home] 더보기 클릭');
              },
              child: const Text(
                '더보기',
                style: TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),
            ),
          ],
        ),
      );
      widgets.add(const SizedBox(height: 12));

      // 모임 카드들 (최대 3개)
      final displayMeetings = homeState.homeData!.homeMeetings.take(3).toList();
      for (final meeting in displayMeetings) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMeetingCard(meeting),
          ),
        );
      }
    }

    // 승인 대기 중 섹션 (waitingMeetings)
    if (homeState.hasWaitingMeetings) {
      if (homeState.hasHomeMeetings) {
        widgets.add(const SizedBox(height: 24));
      }

      widgets.add(
        const Text(
          '승인 대기 중',
          style: TextStyle(
            color: Color(0xFF111111),
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
      );
      widgets.add(const SizedBox(height: 12));

      for (final meeting in homeState.homeData!.waitingMeetings) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildWaitingMeetingCard(meeting),
          ),
        );
      }
    }

    return widgets;
  }

  /// D-day 카드 (우선순위 모임)
  Widget _buildDDayCard(MeetingBriefWithParticipants meeting) {
    // 투표 중인 모임인지 확인
    final isVoting = meeting.status == MeetingStatus.dateVoting ||
        meeting.status == MeetingStatus.timeVoting ||
        meeting.status == MeetingStatus.placeVoting ||
        meeting.status == MeetingStatus.created;

    final daysUntil = _calculateDaysUntilMeeting(meeting.date);
    final dDayText = daysUntil == null
        ? ''
        : daysUntil == 0
            ? 'D-day'
            : 'D-$daysUntil';

    // 참여자 아바타 표시 (최대 4명)
    final displayParticipants = meeting.participants.take(4).toList();
    final remainingCount = meeting.participantCount - displayParticipants.length;

    return GestureDetector(
      onTap: () {
        print('🔍 [Home] D-day 카드 클릭: ${meeting.meetingId} - ${meeting.title}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(
              meeting: MeetingBrief(
                meetingId: meeting.meetingId,
                title: meeting.title,
                status: meeting.status,
                date: meeting.date,
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-1.00, -0.00),
            end: Alignment(1, 0),
            colors: [Color(0xFF1A49F1), Color(0xFF4A6FFF)],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x3D1A49F1),
              blurRadius: 20,
              offset: Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 배지: 투표 중이면 "일정 이야기 중", 확정되었으면 D-day
            if (isVoting || dDayText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isVoting ? '일정 이야기 중' : dDayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.43,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // 모임 제목
            Text(
              meeting.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // 날짜 및 위치 (임시로 강남역 2번 출구 표시)
            if (meeting.date != null)
              Text(
                '${DateFormatter.toKoreanDate(meeting.date)} · 강남역 2번 출구',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),

            const SizedBox(height: 16),

            // 참여자 아바타
            Row(
              children: [
                // 참여자 아바타 스택
                SizedBox(
                  height: 32,
                  child: Stack(
                    children: [
                      for (var i = 0; i < displayParticipants.length; i++)
                        Positioned(
                          left: i * 24.0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1A49F1),
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                displayParticipants[i].characterType.getIconPath('S'),
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: displayParticipants.length * 24.0 + 12),

                // 나머지 참여자 수
                if (remainingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      '+$remainingCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 1.38,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // 코스보기 버튼
            GestureDetector(
              onTap: () {
                // TODO: 코스 상세 화면으로 이동
                print('🗺️ [Home] 코스보기 클릭: ${meeting.meetingId}');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '코스보기',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A49F1),
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
      ),
    );
  }

  /// 모임 카드 (친구들이 기다려요 섹션)
  Widget _buildMeetingCard(MeetingBriefWithParticipants meeting) {
    // 투표 중인 모임인지 확인
    final isVoting = meeting.status == MeetingStatus.dateVoting ||
        meeting.status == MeetingStatus.timeVoting ||
        meeting.status == MeetingStatus.placeVoting ||
        meeting.status == MeetingStatus.created;

    final dateText = meeting.date != null
        ? DateFormatter.toKoreanDate(meeting.date)
        : null;

    // 참여자 아바타 표시 (최대 4명)
    final displayParticipants = meeting.participants.take(4).toList();
    final remainingCount = meeting.participantCount - displayParticipants.length;

    return GestureDetector(
      onTap: () {
        print('🔍 [Home] 모임 카드 클릭: ${meeting.meetingId} - ${meeting.title}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(
              meeting: MeetingBrief(
                meetingId: meeting.meetingId,
                title: meeting.title,
                status: meeting.status,
                date: meeting.date,
              ),
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 투표 상태 태그 + 모임 제목
            Row(
              children: [
                // 투표 중 태그
                if (isVoting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EEFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '일정 이야기 중',
                      style: TextStyle(
                        color: Color(0xFF1A49F1),
                        fontSize: 12,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        height: 1.33,
                      ),
                    ),
                  ),
                // 모임 제목
                Expanded(
                  child: Text(
                    meeting.title,
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 16,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 날짜 및 위치
            if (dateText != null)
              Text(
                '$dateText · 강남역 2번 출구',
                style: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 13,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.38,
                ),
              ),

            const SizedBox(height: 12),

            // 참여자 아바타
            Row(
              children: [
                // 참여자 아바타 스택
                SizedBox(
                  height: 24,
                  child: Stack(
                    children: [
                      for (var i = 0; i < displayParticipants.length; i++)
                        Positioned(
                          left: i * 18.0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE5E5E5),
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: SvgPicture.asset(
                                displayParticipants[i].characterType.getIconPath('S'),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: displayParticipants.length * 18.0 + 8),

                // 나머지 참여자 수
                if (remainingCount > 0)
                  Text(
                    '+$remainingCount',
                    style: const TextStyle(
                      color: Color(0xFF666666),
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
      ),
    );
  }

  /// 대기 중인 모임 카드
  Widget _buildWaitingMeetingCard(MeetingBrief meeting) {
    final statusColor = _getStatusColor(meeting.status);
    final statusBgColor = _getStatusBackgroundColor(meeting.status);
    final dateText = meeting.date != null
        ? DateFormatter.toKoreanDate(meeting.date)
        : null;

    return GestureDetector(
      onTap: () {
        print('🔍 [Home] 대기 모임 카드 클릭: ${meeting.meetingId} - ${meeting.title}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(meeting: meeting),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 모임 제목
            Text(
              meeting.title,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 상태 및 날짜
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    color: statusBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    meeting.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      height: 1.33,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (dateText != null)
                  Text(
                    dateText,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // 대기 상태 안내
            const Text(
              '모임 승인 대기 중입니다',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 13,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상태별 텍스트 색상 반환
  Color _getStatusColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.created:
        return const Color(0xFF1A49F1); // main050 (파란색)
      case MeetingStatus.dateVoting:
      case MeetingStatus.timeVoting:
      case MeetingStatus.placeVoting:
        return const Color(0xFFFF8A00); // 주황색 (투표 중)
      case MeetingStatus.fixed:
        return const Color(0xFF00C853); // 초록색 (확정됨)
      case MeetingStatus.done:
        return const Color(0xFF999999); // 회색 (완료됨)
      default:
        return const Color(0xFF505050); // txt-secondary
    }
  }

  /// 상태별 배경 색상 반환
  Color _getStatusBackgroundColor(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.created:
        return const Color(0xFFE8EEFF); // 연한 파란색
      case MeetingStatus.dateVoting:
      case MeetingStatus.timeVoting:
      case MeetingStatus.placeVoting:
        return const Color(0xFFFFF4E6); // 연한 주황색
      case MeetingStatus.fixed:
        return const Color(0xFFE8F5E9); // 연한 초록색
      case MeetingStatus.done:
        return const Color(0xFFF5F5F5); // 연한 회색
      default:
        return const Color(0xFFF7F8F9); // grey030
    }
  }

  /// 플로팅 액션 버튼 (모임 만들기)
  Widget _buildFloatingActionButton(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "모임 만들기" 텍스트 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF111111), // txt-primary (검은색 배경)
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: const Text(
              '모임 만들기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                height: 1.43,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // + 버튼
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Meet01Screen(),
                ),
              );
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFF1A49F1), // main050
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x3D000000),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
