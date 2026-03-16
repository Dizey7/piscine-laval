import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme/mtl_theme.dart';
import 'services/cache_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/live_screen.dart';
import 'screens/favorites_screen.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Locale française
  await initializeDateFormatting('fr_CA', null);
  await initializeDateFormatting('fr_FR', null);

  // Cache local Hive
  final cacheService = CacheService();
  await cacheService.initialize();

  // Notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        cacheServiceProvider.overrideWithValue(cacheService),
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const MtlLiveApp(),
    ),
  );
}

class MtlLiveApp extends ConsumerWidget {
  const MtlLiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MTL Live',
      debugShowCheckedModeBanner: false,
      theme: MtlTheme.light,
      darkTheme: MtlTheme.dark,
      themeMode: ThemeMode.dark, // Dark mode par défaut
      home: const AppShell(),
    );
  }
}

/// Shell principal avec Bottom Navigation
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _screens = [
    HomeScreen(),
    ExploreScreen(),
    CalendarScreen(),
    LiveScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: MtlColors.darkCardAlt, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: (index) =>
              ref.read(selectedTabProvider.notifier).state = index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explorer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Calendrier',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors_outlined),
              activeIcon: Icon(Icons.sensors),
              label: 'En direct',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Mes plans',
            ),
          ],
        ),
      ),
    );
  }
}
