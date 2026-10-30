// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import '../services/session.dart';
import '../theme/app_colors.dart';
import '../widgets/shared_widgets.dart';
import 'auth_screens.dart';

class ProfileScreen extends StatefulWidget {
  final bool isGuest;
  const ProfileScreen({super.key, this.isGuest = false});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool dark = true, sound = true, hard = false;

  void _logout() async {
    await Session.instance.clear();
    if (mounted) go(context, const SignInScreen(), replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.instance.user;
    final displayName = widget.isGuest ? 'Guest' : (user?.username ?? 'Player');
    final displayEmail = widget.isGuest ? '—' : (user?.email ?? '—');
    final joinedAt = widget.isGuest || user == null
        ? '—'
        : _formatDate(user.createdAt);

    return ListView(
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
        Center(
          child: Text(
            displayName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        Center(
          child: Text(
            displayEmail,
            style: const TextStyle(color: Colors.white60),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            widget.isGuest ? '' : 'Member since $joinedAt',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          value: dark,
          activeColor: kGreen,
          title: const Text('Dark mode'),
          onChanged: (v) => setState(() => dark = v),
        ),
        SwitchListTile(
          value: sound,
          activeColor: kGreen,
          title: const Text('Sound effects'),
          onChanged: (v) => setState(() => sound = v),
        ),
        SwitchListTile(
          value: hard,
          activeColor: kGreen,
          title: const Text('Hard mode'),
          onChanged: (v) => setState(() => hard = v),
        ),
        const SizedBox(height: 20),
        BigButton(
          'Log out',
          _logout,
          outlined: true,
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    // e.g. "Oct 16, 2026"
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }
}
