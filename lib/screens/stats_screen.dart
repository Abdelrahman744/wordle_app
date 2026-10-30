// lib/screens/stats_screen.dart
import 'package:flutter/material.dart';

import '../models/stats_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';

class StatsScreen extends StatefulWidget {
  final bool isGuest;
  const StatsScreen({super.key, this.isGuest = false});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  StatsModel? _stats;
  bool _loading = true;
  String? _error;

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
    setState(() { _loading = true; _error = null; });
    try {
      final s = await ApiService.instance.getStats();
      if (mounted) setState(() { _stats = s; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kGreen,
      onRefresh: widget.isGuest ? () async {} : _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Statistics',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (widget.isGuest)
            _guestBanner()
          else if (_loading)
            const Center(
                child: Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: CircularProgressIndicator(color: kGreen),
            ))
          else if (_error != null)
            Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 40),
                  const SizedBox(height: 10),
                  Text(_error!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 14),
                  TextButton(
                      onPressed: _load, child: const Text('Try again')),
                ],
              ),
            ))
          else
            _statsBody(_stats!),
        ],
      ),
    );
  }

  Widget _guestBanner() => Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: kCard, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: const [
            Icon(Icons.lock_outline, size: 40, color: Colors.white38),
            SizedBox(height: 12),
            Text(
              'Sign in to see your stats',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Your game history and statistics are saved when you have an account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );

  Widget _statsBody(StatsModel s) {
    final dist = s.distribution;
    final maxDist = dist.isEmpty ? 1 : dist.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: StatCard('🎮', '${s.played}', 'Played')),
            const SizedBox(width: 10),
            Expanded(child: StatCard('✅', '${s.winRate}%', 'Win rate')),
            const SizedBox(width: 10),
            Expanded(child: StatCard('🔥', '${s.currentStreak}', 'Streak')),
          ],
        ),
        const SizedBox(height: 22),
        if (s.played == 0)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Text(
                'No games yet. Play your first game!',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          )
        else ...[
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
                  SizedBox(
                      width: 20,
                      child: Text('${n + 1}')),
                  Expanded(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor:
                          (dist[n] / (maxDist == 0 ? 1 : maxDist))
                              .clamp(.08, 1.0),
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
                          style: const TextStyle(
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
