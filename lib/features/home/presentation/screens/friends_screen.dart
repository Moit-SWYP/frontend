import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moit/core/constants/app_colors.dart';
import 'package:moit/core/constants/app_text_styles.dart';
import 'package:moit/features/member/providers/friend_provider.dart';
import 'package:moit/features/member/data/models/friend_info.dart';
import 'package:moit/features/member/data/models/character_type.dart';

/// 친구 목록 화면
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 친구 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(friendProvider.notifier).loadFriends();
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendState = ref.watch(friendProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 56,
        title: const Text(
          '친구',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 24 / 18,
            color: Color(0xFF000000),
          ),
        ),
      ),
      body: friendState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : friendState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        friendState.errorMessage!,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(friendProvider.notifier).loadFriends();
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                )
              : friendState.friends.isEmpty
                  ? _buildEmptyState()
                  : _buildFriendList(friendState.friends),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.grey070,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 친구가 없어요',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '모임에 참여하면 자동으로 친구가 등록돼요',
            style: AppTextStyles.body1.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 친구 목록 위젯
  Widget _buildFriendList(List<FriendInfo> friends) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(friendProvider.notifier).loadFriends();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        itemCount: friends.length + 1, // +1 for header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(friends.length);
          }
          return _buildFriendCard(friends[index - 1]);
        },
      ),
    );
  }

  /// 헤더 위젯 (친구 수 표시)
  Widget _buildHeader(int friendCount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            '함께한 친구',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$friendCount',
            style: AppTextStyles.heading2.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 친구 카드 위젯
  Widget _buildFriendCard(FriendInfo friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.grey040,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 캐릭터 아이콘
          _buildCharacterIcon(friend.characterType),
          const SizedBox(width: 16),
          // 친구 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.nickname,
                  style: AppTextStyles.subtitle1.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      friend.characterType.displayName,
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.grey070,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '함께한 모임 ${friend.metCount}회',
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 캐릭터 아이콘 위젯
  Widget _buildCharacterIcon(CharacterType characterType) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.grey040,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SvgPicture.asset(
          characterType.getIconPath('M'),
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}
