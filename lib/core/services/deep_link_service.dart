import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
import 'package:moit/features/meeting/presentation/screens/meeting_detail_screen.dart';
import 'package:moit/features/meeting/data/models/meeting_brief.dart';

/// 딥링크 서비스
///
/// 지원하는 초대 링크 형식:
/// - QueryParameter: https://moit.shop/invite?token={token} (권장)
/// - QueryParameter: moit://invite?token={token}
/// - Path Segment: https://moit.shop/invite/{token} (레거시 호환)
/// - Path Segment: moit://invite/{token} (레거시 호환)
///
/// 토큰 추출 우선순위:
/// 1. queryParameters['token'] (우선)
/// 2. pathSegments (레거시 호환)
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// NavigatorKey 설정 (main.dart에서 호출)
  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
    print('✅ [DeepLink] NavigatorKey 설정 완료');
  }

  /// 딥링크 리스너 초기화
  ///
  /// [context]: BuildContext
  /// [ref]: WidgetRef (Riverpod)
  Future<void> init(BuildContext context, WidgetRef ref) async {
    print('🔗 [DeepLink] 초기화 시작');

    // 앱이 종료된 상태에서 링크로 실행된 경우 처리
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      print('🔗 [DeepLink] 초기 링크 감지: $initialUri');
      _handleDeepLink(initialUri, context, ref);
    }

    // 앱이 실행 중일 때 링크가 열린 경우 처리
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        print('🔗 [DeepLink] 링크 감지: $uri');
        _handleDeepLink(uri, context, ref);
      },
      onError: (err) {
        print('❌ [DeepLink] 에러: $err');
      },
    );

    print('✅ [DeepLink] 초기화 완료');
  }

  /// 딥링크 처리
  ///
  /// 지원 형식:
  /// - QueryParameter: moit://invite?token={token}, https://moit.shop/invite?token={token}
  /// - Path Segment: moit://invite/{token}, https://moit.shop/invite/{token}
  Future<void> _handleDeepLink(Uri uri, BuildContext context, WidgetRef ref) async {
    print('🔍 [DeepLink] URI 분석 시작');
    print('  - scheme: ${uri.scheme}');
    print('  - host: ${uri.host}');
    print('  - path: ${uri.path}');
    print('  - pathSegments: ${uri.pathSegments}');
    print('  - queryParameters: ${uri.queryParameters}');

    // 1. 초대 링크인지 확인
    bool isInviteLink = false;
    String? inviteToken;

    // moit://invite 형태 (QueryParameter 또는 Path Segment)
    if (uri.scheme == 'moit' && uri.host == 'invite') {
      isInviteLink = true;

      // 1순위: QueryParameter (moit://invite?token=xxx)
      if (uri.queryParameters.containsKey('token')) {
        inviteToken = uri.queryParameters['token'];
      }
      // 2순위: Path Segment (moit://invite/xxx) - 레거시 호환
      else if (uri.pathSegments.isNotEmpty) {
        inviteToken = uri.pathSegments.first;
      }
    }
    // https://moit.shop/invite 형태 (QueryParameter 또는 Path Segment)
    else if (uri.scheme == 'https' &&
             uri.host == 'moit.shop' &&
             uri.pathSegments.isNotEmpty &&
             uri.pathSegments.first == 'invite') {
      isInviteLink = true;

      // 1순위: QueryParameter (https://moit.shop/invite?token=xxx) - 현재 백엔드 방식
      if (uri.queryParameters.containsKey('token')) {
        inviteToken = uri.queryParameters['token'];
      }
      // 2순위: Path Segment (https://moit.shop/invite/xxx) - 레거시 호환
      else if (uri.pathSegments.length > 1) {
        inviteToken = uri.pathSegments[1];
      }
    }

    if (!isInviteLink) {
      print('⚠️ [DeepLink] 초대 링크가 아닙니다');
      return;
    }

    if (inviteToken == null || inviteToken.isEmpty) {
      print('❌ [DeepLink] 토큰이 없습니다');
      print('  - URI: $uri');
      print('  - queryParameters: ${uri.queryParameters}');
      print('  - pathSegments: ${uri.pathSegments}');
      _showError(context, '유효하지 않은 초대 링크입니다.\n토큰이 누락되었습니다.');
      return;
    }

    print('✅ [DeepLink] 초대 토큰: $inviteToken');

    // 2. NavigatorKey에서 context 가져오기
    final navigatorContext = _navigatorKey?.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) {
      print('❌ [DeepLink] Navigator context를 사용할 수 없습니다');
      _showError(context, '앱을 다시 시작해주세요.');
      return;
    }

    // 3. 로딩 표시
    showDialog(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 4. 참여 전 모임 목록 저장 (참여 전후 비교용)
      print('📝 [DeepLink] 참여 전 모임 목록 저장');
      final meetingsBefore = ref.read(meetingProvider).meetings;
      final meetingIdsBefore = meetingsBefore.map((m) => m.meetingId).toSet();
      print('  - 참여 전 모임 개수: ${meetingsBefore.length}');
      print('  - 참여 전 모임 ID 목록: $meetingIdsBefore');

      // 5. 모임 참여 API 호출
      // joinMeetingFromLink() 내부에서 await loadMeetings()를 호출하여
      // 참여 후 최신 모임 목록을 자동으로 가져옵니다
      print('🔄 [DeepLink] 모임 참여 시작');
      await ref
          .read(meetingProvider.notifier)
          .joinMeetingFromLink(inviteToken);

      print('✅ [DeepLink] 모임 참여 성공');

      // 6. 참여 후 모임 목록에서 새로 추가된 모임 찾기
      print('🔍 [DeepLink] 새로 추가된 모임 찾기');
      final meetingsAfter = ref.read(meetingProvider).meetings;
      print('  - 참여 후 모임 개수: ${meetingsAfter.length}');

      // 로딩 닫기
      if (!navigatorContext.mounted) return;
      Navigator.of(navigatorContext).pop();

      // 참여 전에 없던 모임 찾기 (새로 추가된 모임)
      MeetingBrief? newMeeting;

      for (var meeting in meetingsAfter) {
        if (!meetingIdsBefore.contains(meeting.meetingId)) {
          newMeeting = meeting;
          print('✅ [DeepLink] 새로 참여한 모임 발견!');
          print('  - 모임 ID: ${meeting.meetingId}');
          print('  - 모임 제목: ${meeting.title}');
          break;
        }
      }

      // 7. 모임 상세 화면으로 이동
      if (newMeeting != null) {
        // 새로 참여한 모임을 찾은 경우: 해당 모임 상세 화면으로 이동
        final meeting = newMeeting; // 로컬 변수로 non-null 타입 확정

        if (!navigatorContext.mounted) return;

        print('🔄 [DeepLink] 모임 상세 화면으로 이동: ${meeting.title}');
        Navigator.of(navigatorContext).push(
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(meeting: meeting),
          ),
        );

        // 성공 메시지
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          SnackBar(
            content: Text('${meeting.title} 모임에 참여했습니다!'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // 새로운 모임을 찾지 못한 경우 (이미 참여했거나 예외 상황)
        print('⚠️ [DeepLink] 새로운 모임을 찾지 못함');
        print('  - 이미 참여한 모임이거나 목록 새로고침 실패');

        // 성공 메시지 (홈 화면에 머물기)
        ScaffoldMessenger.of(navigatorContext).showSnackBar(
          const SnackBar(
            content: Text('모임에 참여했습니다!\n홈 화면에서 확인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      print('❌ [DeepLink] 모임 참여 실패: $e');

      // 로딩 닫기
      if (!navigatorContext.mounted) return;
      Navigator.of(navigatorContext).pop();

      // 에러 메시지 표시
      String errorMessage = '모임 참여에 실패했습니다';

      if (e.toString().contains('409')) {
        errorMessage = '이미 참여한 모임입니다';
      } else if (e.toString().contains('404')) {
        errorMessage = '존재하지 않는 모임입니다';
      } else if (e.toString().contains('401') || e.toString().contains('AUTH001')) {
        // 권한 에러 (로그인 필요 또는 토큰 문제)
        errorMessage = '로그인이 필요합니다.\n다시 로그인 후 시도해주세요.';
      } else if (e.toString().contains('400')) {
        // 잘못된 요청 (토큰 형식 오류)
        errorMessage = '유효하지 않은 초대 링크입니다';
      }

      _showError(navigatorContext, errorMessage);
    }
  }

  /// 에러 메시지 표시
  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// 리스너 정리
  void dispose() {
    _linkSubscription?.cancel();
    print('🔗 [DeepLink] 리스너 정리 완료');
  }
}
