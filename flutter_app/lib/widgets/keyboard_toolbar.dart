import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class KeyboardToolbar extends StatelessWidget {
  final Widget child;
  final FocusNode focusNode;
  final String? label;

  const KeyboardToolbar({
    super.key,
    required this.child,
    required this.focusNode,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: _FocusNotifier(focusNode),
          builder: (context, hasFocus, _) {
            if (!hasFocus) return const SizedBox.shrink();
            return Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                border: Border(
                  top: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (label != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          label!,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        focusNode.unfocus();
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                      },
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FocusNotifier extends ValueNotifier<bool> {
  final FocusNode focusNode;

  _FocusNotifier(this.focusNode) : super(focusNode.hasFocus) {
    focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    value = focusNode.hasFocus;
  }

  @override
  void dispose() {
    focusNode.removeListener(_onFocusChange);
    super.dispose();
  }
}
