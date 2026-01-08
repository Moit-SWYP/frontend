import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';

/// 네이버 로그인 서비스
class NaverLoginService {
  /// 네이버 로그인
  ///
  /// 네이버 앱이 설치되어 있으면 네이버 앱으로 자동 로그인,
  /// 없으면 웹뷰를 통한 이메일/비밀번호 입력 방식으로 로그인
  ///
  /// 성공 시 사용자 정보 반환
  static Future<Map<String, dynamic>> login() async {
    try {
      print('📱 [네이버 로그인] 로그인 시도');

      // 네이버 로그인 실행
      // - 네이버 앱이 설치되어 있으면: 네이버 앱을 통한 자동 로그인
      // - 네이버 앱이 없으면: 웹뷰를 통한 이메일/비밀번호 입력 방식
      final result = await FlutterNaverLogin.logIn();

      // 로그인 상태 확인
      if (result.status == NaverLoginStatus.loggedIn) {
        print('✅ [네이버 로그인] 로그인 성공');

        // 액세스 토큰 및 계정 정보 가져오기
        final token = result.accessToken;
        final account = result.account;

        // 🔍 디버깅: 네이버에서 받은 사용자 정보 출력
        print('📱 [네이버 로그인] 액세스 토큰: ${token?.accessToken}');
        print('📱 [네이버 로그인] 사용자 ID: ${account?.id}');
        print('📱 [네이버 로그인] 이메일: ${account?.email}');
        print('📱 [네이버 로그인] 이름: ${account?.name}');
        print('📱 [네이버 로그인] 닉네임: ${account?.nickname}');

        final email = account?.email;

        // 이메일이 없는 경우 예외 처리
        if (email == null || email.isEmpty) {
          throw Exception('네이버 계정에서 이메일 정보를 가져올 수 없습니다.');
        }

        final userInfo = {
          'socialProvider': 'NAVER',
          'socialId': account?.id ?? '',
          'email': email,
          'nickname': account?.nickname ?? account?.name ?? '',
          'profileImage': account?.profileImage ?? '',
          'accessToken': token?.accessToken ?? '', // 백엔드로 전송할 액세스 토큰
        };

        print('✅ [네이버 로그인] 변환된 사용자 정보: $userInfo');

        return userInfo;
      } else {
        // 로그인 실패 (loggedOut 또는 error)
        print('❌ [네이버 로그인] 로그인 실패 - 상태: ${result.status}');
        print('❌ [네이버 로그인] 에러 메시지: ${result.errorMessage}');
        throw Exception('네이버 로그인 실패: ${result.errorMessage ?? result.status.toString()}');
      }
    } catch (e) {
      print('❌ [네이버 로그인] 에러: $e');
      rethrow;
    }
  }

  /// 네이버 로그아웃
  static Future<void> logout() async {
    try {
      print('📱 [네이버 로그인] 로그아웃 시도');
      await FlutterNaverLogin.logOut();
      print('✅ [네이버 로그인] 로그아웃 성공');
    } catch (e) {
      print('❌ [네이버 로그인] 로그아웃 실패: $e');
      throw Exception('네이버 로그아웃 실패: $e');
    }
  }

  /// 네이버 연결 해제 (토큰 삭제)
  static Future<void> logOutAndDeleteToken() async {
    try {
      print('📱 [네이버 로그인] 토큰 삭제 및 로그아웃 시도');
      await FlutterNaverLogin.logOutAndDeleteToken();
      print('✅ [네이버 로그인] 토큰 삭제 및 로그아웃 성공');
    } catch (e) {
      print('❌ [네이버 로그인] 토큰 삭제 실패: $e');
      throw Exception('네이버 토큰 삭제 실패: $e');
    }
  }

}
