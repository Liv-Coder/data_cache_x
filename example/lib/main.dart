import 'package:flutter/material.dart';

import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/presentation/pages/analytics_page.dart';
import 'features/explorer/presentation/pages/explorer_page.dart';
import 'features/gallery/presentation/pages/gallery_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/news/presentation/pages/news_page.dart';
import 'features/playground/presentation/pages/playground_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the service locator
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CacheHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/news': (context) => const NewsPage(),
        '/gallery': (context) => const GalleryPage(),
        '/analytics': (context) => const AnalyticsPage(),
        '/explorer': (context) => const ExplorerPage(),
        '/playground': (context) => const PlaygroundPage(),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
