import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/features/home/presentation/widgets/confirmed_meeting_card.dart';
import 'package:moit/features/home/presentation/widgets/voting_meeting_card.dart';
import 'package:moit/features/home/presentation/widgets/page_indicator.dart';
import 'package:moit/features/home/presentation/screens/vote_home.dart';

/// 메인 홈 피드 화면
class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // 상단 바 (로고 + 알림/설정 아이콘)
                    _buildTopBar(),

                    const SizedBox(height: 24),

                    // 인사말 섹션
                    _buildGreetingSection(),

                    const SizedBox(height: 24),

                    // 확정된 약속 영역 (가로 스크롤)
                    _buildConfirmedMeetingsSection(),

                    const SizedBox(height: 32),

                    // 투표 진행중인 약속 영역
                    _buildVotingMeetingsSection(),

                    const SizedBox(height: 100), // 플로팅 버튼 공간 확보
                  ],
                ),
              ),
            ),

            // 플로팅 액션 버튼
            _buildFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  /// 상단 바 (로고 + 알림/설정 아이콘)
  Widget _buildTopBar() {
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
  Widget _buildGreetingSection() {
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
                  '수빈',
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
            // "오늘은 모임이 있어요!"
            Text(
              '오늘은 모임이 있어요!',
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
          transform: Matrix4.rotationY(3.14159), // 수평 반전 (Y축 기준 180도 회전)
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

  /// 확정된 약속 섹션 (가로 스크롤)
  Widget _buildConfirmedMeetingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PageView (확정 약속 카드)
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 5, // 더미 데이터 5개
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: ConfirmedMeetingCard(),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // 페이지 인디케이터
        Center(
          child: PageIndicator(
            currentPage: _currentPage,
            totalPages: 5,
          ),
        ),
      ],
    );
  }

  /// 투표 진행중인 약속 섹션
  Widget _buildVotingMeetingsSection() {
    // 더미 데이터
    final votingMeetings = [
      {'name': '우열님 병문안 가기', 'status': '일정 이야기 중'},
      {'name': '연말 파티', 'status': '일정 이야기 중'},
      {'name': '강릉 여행', 'status': '일정 이야기 중'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목 + 더보기
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '친구들이 기다려요',
              style: TextStyle(
                color: Color(0xFF111111), // txt-primary
                fontSize: 18,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.33,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoteHomeScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Text(
                  '더보기',
                  style: TextStyle(
                    color: Color(0xFF999999), // color-disable
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.38,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 투표 진행중 카드 리스트
        ...votingMeetings.map((meeting) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: VotingMeetingCard(
                meetingName: meeting['name'] as String,
                status: meeting['status'] as String,
              ),
            )),
      ],
    );
  }

  /// 플로팅 액션 버튼 (모임 만들기)
  Widget _buildFloatingActionButton() {
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
              // TODO: 모임 만들기 화면으로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('모임 만들기 화면은 추후 구현 예정입니다'),
                  duration: Duration(seconds: 2),
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
