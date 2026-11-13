import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.radius = 18});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Pastel.avatarColors[name.hashCode.abs() % Pastel.avatarColors.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        _initials(name),
        style: TextStyle(fontSize: radius * 0.75, fontWeight: FontWeight.w700, color: Pastel.ink),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
  }
}

