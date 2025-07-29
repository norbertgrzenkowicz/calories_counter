import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomLoadingDialog extends StatefulWidget {
  final String message;

  const CustomLoadingDialog({
    Key? key,
    this.message = 'Finding your perfect spot...',
  }) : super(key: key);

  @override
  State<CustomLoadingDialog> createState() => _CustomLoadingDialogState();
}

class _CustomLoadingDialogState extends State<CustomLoadingDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.charcoal.withOpacity(0.15),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom animated loading indicator
            AnimatedBuilder(
              animation: _rotationController,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.buttonGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  );
                },
              ),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * 3.14159,
                  child: child,
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              widget.message,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.charcoal,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We\'re curating amazing local spots just for you',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.charcoal.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => CustomLoadingDialog(
            message: message ?? 'Finding your perfect spot...',
          ),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
