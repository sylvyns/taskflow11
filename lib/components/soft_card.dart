import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Белая карточка с мягкой лавандовой тенью и скруглением.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap, this.color});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: const [BoxShadow(color: Color(0x149A88C9), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Material(
        color: color ?? Pastel.card,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: Pastel.outline)),
            child: child,
          ),
        ),
      ),
    );
  }
}

