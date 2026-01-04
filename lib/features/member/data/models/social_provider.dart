/// 소셜 로그인 제공자
enum SocialProvider {
  KAKAO,
  NAVER,
}

extension SocialProviderExtension on SocialProvider {
  /// 제공자 이름
  String get displayName {
    switch (this) {
      case SocialProvider.KAKAO:
        return '카카오';
      case SocialProvider.NAVER:
        return '네이버';
    }
  }

  /// Enum을 문자열로 변환
  String toJson() => name;

  /// 문자열을 Enum으로 변환
  static SocialProvider fromJson(String json) {
    return SocialProvider.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SocialProvider.KAKAO,
    );
  }
}
