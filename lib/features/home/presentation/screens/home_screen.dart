import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/utils/date_formatter.dart';
import 'package:moit/features/home/data/models/home_response.dart';
import 'package:moit/features/home/presentation/screens/meet_01.dart';
import 'package:moit/features/home/presentation/screens/meet_07.dart';
import 'package:moit/features/home/presentation/screens/meet_09.dart';
import 'package:moit/features/home/presentation/screens/meet_17.dart';
import 'package:moit/features/home/providers/home_provider.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/presentation/screens/meeting_detail_screen.dart';
import 'package:moit/features/meeting/providers/vote_provider.dart';
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
  /// D-day 카드는 날짜가 확정된 모임 표시 (시간 확정 여부 무관)
  /// dateVoted (날짜만 확정) 또는 fixed (날짜+시간 확정) 모두 포함
  /// 1순위: 오늘 확정된 모임
  /// 2순위: 7일 이내 확정된 모임 (가장 가까운 것)
  MeetingBriefWithParticipants? _findPriorityMeeting(List<MeetingBriefWithParticipants> meetings) {
    if (meetings.isEmpty) return null;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // 1순위: 오늘 확정된 모임 (날짜가 확정된 모임)
    for (final meeting in meetings) {
      // 날짜가 null이면 제외
      if (meeting.date == null) continue;

      // dateVoted 또는 fixed 상태만 포함
      if (meeting.status != MeetingStatus.dateVoted &&
          meeting.status != MeetingStatus.fixed) continue;

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

    // 2순위: 7일 이내 확정된 모임 (가장 가까운 것)
    MeetingBriefWithParticipants? closestMeeting;
    int? smallestDays;

    for (final meeting in meetings) {
      // 날짜가 null이면 제외
      if (meeting.date == null) continue;

      // dateVoted 또는 fixed 상태만 포함
      if (meeting.status != MeetingStatus.dateVoted &&
          meeting.status != MeetingStatus.fixed) continue;

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

    // 디버그: 각 모임의 상태 출력
    if (homeState.homeData != null) {
      for (final meeting in homeState.homeData!.homeMeetings) {
        print('🔍 [Home] homeMeeting: ${meeting.meetingId} - status: ${meeting.status} - date: ${meeting.date}');
      }
      for (final meeting in homeState.homeData!.waitingMeetings) {
        print('🔍 [Home] waitingMeeting: ${meeting.meetingId} - status: ${meeting.status} - date: ${meeting.date}');
      }
    }

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

    print('🎯 [Home] priorityMeeting: ${priorityMeeting?.meetingId} - ${priorityMeeting?.status}');

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

    // D-day 카드들 (날짜가 확정된 모임들 - 가로 스크롤)
    if (homeState.hasHomeMeetings) {
      // 날짜가 확정된 모임들 필터링 (dateVoted 또는 fixed)
      final confirmedMeetings = homeState.homeData!.homeMeetings
          .where((meeting) =>
              meeting.date != null &&
              (meeting.status == MeetingStatus.dateVoted ||
                  meeting.status == MeetingStatus.fixed))
          .toList();

      if (confirmedMeetings.isNotEmpty) {
        widgets.add(_buildDDayCarousel(confirmedMeetings));
        widgets.add(const SizedBox(height: 24));
      }
    }

    // 일정 이야기 중 섹션 (waitingMeetings)
    // 사용자가 아직 투표하지 않은 모든 모임
    if (homeState.hasWaitingMeetings) {
      if (closestMeeting != null) {
        widgets.add(const SizedBox(height: 24));
      }

      widgets.add(
        const Text(
          '일정 이야기 중',
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

  /// D-day 카드 캐러셀 (가로 스크롤)
  Widget _buildDDayCarousel(List<MeetingBriefWithParticipants> meetings) {
    final PageController pageController = PageController();
    int currentPage = 0;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: [
            // 카드 캐러셀
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: pageController,
                itemCount: meetings.length,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDDayCard(meetings[index]),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // 페이지 인디케이터
            if (meetings.length > 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  meetings.length,
                  (index) => Container(
                    width: index == currentPage ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: ShapeDecoration(
                      color: index == currentPage
                          ? const Color(0xFF7692F7) /* main030 */
                          : const Color(0xFFE9EBEE) /* grey040 */,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(index == currentPage ? 24 : 32),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// D-day 카드 (개별 카드) - 회색 배경 디자인
  Widget _buildDDayCard(MeetingBriefWithParticipants meeting) {
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
      onTap: () async {
        print('🔍 [Home] D-day 카드 클릭: ${meeting.meetingId} - ${meeting.title}');

        // 로딩 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // 투표 요약 로드
        await ref
            .read(voteProvider(meeting.meetingId).notifier)
            .loadVoteSummary();

        // 로딩 닫기
        if (!mounted) return;
        Navigator.pop(context);

        // 투표 상태 확인
        final voteState = ref.read(voteProvider(meeting.meetingId));

        if (!mounted) return;

        // 분기 처리
        if (voteState.summary == null) {
          // API 실패 → 기존 화면으로
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
        } else if (!voteState.hasVotedDate) {
          // 투표 안 함 → 투표 화면
          print('📋 [Home] 투표 안 함 → meet_07 이동');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Meet07Screen(
                meetingName: meeting.title,
                meetingId: meeting.meetingId,
                initialTab: 1,
              ),
            ),
          );
        } else {
          // 투표 완료
          if (voteState.isHost) {
            // 모임장 → meet_09
            print('👑 [Home] 모임장 & 투표 완료 → meet_09 이동');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meet09Screen(
                  meetingName: meeting.title,
                  meetingId: meeting.meetingId,
                  votedDates: {},
                ),
              ),
            );
          } else {
            // 모임원 → meet_17
            print('👤 [Home] 모임원 & 투표 완료 → meet_17 이동');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meet17Screen(
                  meetingName: meeting.title,
                  meetingId: meeting.meetingId,
                  votedDates: {},
                ),
              ),
            );
          }
        }
      },
      child: Container(
        width: 328,
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
            // D-day 배지
            if (dDayText.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE8EDFE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  dDayText,
                  style: const TextStyle(
                    color: Color(0xFF1A49F1),
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
                color: Color(0xFF111111),
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.44,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // 날짜 및 위치
            if (meeting.date != null)
              Row(
                children: [
                  Text(
                    DateFormatter.toKoreanDate(meeting.date),
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 2,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Color(0xFF666666),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '강남역 2번 출구',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // 참여자 아바타 + 캐릭터 아이콘 플레이스홀더
            Row(
              children: [
                // 참여자 아바타 스택
                SizedBox(
                  width: displayParticipants.isEmpty
                      ? 32
                      : (displayParticipants.length - 1) * 24.0 + 32,
                  height: 32,
                  child: Stack(
                    children: [
                      for (var i = 0; i < displayParticipants.length; i++)
                        Positioned(
                          left: i * 24.0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
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

                const SizedBox(width: 8),

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

                const Spacer(),

                // 캐릭터 아이콘 플레이스홀더
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC5C8CE),
                    shape: BoxShape.circle,
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
                  color: const Color(0xFF1A49F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '코스보기',
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
      onTap: () async {
        print('🔍 [Home] 모임 카드 클릭: ${meeting.meetingId} - ${meeting.title}');

        // 로딩 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // 투표 요약 로드
        await ref
            .read(voteProvider(meeting.meetingId).notifier)
            .loadVoteSummary();

        // 로딩 닫기
        if (!mounted) return;
        Navigator.pop(context);

        // 투표 상태 확인
        final voteState = ref.read(voteProvider(meeting.meetingId));

        if (!mounted) return;

        // 분기 처리
        if (voteState.summary == null) {
          // API 실패 → 기존 화면으로
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
        } else if (!voteState.hasVotedDate) {
          // 투표 안 함 → 투표 화면
          print('📋 [Home] 투표 안 함 → meet_07 이동');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Meet07Screen(
                meetingName: meeting.title,
                meetingId: meeting.meetingId,
                initialTab: 1,
              ),
            ),
          );
        } else {
          // 투표 완료
          if (voteState.isHost) {
            // 모임장 → meet_09
            print('👑 [Home] 모임장 & 투표 완료 → meet_09 이동');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meet09Screen(
                  meetingName: meeting.title,
                  meetingId: meeting.meetingId,
                  votedDates: {},
                ),
              ),
            );
          } else {
            // 모임원 → meet_17
            print('👤 [Home] 모임원 & 투표 완료 → meet_17 이동');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meet17Screen(
                  meetingName: meeting.title,
                  meetingId: meeting.meetingId,
                  votedDates: {},
                ),
              ),
            );
          }
        }
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
                  width: displayParticipants.isEmpty ? 24 : (displayParticipants.length - 1) * 18.0 + 24,
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
                const SizedBox(width: 8),

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
    return GestureDetector(
      onTap: () async {
        print('🔍 [Home] 대기 모임 카드 클릭: ${meeting.meetingId} - ${meeting.title}');

        // 로딩 표시
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        // 투표 요약 로드
        await ref
            .read(voteProvider(meeting.meetingId).notifier)
            .loadVoteSummary();

        // 로딩 닫기
        if (!mounted) return;
        Navigator.pop(context);

        // 투표 상태 확인
        final voteState = ref.read(voteProvider(meeting.meetingId));

        if (!mounted) return;

        // 분기 처리
        if (voteState.summary == null) {
          // API 실패 → 기존 화면으로
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MeetingDetailScreen(meeting: meeting),
            ),
          );
        } else {
          // meetingStatus와 hasVotedDate 모두 확인
          // CREATED 상태 또는 투표하지 않은 경우 → meet_07
          final isCreatedStatus = voteState.summary!.meetingStatus == MeetingStatus.created;
          final hasNotVoted = !voteState.hasVotedDate;

          if (isCreatedStatus && hasNotVoted) {
            // 투표 안 함 → 투표 화면
            print('📋 [Home] 투표 안 함 (CREATED & no vote) → meet_07 이동');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Meet07Screen(
                  meetingName: meeting.title,
                  meetingId: meeting.meetingId,
                  initialTab: 1,
                ),
              ),
            );
          } else {
            // 투표 완료 또는 투표 진행 중
            if (voteState.isHost) {
              // 모임장 → meet_09
              print('👑 [Home] 모임장 & 투표 완료 → meet_09 이동');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Meet09Screen(
                    meetingName: meeting.title,
                    meetingId: meeting.meetingId,
                    votedDates: {},
                  ),
                ),
              );
            } else {
              // 모임원 → meet_17
              print('👤 [Home] 모임원 & 투표 완료 → meet_17 이동');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Meet17Screen(
                    meetingName: meeting.title,
                    meetingId: meeting.meetingId,
                    votedDates: {},
                  ),
                ),
              );
            }
          }
        }
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "일정 이야기 중" 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFE8EDFE), // main010
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _getWaitingStatusMessage(meeting.status),
                          style: const TextStyle(
                            color: Color(0xFF1A49F1), // main050
                            fontSize: 13,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                            letterSpacing: -0.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 모임 제목
                  Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            height: 1.50,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 오른쪽 화살표 아이콘
            SvgPicture.asset(
              'assets/icons/right.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Color(0xFF999999),
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 대기 모임 카드 상태별 메시지 반환
  String _getWaitingStatusMessage(MeetingStatus status) {
    switch (status) {
      case MeetingStatus.created:
      case MeetingStatus.dateVoting:
      case MeetingStatus.timeVoting:
        return '일정 이야기 중';
      case MeetingStatus.placeVoting:
        return '장소 이야기 중';
      default:
        return '친구들이 기다려요';
    }
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
