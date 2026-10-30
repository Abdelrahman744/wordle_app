import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

void go(BuildContext context, Widget screen, {bool replace = false}) {
  final route = MaterialPageRoute(builder: (_) => screen);
  if (replace) {
    Navigator.pushReplacement(context, route);
  } else {
    Navigator.push(context, route);
  }
}

// ---------- shared widgets ----------
class Tile extends StatelessWidget {
  final String letter;
  final Color? color;
  final double size;
  const Tile(this.letter, {this.color, this.size = 52, super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    margin: const EdgeInsets.all(3),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color ?? Colors.transparent,
      border: color == null ? Border.all(color: kGray, width: 2) : null,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      letter,
      style: TextStyle(fontSize: size * .5, fontWeight: FontWeight.w800),
    ),
  );
}

class StatCard extends StatelessWidget {
  final String icon, value, label;
  const StatCard(this.icon, this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18),
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        Text(label, style: const TextStyle(color: Colors.white60)),
      ],
    ),
  );
}

class Logo extends StatelessWidget {
  const Logo({super.key});
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: const [
      Tile('W', color: kGreen, size: 44),
      Tile('O', color: kYellow, size: 44),
      Tile('R', color: kGray, size: 44),
      Tile('D', color: kGreen, size: 44),
      Tile('L', color: kYellow, size: 44),
      Tile('E', color: kGray, size: 44),
    ],
  );
}

class BigButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool outlined;
  final bool loading;
  const BigButton(this.text, this.onTap,
      {this.outlined = false, this.loading = false, super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: outlined
        ? OutlinedButton(
            onPressed: loading ? null : onTap,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: kGreen, strokeWidth: 2))
                : Text(
                    text,
                    style: const TextStyle(fontSize: 16, color: kGreen),
                  ),
          )
        : ElevatedButton(
            onPressed: loading ? null : onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: kGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : Text(
                    text,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
  );
}
