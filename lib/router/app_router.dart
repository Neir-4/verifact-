import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../screens/setup/setup_screen.dart';
import '../screens/table/table_screen.dart';
import '../screens/scan/scan_screen.dart';
import '../screens/reveal/reveal_screen.dart';
import '../screens/scoring/scoring_screen.dart';
import '../screens/scoreboard/scoreboard_screen.dart';
import '../screens/end/end_game_screen.dart';
import '../screens/rules/rules_screen.dart';
import '../screens/landing/landing_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/landing',
    redirect: (context, state) {
      final sess = ref.read(sessionProvider);
      final location = state.matchedLocation;

      if (sess.isFinished && !location.startsWith('/end')) {
        return '/end';
      }
      if (!sess.isStarted) {
        if (location != '/landing' && location != '/rulebook' && location != '/setup') {
          return '/landing';
        }
      } else {
        if (location == '/landing' || location == '/setup' || location == '/rulebook') {
          return '/table';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
      GoRoute(
        path: '/rulebook',
        name: 'rulebook',
        builder: (context, state) => const RulesScreen(showBackButton: true),
      ),
      GoRoute(
        path: '/setup',
        name: 'setup',
        builder: (context, state) => const SetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _AppShell(location: state.matchedLocation, child: child);
        },
        routes: [
          GoRoute(
            path: '/table',
            name: 'table',
            builder: (context, state) => const TableScreen(),
          ),
          GoRoute(
            path: '/scoreboard',
            name: 'scoreboard',
            builder: (context, state) => const ScoreboardScreen(),
          ),
          GoRoute(
            path: '/rules',
            name: 'rules',
            builder: (context, state) => const RulesScreen(showBackButton: false),
          ),
        ],
      ),
      // Full-screen routes (no shell)
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: '/reveal',
        name: 'reveal',
        builder: (context, state) => const RevealScreen(),
      ),
      GoRoute(
        path: '/scoring',
        name: 'scoring',
        builder: (context, state) => const ScoringScreen(),
      ),
      GoRoute(
        path: '/end',
        name: 'end',
        builder: (context, state) => const EndGameScreen(),
      ),
    ],
  );
});

class _AppShell extends StatelessWidget {
  final String location;
  final Widget child;
  const _AppShell({required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    int currentIndex = 0;
    if (location.startsWith('/table')) currentIndex = 0;
    if (location.startsWith('/scoreboard')) currentIndex = 1;
    if (location.startsWith('/rules')) currentIndex = 2;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/table');
              break;
            case 1:
              context.go('/scoreboard');
              break;
            case 2:
              context.go('/rules');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Permainan',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard_outlined),
            selectedIcon: Icon(Icons.leaderboard),
            label: 'Skor',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Aturan',
          ),
        ],
      ),
    );
  }
}
