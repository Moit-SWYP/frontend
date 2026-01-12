import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

/// 카카오 로그인 서비스
class KakaoLoginService {
  /// 카카오 SDK 초기화
  ///
  /// main.dart에서 앱 시작 시 호출해야 함
  static Future<void> initialize() async {
    KakaoSdk.init(
      nativeAppKey: '5f85d667c593c86d5bc8372844f15800',
    );

    // 🔑 카카오가 실제로 사용하는 키 해시 출력 (디버깅용)
    try {
      var keyHash = await KakaoSdk.origin;
      print('🔑 [카카오 키 해시] 카카오가 원하는 진짜 키: $keyHash');
      print('🔑 [카카오 키 해시] 이 값을 카카오 개발자 콘솔에 등록하세요!');
    } catch (e) {
      print('⚠️ [카카오 키 해시] 키 해시를 가져올 수 없습니다: $e');
    }
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
        try {
          // 카카오톡으로 로그인 시도
          print('📱 [카카오 로그인] 카카오톡 앱으로 로그인 시도');
          await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          // 카카오톡 로그인 실패 시 → 카카오 계정 로그인으로 전환
          print('⚠️ [카카오 로그인] 카카오톡 로그인 실패 → 카카오 계정 로그인으로 전환');
          print('⚠️ [카카오 로그인] 에러 상세: $e');
          await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        // 카카오 계정으로 로그인
        print('📱 [카카오 로그인] 카카오 계정으로 로그인');
        await UserApi.instance.loginWithKakaoAccount();
      }

      // 사용자 정보 가져오기
      User user = await UserApi.instance.me();

      // 🔍 디버깅: 카카오에서 받은 사용자 정보 출력
      print('📱 [카카오 로그인] 사용자 ID: ${user.id}');
      print('📱 [카카오 로그인] 이메일: ${user.kakaoAccount?.email}');
      print('📱 [카카오 로그인] 닉네임: ${user.kakaoAccount?.profile?.nickname}');
      print('📱 [카카오 로그인] 이메일 제공 동의: ${user.kakaoAccount?.emailNeedsAgreement}');

      final email = user.kakaoAccount?.email;

      // 이메일이 없는 경우 예외 처리
      if (email == null || email.isEmpty) {
        throw Exception('카카오 계정에서 이메일 정보를 가져올 수 없습니다. 카카오 개발자 콘솔에서 이메일 동의 항목을 활성화해주세요.');
      }

      final userInfo = {
        'socialProvider': 'KAKAO',
        'socialId': user.id.toString(),
        'email': email,
        'nickname': user.kakaoAccount?.profile?.nickname ?? '',
        'profileImage': user.kakaoAccount?.profile?.profileImageUrl ?? '',
      };

      print('✅ [카카오 로그인] 변환된 사용자 정보: $userInfo');

      return userInfo;
    } catch (e) {
      print('❌ [카카오 로그인] 에러: $e');
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
