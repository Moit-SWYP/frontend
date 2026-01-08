import 'package:moit/core/services/naver_login_service.dart';
import 'package:moit/features/auth/data/clients/auth_client.dart';

/// 네이버 소셜 로그인 통합 예제
///
/// 이 파일은 네이버 로그인의 전체 흐름을 보여주는 예제입니다.
/// 실제 사용 시에는 AuthProvider나 화면에서 사용하세요.
class NaverAuthExample {
  final AuthClient _authClient = AuthClient();

  /// 네이버 로그인 전체 흐름
  ///
  /// 1. NaverLoginService를 통해 네이버 로그인 (앱 or 웹뷰)
  /// 2. 액세스 토큰을 백엔드로 전송
  /// 3. 백엔드 응답 처리 (기존 회원 or 신규 회원)
  Future<void> performNaverLogin() async {
    try {
      print('🚀 [네이버 로그인 흐름] 시작');

      // ===== 1단계: 네이버 SDK를 통한 로그인 =====
      // - 네이버 앱 설치되어 있으면: 자동 로그인
      // - 네이버 앱 없으면: 웹뷰를 통한 이메일/비밀번호 입력
      print('📱 [1단계] 네이버 SDK 로그인 시도');
      final userInfo = await NaverLoginService.login();

      print('✅ [1단계] 네이버 SDK 로그인 성공');
      print('📱 사용자 정보: $userInfo');

      final accessToken = userInfo['accessToken'] as String;

      // ===== 2단계: 백엔드로 액세스 토큰 전송 =====
      print('🌐 [2단계] 백엔드로 액세스 토큰 전송');
      final response = await _authClient.naverLogin(accessToken);

      print('✅ [2단계] 백엔드 응답 성공');
      print('🌐 응답 데이터: ${response.data}');

      // ===== 3단계: 응답 처리 =====
      if (response.data?.signupRequired ?? false) {
        // 신규 회원 → 회원가입 화면으로 이동
        print('🆕 [3단계] 신규 회원 → 회원가입 필요');
        print('📝 이메일: ${userInfo['email']}');
        print('📝 닉네임: ${userInfo['nickname']}');

        // TODO: 회원가입 화면으로 이동
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => SignupDetailScreen(
        //     email: userInfo['email'],
        //     socialProvider: 'NAVER',
        //     socialId: userInfo['socialId'],
        //   ),
        // ));
      } else {
        // 기존 회원 → 홈 화면으로 이동
        print('✅ [3단계] 기존 회원 → 로그인 완료');
        print('🔑 Access Token: ${response.data?.tokens?.accessToken}');
        print('🔑 Refresh Token: ${response.data?.tokens?.refreshToken}');

        // TODO: 토큰 저장 및 홈 화면으로 이동
        // await TokenStorage.saveTokens(
        //   accessToken: response.data.tokens!.accessToken,
        //   refreshToken: response.data.tokens!.refreshToken,
        // );
        // Navigator.pushReplacementNamed(context, '/home');
      }

      print('🎉 [네이버 로그인 흐름] 완료');
    } on Exception catch (e) {
      // 사용자가 로그인을 취소한 경우
      if (e.toString().contains('취소')) {
        print('⚠️ [네이버 로그인] 사용자가 로그인을 취소했습니다.');
        // TODO: 사용자에게 알림 표시
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('로그인이 취소되었습니다.')),
        // );
      } else {
        // 기타 에러
        print('❌ [네이버 로그인] 에러 발생: $e');
        // TODO: 에러 메시지 표시
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
        // );
      }
    } catch (e) {
      // 예상하지 못한 에러
      print('❌ [네이버 로그인] 예상하지 못한 에러: $e');
      // TODO: 개발자에게 에러 리포팅
    }
  }

  /// 네이버 로그아웃
  Future<void> performNaverLogout() async {
    try {
      print('🚀 [네이버 로그아웃] 시작');

      // 1. 백엔드 로그아웃 (Refresh Token 삭제)
      await _authClient.logout();

      // 2. 네이버 SDK 로그아웃
      await NaverLoginService.logout();

      print('✅ [네이버 로그아웃] 완료');
    } catch (e) {
      print('❌ [네이버 로그아웃] 에러: $e');
      rethrow;
    }
  }
}
