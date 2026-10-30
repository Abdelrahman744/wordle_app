// lib/screens/history_screen.dart
import 'package:flutter/material.dart';

import '../models/game_model.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  final bool isGuest;
  const HistoryScreen({super.key, this.isGuest = false});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GameModel> _games = [];
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
      final g = await ApiService.instance.getGames();
      if (mounted) setState(() { _games = g; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _relativeDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
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
            'History',
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
              ),
            )
          else if (_games.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Text(
                  'No games yet. Play your first game!',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            for (final g in _games) _gameCard(g),
        ],
      ),
    );
  }

  Widget _guestBanner() => Container(
        margin: const EdgeInsets.symmetric(vertical: 30),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF1F1F21),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: const [
            Icon(Icons.lock_outline, size: 40, color: Colors.white38),
            SizedBox(height: 12),
            Text(
              'Sign in to see your history',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text(
              'Your game results are saved when you have an account.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
          ],
        ),
      );

  Widget _gameCard(GameModel g) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F21),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              g.won ? Icons.check_circle : Icons.cancel,
              color: g.won ? kGreen : Colors.redAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                g.word,
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
                  g.won ? '${g.attempts}/6' : 'X/6',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  _relativeDate(g.date),
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
}
