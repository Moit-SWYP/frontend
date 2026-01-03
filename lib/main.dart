import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moit/core/router/app_router.dart';
import 'package:moit/core/theme/app_theme.dart';
import 'package:moit/core/services/kakao_login_service.dart';

void main() {
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
