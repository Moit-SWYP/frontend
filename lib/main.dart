import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moit/core/router/app_router.dart';
import 'package:moit/core/theme/app_theme.dart';
import 'package:moit/core/services/kakao_login_service.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일 초기화 (날짜 포맷팅용)
  await initializeDateFormatting('ko', null);

  // 카카오 SDK 초기화
  KakaoLoginService.initialize();

  runApp(
    const ProviderScope(
      child: MoitApp(),
    ),
  );
}

class MoitApp extends ConsumerWidget {
  const MoitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Moit',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router(ref),
      debugShowCheckedModeBanner: false,
    );
  }
}
