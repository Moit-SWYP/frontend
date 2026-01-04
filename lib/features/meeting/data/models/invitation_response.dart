import 'package:json_annotation/json_annotation.dart';

part 'invitation_response.g.dart';

/// 초대 링크 응답
///
/// GET /api/meetings/{meetingId}/invitations/link
@JsonSerializable()
class InvitationResponse {
  final int meetingId;
  final String inviteToken; // UUID 형식

  InvitationResponse({
    required this.meetingId,
    required this.inviteToken,
  });

  factory InvitationResponse.fromJson(Map<String, dynamic> json) =>
      _$InvitationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationResponseToJson(this);

  /// 초대 링크 생성 (프론트엔드에서 사용)
  String get inviteLink => 'https://moit.shop/invite?token=$inviteToken';
}
