// lib/screens/auth_screens.dart
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'main_shell.dart';

// ─────────────────────────────────────────────
// 1. Splash
// ─────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Always show the splash for at least 2 seconds.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Try to restore a saved token from SharedPreferences.
    final restored = await Session.instance.tryRestore();
    if (!mounted) return;

    if (restored) {
      // Token found — verify it's still valid with the server.
      try {
        final user = await ApiService.instance.getMe();
        await Session.instance.updateUser(user);
        if (mounted) go(context, const MainShell(), replace: true);
      } catch (_) {
        // Token invalid / server unreachable → go to sign-in.
        await Session.instance.clear();
        if (mounted) go(context, const SignInScreen(), replace: true);
      }
    } else {
      go(context, const SignInScreen(), replace: true);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Logo(),
              SizedBox(height: 20),
              Text(
                'Guess the word in six tries',
                style: TextStyle(color: Colors.white60),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: kGreen),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// 2. Sign In
// ─────────────────────────────────────────────
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _hide = true;
  bool _remember = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter your email and password.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.instance.login(
        email: email,
        password: password,
      );
      await Session.instance.save(
        result.token,
        result.user,
        persist: _remember,
      );
      if (mounted) go(context, const MainShell(), replace: true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 30),
              const Center(child: Logo()),
              const SizedBox(height: 36),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sign in to keep your streak going.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passCtrl,
                obscureText: _hide,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon:
                        Icon(_hide ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.redAccent)),
              ],
              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    activeColor: kGreen,
                    onChanged: (v) => setState(() => _remember = v!),
                  ),
                  const Text('Remember me'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot password?'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BigButton(
                'Sign in',
                _loading ? () {} : _signIn,
                loading: _loading,
              ),
              const SizedBox(height: 12),
              BigButton(
                'Continue as guest',
                () {
                  Session.instance.clear(); // ensure no stale session
                  go(context, const MainShell(isGuest: true), replace: true);
                },
                outlined: true,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => go(context, const SignUpScreen()),
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// 3. Sign Up
// ─────────────────────────────────────────────
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _hide = true;
  bool _loading = false;

  // Per-field error messages
  String? _usernameErr;
  String? _emailErr;
  String? _passErr;
  String? _confirmErr;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    bool ok = true;
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    _usernameErr = null;
    _emailErr = null;
    _passErr = null;
    _confirmErr = null;

    if (username.length < 3) {
      _usernameErr = 'Username must be at least 3 characters.';
      ok = false;
    }
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email)) {
      _emailErr = 'Please enter a valid email address.';
      ok = false;
    }
    if (pass.length < 6) {
      _passErr = 'Password must be at least 6 characters.';
      ok = false;
    }
    if (pass != confirm) {
      _confirmErr = 'Passwords do not match.';
      ok = false;
    }
    setState(() {});
    return ok;
  }

  Future<void> _register() async {
    if (!_validate()) return;

    setState(() => _loading = true);
    try {
      final result = await ApiService.instance.register(
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      await Session.instance.save(result.token, result.user);
      if (mounted) go(context, const MainShell(), replace: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Create account',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Join to track your stats and history.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 28),
              // Username
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              if (_usernameErr != null)
                _errText(_usernameErr!),
              const SizedBox(height: 14),
              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.mail_outline),
                ),
              ),
              if (_emailErr != null) _errText(_emailErr!),
              const SizedBox(height: 14),
              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _hide,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon:
                        Icon(_hide ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _hide = !_hide),
                  ),
                ),
              ),
              if (_passErr != null) _errText(_passErr!),
              const SizedBox(height: 14),
              // Confirm
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Confirm password',
                  prefixIcon: Icon(Icons.lock_reset),
                ),
              ),
              if (_confirmErr != null) _errText(_confirmErr!),
              const SizedBox(height: 26),
              BigButton(
                'Create account',
                _loading ? () {} : _register,
                loading: _loading,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sign in'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _errText(String msg) => Padding(
        padding: const EdgeInsets.only(top: 4, left: 4),
        child: Text(msg, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
      );
}
