import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:moit/features/home/presentation/screens/meet_01.dart';

/// 메인 홈 빈 화면 (모임이 없을 때)
class HomeEmptyScreen extends StatelessWidget {
  const HomeEmptyScreen({super.key});

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
                    _buildTopBar(context),

                    const SizedBox(height: 24),

                    // 인사말 섹션
                    _buildGreetingSection(),

                    const SizedBox(height: 24),

                    // 빈 상태 박스
                    _buildEmptyStateBox(context),

                    const SizedBox(height: 100), // 플로팅 버튼 공간 확보
                  ],
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
            // "모임을 만들어볼까요?"
            Text(
              '모임을 만들어볼까요?',
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
          Container(
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
