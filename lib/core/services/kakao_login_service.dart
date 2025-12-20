import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 서비스
class KakaoLoginService {
  /// 카카오 SDK 초기화
  ///
  /// main.dart에서 앱 시작 시 호출해야 함
  static void initialize() {
    KakaoSdk.init(
      nativeAppKey: '5f85d667c593c86d5bc8372844f15800',
    );
  }

  /// 카카오 로그인
  ///
  /// 카카오톡 앱이 설치되어 있으면 카카오톡으로 로그인,
  /// 없으면 카카오 계정으로 로그인
  ///
  /// 성공 시 사용자 정보 반환
  static Future<Map<String, dynamic>> login() async {
    try {
      // 카카오톡 설치 여부 확인
      bool installed = await isKakaoTalkInstalled();

      if (installed) {
        // 카카오톡으로 로그인
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        // 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();

      return {
        'socialProvider': 'KAKAO',
        'socialId': user.id.toString(),
        'email': user.kakaoAccount?.email ?? '',
        'nickname': user.kakaoAccount?.profile?.nickname ?? '',
        'profileImage': user.kakaoAccount?.profile?.profileImageUrl ?? '',
      };
    } catch (e) {
      throw Exception('카카오 로그인 실패: $e');
    }
  }

  /// 카카오 로그아웃
  static Future<void> logout() async {
    try {
      await UserApi.instance.logout();
    } catch (e) {
      throw Exception('카카오 로그아웃 실패: $e');
    }
  }

  /// 카카오 연결 해제 (회원 탈퇴)
  static Future<void> unlink() async {
    try {
      await UserApi.instance.unlink();
    } catch (e) {
      throw Exception('카카오 연결 해제 실패: $e');
    }
  }
}
