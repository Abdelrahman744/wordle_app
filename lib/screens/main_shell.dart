// lib/screens/main_shell.dart
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';

class MainShell extends StatefulWidget {
  final bool isGuest;
  const MainShell({super.key, this.isGuest = false});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(isGuest: widget.isGuest),
      StatsScreen(isGuest: widget.isGuest),
      HistoryScreen(isGuest: widget.isGuest),
      ProfileScreen(isGuest: widget.isGuest),
    ];

    return Scaffold(
      body: SafeArea(child: pages[i]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: kCard,
        indicatorColor: kGreen.withValues(alpha: .3),
        selectedIndex: i,
        onDestinationSelected: (v) => setState(() => i = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
