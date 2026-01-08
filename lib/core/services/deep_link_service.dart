import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/features/meeting/providers/meeting_provider.dart';

/// 딥링크 서비스
///
/// moit://invite/{token} 또는 https://moit.shop/invite/{token} 형태의 링크 처리
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
  /// moit://invite/{token} 또는 https://moit.shop/invite/{token}
  Future<void> _handleDeepLink(Uri uri, BuildContext context, WidgetRef ref) async {
    print('🔍 [DeepLink] URI 분석 시작');
    print('  - scheme: ${uri.scheme}');
    print('  - host: ${uri.host}');
    print('  - path: ${uri.path}');
    print('  - pathSegments: ${uri.pathSegments}');

    // 1. 초대 링크인지 확인
    bool isInviteLink = false;
    String? inviteToken;

    // moit://invite/{token} 형태
    if (uri.scheme == 'moit' && uri.host == 'invite') {
      isInviteLink = true;
      // pathSegments가 있으면 첫번째가 token
      if (uri.pathSegments.isNotEmpty) {
        inviteToken = uri.pathSegments.first;
      }
    }
    // https://moit.shop/invite/{token} 형태
    else if (uri.scheme == 'https' &&
             uri.host == 'moit.shop' &&
             uri.pathSegments.isNotEmpty &&
             uri.pathSegments.first == 'invite') {
      isInviteLink = true;
      // pathSegments[1]이 token
      if (uri.pathSegments.length > 1) {
        inviteToken = uri.pathSegments[1];
      }
    }

    if (!isInviteLink) {
      print('⚠️ [DeepLink] 초대 링크가 아닙니다');
      return;
    }

    if (inviteToken == null || inviteToken.isEmpty) {
      print('❌ [DeepLink] 토큰이 없습니다');
      _showError(context, '유효하지 않은 초대 링크입니다');
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
      final success = await ref
          .read(meetingProvider.notifier)
          .joinMeetingFromLink(inviteToken);

      if (!success) {
        throw Exception('모임 참여 실패');
      }

      print('✅ [DeepLink] 모임 참여 성공');

      // 4. 참여한 모임 정보 가져오기
      // (백엔드에서 참여 후 meetingId를 반환하면 좋지만, 없다면 홈 데이터를 새로고침)
      // 일단 홈 화면으로 이동 후 사용자가 직접 카드를 누르게 함

      // 로딩 닫기
      if (!context.mounted) return;
      Navigator.pop(context);

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('모임에 참여했습니다!'),
          duration: Duration(seconds: 2),
        ),
      );

      // TODO: 백엔드에서 참여한 meetingId를 반환하면, 해당 모임의 투표 화면으로 직접 이동
      // 현재는 홈 화면으로 이동

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
