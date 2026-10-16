import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'auth_screens.dart';

// ---------- 7. Profile ----------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dark = true, sound = true, hard = false;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const SizedBox(height: 10),
      const Center(
        child: CircleAvatar(
          radius: 46,
          backgroundColor: kGreen,
          child: Icon(Icons.person, size: 50),
        ),
      ),
      const SizedBox(height: 12),
      const Center(
        child: Text(
          'Player One',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
      ),
      const Center(
        child: Text(
          'player@email.com',
          style: TextStyle(color: Colors.white60),
        ),
      ),
      const SizedBox(height: 24),
      SwitchListTile(
        value: dark,
        activeThumbColor: kGreen,
        title: const Text('Dark mode'),
        onChanged: (v) => setState(() => dark = v),
      ),
      SwitchListTile(
        value: sound,
        activeThumbColor: kGreen,
        title: const Text('Sound effects'),
        onChanged: (v) => setState(() => sound = v),
      ),
      SwitchListTile(
        value: hard,
        activeThumbColor: kGreen,
        title: const Text('Hard mode'),
        onChanged: (v) => setState(() => hard = v),
      ),
      const SizedBox(height: 20),
      BigButton(
        'Log out',
        () => go(context, const SignInScreen(), replace: true),
        outlined: true,
      ),
    ],
  );
}
