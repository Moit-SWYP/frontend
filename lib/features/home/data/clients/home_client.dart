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

      print('✅ [HomeClient] 홈 데이터 조회 성공');
      print('  - homeMeetings: ${response.data['homeMeetings']?.length ?? 0}개');
      print('  - waitingMeetings: ${response.data['waitingMeetings']?.length ?? 0}개');

      final homeResponse = HomeResponse.fromJson(response.data);
      return homeResponse;
    } catch (e, stackTrace) {
      print('❌ [HomeClient] getHomeData 에러: $e');
      print('❌ [HomeClient] StackTrace: $stackTrace');
      rethrow;
    }
  }
}
