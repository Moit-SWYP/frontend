import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';
import 'package:moit/features/meeting/presentation/screens/meeting_detail_screen.dart';

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

    // 2. 로딩 표시
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // 3. 모임 참여 API 호출
      print('🔄 [DeepLink] 모임 참여 시작');
      final meetingId = await ref
          .read(meetingProvider.notifier)
          .joinMeetingFromLink(inviteToken);

      print('✅ [DeepLink] 모임 참여 성공 - meetingId: $meetingId');

      // 로딩 닫기
      if (!context.mounted) return;
      Navigator.pop(context);

      // 4. 모임 상세 화면으로 이동
      if (meetingId != null) {
        // 백엔드가 meetingId를 반환하는 경우: 해당 모임 상세 화면으로 이동
        print('🔄 [DeepLink] 모임 상세 화면으로 이동: meetingId=$meetingId');

        // 모임 목록에서 해당 모임 찾기
        final meetings = ref.read(meetingProvider).meetings;
        final meeting = meetings.firstWhere(
          (m) => m.meetingId == meetingId,
          orElse: () => throw Exception('모임을 찾을 수 없습니다'),
        );

        if (!context.mounted) return;

        // 모임 상세 화면으로 네비게이션
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MeetingDetailScreen(meeting: meeting),
          ),
        );

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모임에 참여했습니다!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // 백엔드가 meetingId를 반환하지 않는 경우: 홈 화면으로 이동
        print('⚠️ [DeepLink] meetingId 없음 - 홈 화면으로 이동');

        // 성공 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('모임에 참여했습니다!\n홈 화면에서 확인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      print('❌ [DeepLink] 모임 참여 실패: $e');

      // 로딩 닫기
      if (!context.mounted) return;
      Navigator.pop(context);

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

      _showError(context, errorMessage);
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
