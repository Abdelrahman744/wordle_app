import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// ---------- 6. History ----------
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const items = [
      ['CRANE', true, '3/6', 'Today'],
      ['PLUMB', true, '5/6', 'Yesterday'],
      ['GHOST', false, 'X/6', '2 days ago'],
      ['SHARK', true, '4/6', '3 days ago'],
      ['MOUSE', true, '2/6', '4 days ago'],
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'History',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 16),
        for (final e in items)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  e[1] as bool ? Icons.check_circle : Icons.cancel,
                  color: e[1] as bool ? kGreen : Colors.redAccent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e[0] as String,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      e[2] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      e[3] as String,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
