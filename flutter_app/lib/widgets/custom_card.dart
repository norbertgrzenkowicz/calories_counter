import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool hasBlur;
  final Color? backgroundColor;

  const CustomCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.hasBlur = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            // Subtle shadow for depth
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 12,
              spreadRadius: 0,
            ),
            // Additional soft shadow for dark mode depth
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}
