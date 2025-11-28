import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routes/app_router.dart';
import 'core/theme/flexvault_theme.dart';

class FlexVaultApp extends ConsumerWidget {
  const FlexVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FlexVault',
      debugShowCheckedModeBanner: false,
      theme: FlexVaultTheme.lightTheme,
      darkTheme: FlexVaultTheme.darkTheme,
      routerConfig: router,
    );
  }
}

