/// 회원 캐릭터 타입
///
/// 8가지 캐릭터 유형
enum CharacterType {
  FOODIE, // 미식가
  DRINKER, // 애주가
  HEALER, // 휴식가
  CULTURE_LOVER, // 관람형
  TRAVELER, // 모험가
  ACTIVE, // 활동가
  TREND_SETTER, // 주도가
  STUDYER, // 독습가
}

extension CharacterTypeExtension on CharacterType {
  /// 캐릭터 타입 한글 이름
  String get displayName {
    switch (this) {
      case CharacterType.FOODIE:
        return '미식가';
      case CharacterType.DRINKER:
        return '애주가';
      case CharacterType.HEALER:
        return '휴식가';
      case CharacterType.CULTURE_LOVER:
        return '관람형';
      case CharacterType.TRAVELER:
        return '모험가';
      case CharacterType.ACTIVE:
        return '활동가';
      case CharacterType.TREND_SETTER:
        return '주도가';
      case CharacterType.STUDYER:
        return '독습가';
    }
  }

  /// 캐릭터 타입 설명
  String get description {
    switch (this) {
      case CharacterType.FOODIE:
        return '맛집 탐방을 즐기는 미식가';
      case CharacterType.DRINKER:
        return '술자리를 좋아하는 애주가';
      case CharacterType.HEALER:
        return '휴식과 힐링을 중요시하는 휴식가';
      case CharacterType.CULTURE_LOVER:
        return '문화생활을 즐기는 관람형';
      case CharacterType.TRAVELER:
        return '새로운 곳을 탐험하는 모험가';
      case CharacterType.ACTIVE:
        return '활발한 활동을 선호하는 활동가';
      case CharacterType.TREND_SETTER:
        return '트렌드를 주도하는 주도가';
      case CharacterType.STUDYER:
        return '학습과 자기계발을 추구하는 독습가';
    }
  }

  /// Enum을 문자열로 변환
  String toJson() => name;

  /// 문자열을 Enum으로 변환
  static CharacterType fromJson(String json) {
    return CharacterType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => CharacterType.FOODIE,
    );
  }
}
