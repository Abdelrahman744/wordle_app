import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

// ---------- 9. How to play ----------
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});
  Widget row(String w, int hi, Color c, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (int i = 0; i < 5; i++)
              Tile(w[i], color: i == hi ? c : null, size: 46),
          ],
        ),
        const SizedBox(height: 6),
        Text(text, style: const TextStyle(color: Colors.white70)),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('How to play')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Guess the word in 6 tries.',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Each guess must be a valid 5-letter word. After each guess, the tiles change color.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 24),
        row('WEARY', 0, kGreen, 'W is in the word and in the correct spot.'),
        row('PILLS', 1, kYellow, 'I is in the word but in the wrong spot.'),
        row('VAGUE', 3, kGray, 'U is not in the word in any spot.'),
        BigButton('Got it', () => Navigator.pop(context)),
      ],
    ),
  );
}
