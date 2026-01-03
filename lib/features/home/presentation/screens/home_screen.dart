import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/core/utils/date_formatter.dart';
import 'package:moit/features/home/presentation/screens/meet_01.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
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
    // 화면 진입 시 모임 리스트 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 [Home] 화면 진입 → 모임 리스트 로드');
      ref.read(meetingProvider.notifier).loadMeetings();
    });
  }

  /// Pull-to-refresh 핸들러
  Future<void> _handleRefresh() async {
    print('🔄 [Home] Pull-to-refresh 시작');
    await ref.read(meetingProvider.notifier).loadMeetings();
    print('✅ [Home] Pull-to-refresh 완료');
  }

  @override
  Widget build(BuildContext context) {
    final meetingState = ref.watch(meetingProvider);
    final userProfile = ref.watch(userProfileProvider);

    print('🏠 [Home] 빌드 시작');
    print('🏠 [Home] meetings.length: ${meetingState.meetings.length}');
    print('🏠 [Home] isLoading: ${meetingState.isLoading}');

    // 에러 메시지가 있으면 SnackBar 표시
    if (meetingState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(meetingState.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // 에러 메시지 표시 후 클리어
        ref.read(meetingProvider.notifier).clearError();
      });
    }

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

                      // 인사말 섹션
                      _buildGreetingSection(userProfile.displayName, meetingState.count),

                      const SizedBox(height: 24),

                      // 로딩 중일 때
                      if (meetingState.isLoading && meetingState.meetings.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )

                      // 모임이 없을 때
                      else if (meetingState.isEmpty)
                        _buildEmptyStateBox(context)

                      // 모임이 있을 때
                      else
                        _buildMeetingList(meetingState.meetings),

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
  Widget _buildGreetingSection(String userName, int meetingCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 좌측 인사말 텍스트
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // "수빈님,"
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Color(0xFF111111), // txt-primary
                    fontSize: 18,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.33,
                  ),
                ),
                Text(
                  '님,',
                  style: const TextStyle(
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
            // 모임 개수에 따른 메시지
            Text(
              meetingCount == 0
                  ? '모임을 만들어볼까요?'
                  : '오늘도 즐거운 모임 되세요!',
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
          SizedBox(
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
                      color: const Color(0xFF505050), // txt-secondary
                      fontSize: 14,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.43,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 296,
                  child: Text(
                    '아래 버튼을 눌러 첫 모임을 시작해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF999999), // color-disable
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
              child: Row(
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

  /// 모임 리스트
  Widget _buildMeetingList(List meetings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "내 모임" 타이틀
        Text(
          '내 모임',
          style: const TextStyle(
            color: Color(0xFF111111),
            fontSize: 16,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),

        // 모임 카드 리스트
        ...meetings.map((meeting) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMeetingCard(meeting),
            )),
      ],
    );
  }

  /// 모임 카드
  Widget _buildMeetingCard(dynamic meeting) {
    // 상태별 색상 결정
    final statusColor = _getStatusColor(meeting.status);
    final statusBgColor = _getStatusBackgroundColor(meeting.status);

    // 날짜 포맷팅
    final dateText = meeting.date != null
        ? DateFormatter.toKoreanDate(meeting.date)
        : null;

    return GestureDetector(
      onTap: () {
        // TODO: 모임 상세 화면으로 이동
        print('🔍 [Home] 모임 카드 클릭: ${meeting.meetingId} - ${meeting.title}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meeting.title} 상세 화면 (준비 중)'),
            duration: const Duration(seconds: 2),
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
              // 상태 뱃지
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

              // 날짜 (있을 경우)
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
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
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
              decoration: BoxDecoration(
                color: const Color(0xFF1A49F1), // main050
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x3D000000),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
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
