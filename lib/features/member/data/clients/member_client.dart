import 'package:dio/dio.dart';
import 'package:moit/core/models/api_response.dart';
import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/member/data/models/member_profile.dart';

/// Member API 클라이언트
class MemberClient {
  final DioClient _dioClient = DioClient();

  /// 내 프로필 조회
  ///
  /// GET /api/members/me
  ///
  /// Authorization 헤더에 Access Token 필요
  Future<ApiResponse<MemberProfile>> getMyProfile() async {
    try {
      print('🌐 [MemberClient] GET /api/members/me');

      final response = await _dioClient.get('/api/members/me');

      print('🌐 [MemberClient] Response Status: ${response.statusCode}');
      print('🌐 [MemberClient] Response Data: ${response.data}');
      print('🌐 [MemberClient] Response Data Type: ${response.data.runtimeType}');
      print('🌐 [MemberClient] Data field: ${response.data['data']}');
      print('🌐 [MemberClient] Data field type: ${response.data['data'].runtimeType}');

      final dataField = response.data['data'];
      print('🔍 [MemberClient] Parsing data field...');
      print('🔍 [MemberClient] email: ${dataField['email']}');
      print('🔍 [MemberClient] nickname: ${dataField['nickname']}');
      print('🔍 [MemberClient] birthDate: ${dataField['birthDate']}');
      print('🔍 [MemberClient] gender: ${dataField['gender']} (type: ${dataField['gender'].runtimeType})');
      print('🔍 [MemberClient] socialAccounts: ${dataField['socialAccounts']}');

      print('🔍 [MemberClient] MemberProfile.fromJson 호출 시작...');
      final memberProfile = MemberProfile.fromJson(response.data['data']);
      print('✅ [MemberClient] MemberProfile.fromJson 성공!');

      return ApiResponse<MemberProfile>(
        code: response.data['code']?.toString() ?? '200',
        message: response.data['message'] ?? 'Success',
        data: memberProfile,
      );
    } catch (e, stackTrace) {
      print('❌ [MemberClient] getMyProfile 에러: $e');
      print('❌ [MemberClient] StackTrace: $stackTrace');

      if (e is DioException) {
        print('❌ [MemberClient] Status Code: ${e.response?.statusCode}');
        print('❌ [MemberClient] Response Data: ${e.response?.data}');
        print('❌ [MemberClient] Error Message: ${e.message}');
      }

      rethrow;
    }
  }
}
