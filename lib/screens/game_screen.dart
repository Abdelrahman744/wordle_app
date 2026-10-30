// lib/screens/game_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/words.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'how_to_play_screen.dart';

// ─── Letter state enum ────────────────────────────────────────────────────────
enum LetterState { empty, absent, present, correct }

// ─── GameScreen ───────────────────────────────────────────────────────────────
class GameScreen extends StatefulWidget {
  final String mode; // 'daily' or 'practice'
  const GameScreen({super.key, this.mode = 'practice'});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int _maxRows = 6;
  static const int _wordLen = 5;

  late String _answer;
  final List<String> _guesses = List.filled(_maxRows, '');
  // _colors[r][c] — color per tile
  final List<List<Color?>> _colors =
      List.generate(_maxRows, (_) => List.filled(_wordLen, null));
  // Best known state per key
  final Map<String, LetterState> _keyStates = {};

  int _currentRow = 0;
  String _currentInput = '';
  bool _gameOver = false;
  bool _won = false;
  String? _message; // small toast message

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  // ── Pick the word ──────────────────────────────────────────────────────────
  void _startGame() {
    setState(() {
      _answer = _pickWord();
      for (int r = 0; r < _maxRows; r++) {
        _guesses[r] = '';
        for (int c = 0; c < _wordLen; c++) {
          _colors[r][c] = null;
        }
      }
      _keyStates.clear();
      _currentRow = 0;
      _currentInput = '';
      _gameOver = false;
      _won = false;
      _message = null;
    });
  }

  String _pickWord() {
    if (widget.mode == 'daily') {
      // Same word for everyone on the same calendar day.
      final epoch = DateTime(2024, 1, 1);
      final today = DateTime.now();
      final dayIndex = today.difference(epoch).inDays;
      return kWordList[dayIndex % kWordList.length];
    } else {
      return kWordList[Random().nextInt(kWordList.length)];
    }
  }

  // ── Key press ─────────────────────────────────────────────────────────────
  void _onKey(String key) {
    if (_gameOver) return;
    if (key == '⌫') {
      if (_currentInput.isNotEmpty) {
        setState(() => _currentInput =
            _currentInput.substring(0, _currentInput.length - 1));
      }
      return;
    }
    if (key == 'ENTER') {
      _submitGuess();
      return;
    }

    // Option B: Block gray (eliminated) letters from being typed
    if (_keyStates[key] == LetterState.absent) {
      _showMessage('$key is not in the word');
      return;
    }

    if (_currentInput.length < _wordLen) {
      setState(() => _currentInput += key);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submitGuess() {
    if (_currentInput.length < _wordLen) {
      _showMessage('Not enough letters');
      return;
    }
    if (!kWordList.contains(_currentInput)) {
      _showMessage('Not in word list');
      return;
    }

    final result = _evaluate(_currentInput, _answer);
    setState(() {
      _guesses[_currentRow] = _currentInput;
      for (int c = 0; c < _wordLen; c++) {
        _colors[_currentRow][c] = result[c];
      }
      // Update keyboard key states
      for (int c = 0; c < _wordLen; c++) {
        final ch = _currentInput[c];
        final newState = result[c] == kGreen
            ? LetterState.correct
            : result[c] == kYellow
                ? LetterState.present
                : LetterState.absent;
        final prev = _keyStates[ch] ?? LetterState.empty;
        // Only upgrade: correct > present > absent > empty
        if (_isBetter(newState, prev)) {
          _keyStates[ch] = newState;
        }
      }

      if (_currentInput == _answer) {
        _won = true;
        _gameOver = true;
      } else if (_currentRow == _maxRows - 1) {
        _gameOver = true;
      }

      _currentRow++;
      _currentInput = '';
    });

    if (_gameOver) {
      // Small delay so the last row tiles paint first
      Future.delayed(const Duration(milliseconds: 400), _showEndDialog);
    }
  }

  bool _isBetter(LetterState a, LetterState b) {
    const order = [
      LetterState.empty,
      LetterState.absent,
      LetterState.present,
      LetterState.correct
    ];
    return order.indexOf(a) > order.indexOf(b);
  }

  // ── Wordle evaluation (official duplicate-letter rules) ────────────────────
  List<Color> _evaluate(String guess, String target) {
    final result = List<Color>.filled(_wordLen, kGray);
    final targetChars = target.split('').toList();
    final guessChars = guess.split('').toList();

    // Pass 1: mark greens
    for (int i = 0; i < _wordLen; i++) {
      if (guessChars[i] == targetChars[i]) {
        result[i] = kGreen;
        targetChars[i] = '*'; // consumed
        guessChars[i] = ' '; // skip in pass 2
      }
    }
    // Pass 2: mark yellows
    for (int i = 0; i < _wordLen; i++) {
      if (guessChars[i] == ' ') continue;
      final idx = targetChars.indexOf(guessChars[i]);
      if (idx != -1) {
        result[i] = kYellow;
        targetChars[idx] = '*'; // consume
      }
    }
    return result;
  }

  // ── End dialog ────────────────────────────────────────────────────────────
  void _showEndDialog() async {
    // Save to server if logged in
    if (Session.instance.isLoggedIn) {
      try {
        await ApiService.instance.saveGame(
          word: _answer,
          won: _won,
          attempts: _won ? _currentRow : 6,
          mode: widget.mode,
        );
      } catch (_) {
        // Non-fatal — game is still shown
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F21),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          _won ? '🎉 You won!' : '😞 Game over',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _won
                  ? 'Solved in $_currentRow ${_currentRow == 1 ? "guess" : "guesses"}!'
                  : 'The word was:',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              _answer,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  color: kGreen),
            ),
            if (!Session.instance.isLoggedIn) ...[
              const SizedBox(height: 10),
              const Text(
                'Sign in to save your results.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // go back to home
            },
            child:
                const Text('Back to home', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play again',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Small toast ────────────────────────────────────────────────────────────
  void _showMessage(String msg) {
    setState(() => _message = msg);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _message = null);
    });
  }

  // ── Key colour ─────────────────────────────────────────────────────────────
  Color _keyColor(String ch) {
    switch (_keyStates[ch]) {
      case LetterState.correct:
        return kGreen;
      case LetterState.present:
        return kYellow;
      case LetterState.absent:
        return const Color(0xFF3A3A3C); // Darker gray for eliminated letters
      default:
        return kGray;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    const rows = ['QWERTYUIOP', 'ASDFGHJKL', 'ZXCVBNM'];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == 'daily' ? 'DAILY WORD' : 'WORDLE',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => go(context, const HowToPlayScreen()),
          ),
          if (widget.mode == 'practice')
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startGame,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // ── Board ──────────────────────────────────────────────
                  for (int r = 0; r < _maxRows; r++)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int c = 0; c < _wordLen; c++)
                          Tile(
                            _cellLetter(r, c),
                            color: _colors[r][c],
                            size: 56,
                          ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  // ── Keyboard ───────────────────────────────────────────
                  for (int k = 0; k < 3; k++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (k == 2)
                            _key('ENTER', 52, _keyColor('ENTER')),
                          for (final ch in rows[k].split(''))
                            _key(ch, 34, _keyColor(ch)),
                          if (k == 2)
                            _key('⌫', 52, _keyColor('⌫')),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            // ── Toast message ────────────────────────────────────────────
            if (_message != null)
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _message!,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // The letter to show in a tile
  String _cellLetter(int r, int c) {
    if (r < _currentRow) {
      // Already submitted row
      return _guesses[r].isNotEmpty ? _guesses[r][c] : '';
    }
    if (r == _currentRow) {
      // Current typing row
      return c < _currentInput.length ? _currentInput[c] : '';
    }
    return '';
  }

  // On-screen key widget — tappable
  Widget _key(String t, double w, Color c) => GestureDetector(
        onTap: () => _onKey(t),
        child: Container(
          width: w,
          height: 52,
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.withValues(alpha: .65),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            t,
            style: TextStyle(
              fontSize: t.length > 1 ? 11 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
