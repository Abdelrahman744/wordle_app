import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'main_shell.dart';

// ---------- 1. Splash ----------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) go(context, const SignInScreen(), replace: true);
    });
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

// ---------- 2. Sign in ----------
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool hide = true, remember = false;
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
          const TextField(
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            obscureText: hide,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => hide = !hide),
              ),
            ),
          ),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kGreen,
                onChanged: (v) => setState(() => remember = v!),
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
            () => go(context, const MainShell(), replace: true),
          ),
          const SizedBox(height: 12),
          BigButton(
            'Continue as guest',
            () => go(context, const MainShell(), replace: true),
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

// ---------- 3. Sign up ----------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool hide = true;
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
          const TextField(
            decoration: InputDecoration(
              hintText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            obscureText: hide,
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => hide = !hide),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Confirm password',
              prefixIcon: Icon(Icons.lock_reset),
            ),
          ),
          const SizedBox(height: 26),
          BigButton(
            'Create account',
            () => go(context, const MainShell(), replace: true),
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
}
