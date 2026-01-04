import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/member/data/clients/member_client.dart';
import 'package:moit/features/member/providers/user_profile_state.dart';

/// 사용자 프로필 Provider
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfileState>((ref) {
  return UserProfileNotifier();
});

/// 사용자 프로필 Notifier
class UserProfileNotifier extends StateNotifier<UserProfileState> {
  UserProfileNotifier() : super(const UserProfileState());

  final MemberClient _memberClient = MemberClient();

  /// 내 프로필 로드
  Future<void> loadProfile() async {
    if (state.isLoading) return; // 이미 로딩 중이면 중복 호출 방지

    print('👤 [UserProfile] 프로필 로드 시작');
    print('👤 [UserProfile] 현재 상태 - isLoading: ${state.isLoading}, hasProfile: ${state.hasProfile}');

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _memberClient.getMyProfile();

      print('👤 [UserProfile] API 응답 받음 - code: ${response.code}, message: ${response.message}');
      print('👤 [UserProfile] API 응답 data: ${response.data}');

      if (response.data == null) {
        print('❌ [UserProfile] 응답 데이터가 null입니다!');
        state = state.copyWith(
          isLoading: false,
          errorMessage: '프로필 데이터가 없습니다.',
        );
        return;
      }

      final profile = response.data!;

      print('✅ [UserProfile] 프로필 로드 성공!');
      print('  - nickname: ${profile.nickname}');
      print('  - email: ${profile.email}');
      print('  - gender: ${profile.gender}');
      print('  - birthDate: ${profile.birthDate}');

      state = state.copyWith(
        profile: profile,
        isLoading: false,
      );

      print('👤 [UserProfile] 상태 업데이트 완료 - displayName: ${state.displayName}');
    } on DioException catch (e, stackTrace) {
      print('❌ [UserProfile] 프로필 로드 실패 (DioException): $e');
      print('❌ [UserProfile] StackTrace: $stackTrace');

      // 401 에러이거나 AUTH_EXPIRED 에러인 경우 - 인증 실패로 간주
      if (e.response?.statusCode == 401 || e.error == 'AUTH_EXPIRED') {
        print('🚨 [UserProfile] 인증 만료 - 프로필 초기화');
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'AUTH_EXPIRED', // 인증 만료 표시
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '프로필을 불러오는데 실패했습니다.',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [UserProfile] 프로필 로드 실패: $e');
      print('❌ [UserProfile] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '프로필을 불러오는데 실패했습니다.',
      );
    }
  }

  /// 프로필 초기화 (로그아웃 시)
  void clearProfile() {
    print('🗑️ [UserProfile] 프로필 초기화');
    state = const UserProfileState();
  }

  /// 에러 메시지 초기화
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
