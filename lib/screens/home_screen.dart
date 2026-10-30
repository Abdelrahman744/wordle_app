// lib/screens/home_screen.dart
import 'package:flutter/material.dart';

import '../models/stats_model.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isGuest;
  const HomeScreen({super.key, this.isGuest = false});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StatsModel _stats = StatsModel.empty;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (!widget.isGuest) {
      _load();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _load() async {
    try {
      final s = await ApiService.instance.getStats();
      if (mounted) setState(() { _stats = s; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.isGuest
        ? 'Guest'
        : (Session.instance.user?.username ?? 'Player');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Hi, $username',
                style: const TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => go(context, const HowToPlayScreen()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Logo(),
              const SizedBox(height: 18),
              const Text("Today's puzzle is ready",
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              BigButton(
                'Play daily word',
                () => go(context, const GameScreen(mode: 'daily')),
              ),
              const SizedBox(height: 10),
              BigButton(
                'Practice mode',
                () => go(context, const GameScreen(mode: 'practice')),
                outlined: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: kGreen))
        else
          Row(
            children: [
              Expanded(
                child: StatCard(
                  '🔥',
                  '${_stats.currentStreak}',
                  'Day streak',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  '🏆',
                  '${_stats.winRate}%',
                  'Win rate',
                ),
              ),
            ],
          ),
        const SizedBox(height: 18),
        ListTile(
          tileColor: kCard,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          leading: const Icon(Icons.menu_book, color: kGreen),
          title: const Text('How to play'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(context, const HowToPlayScreen()),
        ),
      ],
    );
  }
}
