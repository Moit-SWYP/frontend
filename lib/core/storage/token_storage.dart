import 'package:shared_preferences/shared_preferences.dart';

/// 토큰 저장소
///
/// SharedPreferences를 사용하여 액세스 토큰과 리프레시 토큰을 안전하게 저장합니다.
class TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// 액세스 토큰 저장
  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  /// 리프레시 토큰 저장
  Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  /// 토큰 저장 (액세스 + 리프레시)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// 액세스 토큰 가져오기
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// 토큰 존재 여부 확인
  Future<bool> hasTokens() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_accessTokenKey) &&
        prefs.containsKey(_refreshTokenKey);
  }

  /// 액세스 토큰 삭제
  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
  }

  /// 리프레시 토큰 삭제
  Future<void> clearRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_refreshTokenKey);
  }

  /// 모든 토큰 삭제
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
