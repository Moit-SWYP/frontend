import 'package:json_annotation/json_annotation.dart';
import 'package:moit/features/auth/data/models/login_request.dart';
import 'package:moit/features/member/data/models/character_type.dart';

part 'signup_request.g.dart';

/// 성별
enum Gender {
  @JsonValue('MALE')
  male,
  @JsonValue('FEMALE')
  female,
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
