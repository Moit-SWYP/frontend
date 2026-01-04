import 'package:moit/features/member/data/models/member_info.dart';

/// 사용자 프로필 상태
class UserProfileState {
  final MemberInfo? profile;
  final bool isLoading;
  final String? errorMessage;

  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 프로필이 로드되었는지 여부
  bool get hasProfile => profile != null;

  /// 기본 닉네임 (프로필이 없을 경우 '사용자' 반환)
  String get displayName => profile?.nickname ?? '사용자';

  /// 기본 이메일
  String get displayEmail => profile?.email ?? '';

  UserProfileState copyWith({
    MemberInfo? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
