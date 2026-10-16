import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          const Expanded(
            child: Text(
              'Hi, Player',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
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
            const Text(
              "Today's puzzle is ready",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            BigButton('Play daily word', () => go(context, const GameScreen())),
            const SizedBox(height: 10),
            BigButton(
              'Practice mode',
              () => go(context, const GameScreen()),
              outlined: true,
            ),
          ],
        ),
      ),
      const SizedBox(height: 18),
      Row(
        children: const [
          Expanded(child: StatCard('🔥', '5', 'Day streak')),
          SizedBox(width: 12),
          Expanded(child: StatCard('🏆', '88%', 'Win rate')),
        ],
      ),
      const SizedBox(height: 18),
      ListTile(
        tileColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: const Icon(Icons.menu_book, color: kGreen),
        title: const Text('How to play'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => go(context, const HowToPlayScreen()),
      ),
    ],
  );
}
