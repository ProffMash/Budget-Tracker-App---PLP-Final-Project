import 'package:flutter/material.dart';

class ThemeIcon extends StatelessWidget {
  final bool isDark;
  final VoidCallback onPressed;
  const ThemeIcon({super.key, required this.isDark, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny),
      tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      onPressed: onPressed,
    );
  }
}
