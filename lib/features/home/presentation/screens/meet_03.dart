import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/features/home/presentation/screens/meet_07.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';

/// 모임 만들기 3단계 - 친구 초대 화면
class Meet03Screen extends ConsumerStatefulWidget {
  final String meetingName;
  final int? meetingId; // 생성된 모임 ID
  final int initialTab;

  const Meet03Screen({
    super.key,
    required this.meetingName,
    this.meetingId,
    this.initialTab = 0,
  });

  @override
  ConsumerState<Meet03Screen> createState() => _Meet03ScreenState();
}

class _Meet03ScreenState extends ConsumerState<Meet03Screen> {
  late int _selectedTab; // 0: 초대, 1: 일정

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }
  final TextEditingController _searchController = TextEditingController();
  bool _isLinkCopied = false;
  bool _isGeneratingLink = false;
  String? _invitationLink;
  final Set<String> _selectedFriends = {}; // 선택된 친구 ID들

  // 더미 데이터
  final List<Map<String, dynamic>> _friendGroups = [
    {'name': '스위프', 'count': 3, 'icons': ['alcohol_S', 'food_S', 'exhibit_S']},
    {'name': '기요미들', 'count': 3, 'icons': ['study_S', 'food_S', 'alcohol_S']},
    {'name': '모잉이들', 'count': 4, 'icons': ['exhibit_S', 'study_S', 'food_S']},
  ];

  final List<Map<String, dynamic>> _friends = [
    {'id': '1', 'name': '남수빈', 'meetingCount': 3, 'icon': 'alcohol_S'},
    {'id': '2', 'name': '양우열', 'meetingCount': 4, 'icon': 'food_S'},
    {'id': '3', 'name': '김여명', 'meetingCount': 10, 'icon': 'exhibit_S'},
    {'id': '4', 'name': '신아름', 'meetingCount': 2, 'icon': 'study_S'},
    {'id': '5', 'name': '조명근', 'meetingCount': 3, 'icon': 'food_S'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
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
            onPressed: _showLinkShareDialog,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      // 검색 바
                      _buildSearchBar(),

                      const SizedBox(height: 16),

                      // 모임친구 섹션
                      _buildFriendGroupsSection(),

                      const SizedBox(height: 24),

                      // 친구목록 섹션
                      _buildFriendListSection(),

                      const SizedBox(height: 24),
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
        if (index == 1) {
          // 일정 탭 클릭 시 meet_07로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Meet07Screen(
                meetingName: widget.meetingName,
                initialTab: 1,
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

  /// 검색 바
  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: const Color(0xFFE9EBEE), // grey040
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            size: 24,
            color: Color(0xFF999999),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontSize: 14,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                height: 1.43,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '이름(초성), 전화번호 검색',
                hintStyle: TextStyle(
                  color: Color(0xFF999999), // color-disable
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Color(0xFFE9EBEE), // grey040
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 모임친구 섹션
  Widget _buildFriendGroupsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '모임친구',
              style: TextStyle(
                color: Color(0xFF111111),
                fontSize: 16,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.50,
              ),
            ),
            GestureDetector(
              onTap: () {
                // TODO: 등록 기능
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE9EBEE), // grey040
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      size: 16,
                      color: Color(0xFF505050),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      '등록',
                      style: TextStyle(
                        color: Color(0xFF505050),
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
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 친구 그룹 카드들 (가로 스크롤)
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _friendGroups.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildFriendGroupCard(_friendGroups[index]);
            },
          ),
        ),
      ],
    );
  }

  /// 친구 그룹 카드
  Widget _buildFriendGroupCard(Map<String, dynamic> group) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F8F9), // grey030
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            group['name'],
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 16,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w700,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 아이콘 겹치기
              SizedBox(
                width: 64,
                height: 32,
                child: Stack(
                  children: List.generate(3, (i) {
                    return Positioned(
                      left: i * 16.0,
                      child: SvgPicture.asset(
                        'assets/icons/${group['icons'][i]}.svg',
                        width: 32,
                        height: 32,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${group['count']}',
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
        ],
      ),
    );
  }

  /// 친구목록 섹션
  Widget _buildFriendListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  '친구목록',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    height: 1.50,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_friends.length}',
                  style: const TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 16,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    height: 1.50,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.swap_vert,
                  size: 18,
                  color: Color(0xFF505050),
                ),
                const SizedBox(width: 8),
                const Text(
                  '이름순',
                  style: TextStyle(
                    color: Color(0xFF505050),
                    fontSize: 13,
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                    letterSpacing: -0.33,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 친구 리스트
        Column(
          children: _friends.map((friend) => _buildFriendItem(friend)).toList(),
        ),
      ],
    );
  }

  /// 친구 아이템
  Widget _buildFriendItem(Map<String, dynamic> friend) {
    final isSelected = _selectedFriends.contains(friend['id']);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // 아이콘
                SvgPicture.asset(
                  'assets/icons/${friend['icon']}.svg',
                  width: 32,
                  height: 32,
                ),
                const SizedBox(width: 8),
                // 이름 및 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend['name'],
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          height: 1.50,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            '함께한 모임',
                            style: TextStyle(
                              color: Color(0xFF505050),
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${friend['meetingCount']}회',
                            style: const TextStyle(
                              color: Color(0xFF505050),
                              fontSize: 12,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 선택 체크박스
          GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedFriends.remove(friend['id']);
                } else {
                  _selectedFriends.add(friend['id']);
                }
              });
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: isSelected
                      ? const Color(0xFF1A49F1) // main050
                      : const Color(0xFFC5C8CE), // grey050
                ),
                color: isSelected ? const Color(0xFF1A49F1) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// 링크 공유 다이얼로그
  void _showLinkShareDialog() async {
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
      _showLinkDialog(_invitationLink!);
      return;
    }

    // 링크 생성 중 표시
    setState(() {
      _isGeneratingLink = true;
    });

    try {
      print('🔗 [Meet03] 초대 링크 생성 시작: meetingId=${widget.meetingId}');

      final invitationLink = await ref
          .read(meetingProvider.notifier)
          .getInvitationLink(widget.meetingId!);

      if (!mounted) return;

      if (invitationLink != null) {
        print('✅ [Meet03] 초대 링크 생성 성공: $invitationLink');
        setState(() {
          _invitationLink = invitationLink;
          _isGeneratingLink = false;
        });
        _showLinkDialog(invitationLink);
      } else {
        print('❌ [Meet03] 초대 링크 생성 실패');
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
      print('❌ [Meet03] 초대 링크 생성 에러: $e');
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

  /// 링크 다이얼로그 표시
  void _showLinkDialog(String linkUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '약속방 링크 공유하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF111111),
                      fontSize: 18,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      height: 1.33,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '약속방 링크를 친구에게 공유하고\n모잇에서 편리하게 약속을 정해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF505050),
                      fontSize: 13,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      height: 1.38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 링크 박스
                  GestureDetector(
                    onTap: () {
                      _copyLinkToClipboard(linkUrl);
                      setDialogState(() {
                        _isLinkCopied = true;
                      });
                      // 2초 후 원래 색상으로 복귀
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setDialogState(() {
                            _isLinkCopied = false;
                          });
                        }
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: _isLinkCopied
                            ? const Color(0xFFE8EDFE) // main010 (복사 후)
                            : const Color(0xFFE9EBEE), // grey040 (기본)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              linkUrl,
                              style: TextStyle(
                                color: _isLinkCopied
                                    ? const Color(0xFF1A49F1) // main050 (복사 후)
                                    : const Color(0xFF999999), // color-disable (기본)
                                fontSize: 16,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/copy.svg',
                            width: 18,
                            height: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 클립보드에 링크 복사
  void _copyLinkToClipboard(String linkUrl) {
    Clipboard.setData(ClipboardData(text: linkUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('링크가 복사되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
