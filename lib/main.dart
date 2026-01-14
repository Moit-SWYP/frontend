import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moit/core/router/app_router.dart';
import 'package:moit/core/theme/app_theme.dart';
import 'package:moit/core/services/kakao_login_service.dart';
import 'package:moit/core/services/deep_link_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 한국어 로케일 초기화 (날짜 포맷팅용)
  await initializeDateFormatting('ko', null);

  // 카카오 SDK 초기화
  await KakaoLoginService.initialize();

  runApp(
    const ProviderScope(
      child: MoitApp(),
    ),
  );
}

class MoitApp extends ConsumerStatefulWidget {
  const MoitApp({super.key});

  @override
  ConsumerState<MoitApp> createState() => _MoitAppState();
}

class _MoitAppState extends ConsumerState<MoitApp> {
  final _deepLinkService = DeepLinkService();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // NavigatorKey를 DeepLinkService에 전달
    _deepLinkService.setNavigatorKey(_navigatorKey);

    // 딥링크 초기화는 첫 프레임 이후에 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkService.init(context, ref);
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Moit',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(ref, _navigatorKey),
      debugShowCheckedModeBanner: false,
    );
  }
}
