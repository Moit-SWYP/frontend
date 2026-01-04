import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/features/home/presentation/screens/home_screen.dart';
import 'package:moit/features/home/presentation/screens/calendar_placeholder_screen.dart';
import 'package:moit/features/home/presentation/screens/friends_screen.dart';

/// 메인 탭 네비게이션 화면
///
/// 하단 탭 바를 통해 홈/캘린더/친구 화면을 전환합니다.
class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _selectedIndex = 0;

  // 탭별 화면 목록
  static const List<Widget> _screens = [
    HomeScreen(), // 홈 화면 (모임 리스트 표시)
    CalendarPlaceholderScreen(),
    FriendsScreen(), // 친구 목록 화면 (실제 데이터 표시)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A000000),
              blurRadius: 8,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF1A49F1), // main050
              unselectedItemColor: const Color(0xFF999999), // txt-disable
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(
                      'assets/icons/home_tab.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 0
                            ? const Color(0xFF1A49F1)
                            : const Color(0xFF999999),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: '홈',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(
                      'assets/icons/calendar_tab.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 1
                            ? const Color(0xFF1A49F1)
                            : const Color(0xFF999999),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: '캘린더',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: SvgPicture.asset(
                      'assets/icons/friend_tab.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        _selectedIndex == 2
                            ? const Color(0xFF1A49F1)
                            : const Color(0xFF999999),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  label: '친구',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
