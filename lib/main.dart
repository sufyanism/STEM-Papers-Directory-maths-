import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/core/theme/app_theme.dart';
import 'app/core/theme/theme_provider.dart';
import 'app/features/auth/presentation/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox("papers_cache");

  runApp(
    const ProviderScope(
      child: ScholarsHorizonApp(),
    ),
  );
}

class ScholarsHorizonApp extends ConsumerWidget {
  const ScholarsHorizonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: "Scholar's Horizon",
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      themeMode: themeMode,

      home: const SplashPage(),
    );
  }
}