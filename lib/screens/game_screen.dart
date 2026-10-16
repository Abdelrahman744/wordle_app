import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'how_to_play_screen.dart';

// ---------- 8. Game ----------
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Static demo board so the design looks complete
  final rows = ['CRANE', 'SLOTH', 'PLUMB', '', '', ''];
  final colors = [
    [kGray, kYellow, kGray, kGray, kGreen],
    [kGray, kGray, kGray, kGray, kGray],
    [kGreen, kGreen, kGreen, kYellow, kGray],
  ];

  @override
  Widget build(BuildContext context) {
    const keys = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WORDLE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => go(context, const HowToPlayScreen()),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              for (int r = 0; r < 6; r++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int c = 0; c < 5; c++)
                      Tile(
                        rows[r].isEmpty ? '' : rows[r][c],
                        color: r < colors.length ? colors[r][c] : null,
                        size: 56,
                      ),
                  ],
                ),
              const SizedBox(height: 10),
              for (int k = 0; k < 3; k++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (k == 2) _key('ENTER', 58, kGray),
                      for (final ch in keys[k].split('')) _key(ch, 34, kGray),
                      if (k == 2) _key('⌫', 58, kGray),
                    ],
                  ),
                ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _key(String t, double w, Color c) => Container(
    width: w,
    height: 52,
    margin: const EdgeInsets.symmetric(horizontal: 2.5),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: c.withValues(alpha: .55),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      t,
      style: TextStyle(
        fontSize: t.length > 1 ? 11 : 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
