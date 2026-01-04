import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/member/data/clients/member_client.dart';
import 'package:moit/features/member/data/models/member_info.dart';
import 'package:moit/features/member/data/models/member_withdraw_request.dart';
import 'package:moit/features/member/data/models/social_link_request.dart';

/// Member 상태
class MemberState {
  final MemberInfo? memberInfo; // 회원 정보
  final bool isLoading; // 로딩 상태
  final String? errorMessage; // 에러 메시지

  const MemberState({
    this.memberInfo,
    this.isLoading = false,
    this.errorMessage,
  });

  MemberState copyWith({
    MemberInfo? memberInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MemberState(
      memberInfo: memberInfo ?? this.memberInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// 회원 정보가 로드되었는지 여부
  bool get hasInfo => memberInfo != null;

  /// 이메일
  String? get email => memberInfo?.email;

  /// 닉네임
  String? get nickname => memberInfo?.nickname;

  /// 생년월일
  String? get birthDate => memberInfo?.birthDate;

  /// 성별
  String? get gender => memberInfo?.gender;

  /// 성별 한글 변환
  String? get genderText => memberInfo?.genderText;

  /// 연동된 소셜 계정 수
  int get socialAccountCount => memberInfo?.socialAccountCount ?? 0;

  /// 특정 소셜 계정 연동 여부
  bool isSocialLinked(String provider) {
    return memberInfo?.isSocialLinked(provider) ?? false;
  }
}

/// Member Provider
final memberProvider = StateNotifierProvider<MemberNotifier, MemberState>((ref) {
  return MemberNotifier();
});

/// Member StateNotifier
class MemberNotifier extends StateNotifier<MemberState> {
  MemberNotifier() : super(const MemberState());

  final MemberClient _memberClient = MemberClient();

  /// 내 정보 조회
  Future<void> loadMyInfo() async {
    // 이미 로딩 중이면 중복 호출 방지
    if (state.isLoading) {
      print('⚠️ [Member] 이미 로딩 중입니다.');
      return;
    }

    print('🔄 [Member] 내 정보 로드 시작');
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final memberInfo = await _memberClient.getMyInfo();

      print('✅ [Member] 내 정보 로드 성공');
      print('  - email: ${memberInfo.email}');
      print('  - nickname: ${memberInfo.nickname}');

      state = state.copyWith(
        memberInfo: memberInfo,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      print('❌ [Member] 내 정보 로드 실패: $e');
      print('❌ [Member] StackTrace: $stackTrace');

      state = state.copyWith(
        isLoading: false,
        errorMessage: '내 정보를 불러오는데 실패했습니다.',
      );
    }
  }

  /// 캐릭터 변경
  Future<bool> updateCharacter(String character) async {
    print('🔄 [Member] 캐릭터 변경 시작: $character');

    try {
      await _memberClient.updateCharacter(character);

      print('✅ [Member] 캐릭터 변경 성공');

      // 변경 후 정보 새로고침
      await loadMyInfo();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Member] 캐릭터 변경 실패: $e');
      print('❌ [Member] StackTrace: $stackTrace');

      String errorMessage = '캐릭터 변경에 실패했습니다.';
      if (e is DioException && e.response?.statusCode == 400) {
        errorMessage = '유효하지 않은 캐릭터 타입입니다.';
      }

      state = state.copyWith(errorMessage: errorMessage);

      return false;
    }
  }

  /// 소셜 계정 연동
  Future<bool> linkSocialAccount(String provider, String socialId) async {
    print('🔄 [Member] 소셜 계정 연동 시작: $provider');

    try {
      final request = SocialLinkRequest(
        socialProvider: provider,
        socialId: socialId,
      );

      await _memberClient.linkSocialAccount(request);

      print('✅ [Member] 소셜 계정 연동 성공');

      // 연동 후 정보 새로고침
      await loadMyInfo();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Member] 소셜 계정 연동 실패: $e');
      print('❌ [Member] StackTrace: $stackTrace');

      String errorMessage = '소셜 계정 연동에 실패했습니다.';
      if (e is DioException && e.response?.statusCode == 409) {
        errorMessage = '이미 연동된 소셜 계정입니다.';
      }

      state = state.copyWith(errorMessage: errorMessage);

      return false;
    }
  }

  /// 소셜 계정 연동 해제
  Future<bool> unlinkSocialAccount(String provider) async {
    print('🔄 [Member] 소셜 계정 연동 해제 시작: $provider');

    try {
      await _memberClient.unlinkSocialAccount(provider);

      print('✅ [Member] 소셜 계정 연동 해제 성공');

      // 해제 후 정보 새로고침
      await loadMyInfo();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Member] 소셜 계정 연동 해제 실패: $e');
      print('❌ [Member] StackTrace: $stackTrace');

      String errorMessage = '소셜 계정 연동 해제에 실패했습니다.';
      if (e is DioException && e.response?.statusCode == 404) {
        errorMessage = '연동된 소셜 계정이 없습니다.';
      }

      state = state.copyWith(errorMessage: errorMessage);

      return false;
    }
  }

  /// 회원 탈퇴
  Future<bool> withdraw(String type, {String? description}) async {
    print('🔄 [Member] 회원 탈퇴 시작');
    print('  - type: $type');

    try {
      final request = MemberWithdrawRequest(
        type: type,
        description: description,
      );

      await _memberClient.withdraw(request);

      print('✅ [Member] 회원 탈퇴 성공');

      // 탈퇴 후 상태 초기화
      clearMemberInfo();

      return true;
    } catch (e, stackTrace) {
      print('❌ [Member] 회원 탈퇴 실패: $e');
      print('❌ [Member] StackTrace: $stackTrace');

      state = state.copyWith(
        errorMessage: '회원 탈퇴에 실패했습니다.',
      );

      return false;
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// 회원 정보 초기화 (로그아웃/탈퇴 시 사용)
  void clearMemberInfo() {
    print('🔄 [Member] 회원 정보 초기화');
    state = const MemberState();
  }
}
