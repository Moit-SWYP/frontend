/// API 설정
class ApiConfig {
  /// 백엔드 API 기본 URL
  ///
  /// 프로덕션: https://moit.shop
  /// 개발/로컬:
  /// - Android 에뮬레이터: 10.0.2.2 = Mac의 localhost
  /// - iOS 시뮬레이터: localhost 사용 가능
  /// - 실제 디바이스: Mac의 실제 IP 주소 사용 (예: 192.168.0.10)
  static const String baseUrl = 'https://moit.shop';

  /// API 엔드포인트
  static const String login = '/api/auth/login';
  static const String signup = '/api/auth/signup';
  static const String logout = '/api/auth/logout';
  static const String reissue = '/api/auth/reissue';
  static const String memberMe = '/api/members/me';
  static const String withdraw = '/api/members/me/withdraw';
  static const String socialLink = '/api/members/me/social-accounts';

  /// 요청 타임아웃 (초)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  /// 전체 URL 생성
  static String getUrl(String endpoint) => '$baseUrl$endpoint';
}
