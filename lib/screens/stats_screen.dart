import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

// ---------- 5. Stats ----------
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const dist = [1, 4, 12, 15, 7, 3];
    final max = dist.reduce((a, b) => a > b ? a : b);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Statistics',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        Row(
          children: const [
            Expanded(child: StatCard('🎮', '42', 'Played')),
            SizedBox(width: 10),
            Expanded(child: StatCard('✅', '88%', 'Win rate')),
            SizedBox(width: 10),
            Expanded(child: StatCard('🔥', '5', 'Streak')),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Guess distribution',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        for (int n = 0; n < 6; n++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                SizedBox(width: 20, child: Text('${n + 1}')),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (dist[n] / max).clamp(.1, 1.0),
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.only(right: 8),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: kGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${dist[n]}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
