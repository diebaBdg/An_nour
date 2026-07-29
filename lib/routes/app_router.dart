import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/prayer/prayer_screen.dart';
import '../screens/quran/quran_screen.dart';
import '../screens/duas/duas_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/qibla/qibla_screen.dart';
import '../screens/tasbih/tasbih_screen.dart';
import '../screens/quran/surah_detail_screen.dart';
import '../screens/duas/dua_detail_screen.dart';
import '../screens/hadith/hadith_screen.dart';
import '../screens/hadith/hadith_detail_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../models/dua_model.dart';
import '../models/hadith_model.dart';

/// Clés de navigation pour le shell principal.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/prayer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrayerScreen(),
            ),
          ),
          GoRoute(
            path: '/quran',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QuranScreen(),
            ),
          ),
          GoRoute(
            path: '/duas',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DuasScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/quran/:number',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final number = int.parse(state.pathParameters['number']!);
          return SurahDetailScreen(surahNumber: number);
        },
      ),
      GoRoute(
        path: '/qibla',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const QiblaScreen(),
      ),
      GoRoute(
        path: '/tasbih',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const TasbihScreen(),
      ),
      GoRoute(
        path: '/dua/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Dua;
          return DuaDetailScreen(dua: extra);
        },
      ),
      GoRoute(
        path: '/hadiths',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const HadithScreen(),
      ),
      GoRoute(
        path: '/hadith/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Hadith;
          return HadithDetailScreen(hadith: extra);
        },
      ),
      GoRoute(
        path: '/calendar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/favorites',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
});

/// Shell avec Bottom Navigation Bar Material 3.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/prayer')) return 1;
    if (location.startsWith('/quran')) return 2;
    if (location.startsWith('/duas')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) {
          const paths = ['/home', '/prayer', '/quran', '/duas', '/profile'];
          context.go(paths[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'Prières',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Coran',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Douas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
        indicatorColor: AppColors.emerald.withValues(alpha: 0.15),
      ),
    );
  }
}
