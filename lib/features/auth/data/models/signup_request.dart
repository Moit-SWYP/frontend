import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/auth/data/models/login_request.dart';

part 'signup_request.g.dart';

/// 성별
enum Gender {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
}

/// 캐릭터 타입 (8가지)
enum CharacterType {
  @JsonValue('FOODIE')
  foodie, // 미식가
  @JsonValue('DRINKER')
  drinker, // 술고래
  @JsonValue('HEALER')
  healer, // 힐러
  @JsonValue('CULTURE_LOVER')
  cultureLover, // 문화애호가
  @JsonValue('TRAVELER')
  traveler, // 여행가
  @JsonValue('ACTIVE')
  active, // 액티브
  @JsonValue('TREND_SETTER')
  trendSetter, // 트렌드세터
  @JsonValue('STUDYER')
  studyer, // 공부벌레
}

/// 회원가입 요청 모델
@JsonSerializable()
class SignupRequest {
  final LoginRequest login;
  final String nickname;
  final String birthDate; // yyyy-MM-dd 형식
  final Gender gender;
  final CharacterType characterType;

  SignupRequest({
    required this.login,
    required this.nickname,
    required this.birthDate,
    required this.gender,
    required this.characterType,
  });

  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}
