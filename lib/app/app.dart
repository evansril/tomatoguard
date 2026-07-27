import 'package:flutter/material.dart';
import 'package:tomatoguard/app/theme.dart';
import 'package:tomatoguard/features/splash/splash_page.dart';

class TomatoGuardApp extends StatelessWidget {
  const TomatoGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TomatoGuard',
      debugShowCheckedModeBanner: false,
      theme: TomatoGuardTheme.light(),
      darkTheme: TomatoGuardTheme.dark(),
      themeMode: ThemeMode.system,
      home: const SplashPage(),
    );
  }
}
