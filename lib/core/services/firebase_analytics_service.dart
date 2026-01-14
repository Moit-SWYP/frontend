import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

/// Firebase Analytics 서비스
///
/// 앱 전반의 사용자 행동 추적 및 이벤트 로깅을 담당합니다.
class FirebaseAnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver _observer =
      FirebaseAnalyticsObserver(analytics: _analytics);
  static final Logger _logger = Logger();

  /// FirebaseAnalyticsObserver getter
  ///
  /// MaterialApp의 navigatorObservers에 추가하여 화면 전환을 자동으로 추적합니다.
  static FirebaseAnalyticsObserver get observer => _observer;

  /// 회원가입 완료 이벤트 로깅
  ///
  /// 사용자가 회원가입을 성공적으로 완료했을 때 호출됩니다.
  static Future<void> logSignupComplete() async {
    try {
      await _analytics.logEvent(
        name: 'signup_complete',
        parameters: <String, Object>{
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _logger.i('[Firebase Analytics] signup_complete 이벤트 로깅 완료');
    } catch (e) {
      _logger.e('[Firebase Analytics] signup_complete 이벤트 로깅 실패: $e');
    }
  }

  /// 커스텀 이벤트 로깅
  ///
  /// 필요 시 다른 이벤트를 로깅할 수 있는 범용 메서드입니다.
  static Future<void> logEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      _logger.i('[Firebase Analytics] $eventName 이벤트 로깅 완료');
    } catch (e) {
      _logger.e('[Firebase Analytics] $eventName 이벤트 로깅 실패: $e');
    }
  }
}
