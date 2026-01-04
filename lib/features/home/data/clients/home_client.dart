import 'package:moit/core/network/dio_client.dart';
import 'package:moit/features/home/data/models/home_response.dart';

/// 홈 API 클라이언트
class HomeClient {
  final DioClient _dioClient = DioClient();

  /// 홈 화면 데이터 조회
  /// GET /api/home
  Future<HomeResponse> getHomeData() async {
    try {
      print('🌐 [HomeClient] GET /api/home');
      final response = await _dioClient.get('/api/home');

      print('🌐 [HomeClient] Response Status: ${response.statusCode}');
      print('🌐 [HomeClient] Response Data: ${response.data}');

      // 공통 응답 형식 처리: {code, message, data: {homeMeetings: [], waitingMeetings: []}}
      final dataField = response.data is Map<String, dynamic>
          ? response.data['data']
          : response.data;

      final homeResponse = HomeResponse.fromJson(
        dataField is Map<String, dynamic> ? dataField : {'homeMeetings': [], 'waitingMeetings': []}
      );

      print('✅ [HomeClient] 홈 데이터 조회 성공');
      print('  - homeMeetings: ${homeResponse.homeMeetings.length}개');
      print('  - waitingMeetings: ${homeResponse.waitingMeetings.length}개');

      return homeResponse;
    } catch (e, stackTrace) {
      print('❌ [HomeClient] getHomeData 에러: $e');
      print('❌ [HomeClient] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
