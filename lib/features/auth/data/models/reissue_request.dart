import 'package:json_annotation/json_annotation.dart';

part 'reissue_request.g.dart';

/// 토큰 재발급 요청 모델
@JsonSerializable()
class ReissueRequest {
  final String refreshToken;

  ReissueRequest({
    required this.refreshToken,
  });

  factory ReissueRequest.fromJson(Map<String, dynamic> json) =>
      _$ReissueRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ReissueRequestToJson(this);
}
