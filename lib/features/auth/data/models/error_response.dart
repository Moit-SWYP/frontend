import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

/// API 에러 응답 모델
@JsonSerializable()
class ErrorResponse {
  final String code;
  final String message;
  final Map<String, String>? data;

  ErrorResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);
}
