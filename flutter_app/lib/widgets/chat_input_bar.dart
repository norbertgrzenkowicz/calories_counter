import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../core/app_logger.dart';
import '../utils/app_snackbar.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String text) onSendText;
  final Function(File audio, String format) onSendAudio;
  final bool isProcessing;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendAudio,
    this.isProcessing = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Audio recording temporarily disabled due to package compatibility issues
  Future<void> _handleAudioRecording() async {
    if (widget.isProcessing) return;

    AppSnackbar.warning(context, 'Audio recording temporarily unavailable');
  }

  void _handleSendText() {
    if (widget.isProcessing) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    widget.onSendText(text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Audio button (temporarily disabled)
          IconButton(
            onPressed: widget.isProcessing ? null : _handleAudioRecording,
            icon: Icon(
              Icons.mic_off,
              color: AppTheme.textTertiary,
            ),
            tooltip: 'Audio recording unavailable',
          ),
          // Text input
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Describe your food...',
                hintStyle: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.neonGreen),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                filled: true,
                fillColor: AppTheme.darkBackground,
              ),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendText(),
            ),
          ),
          // Send button
          IconButton(
            onPressed: widget.isProcessing ? null : _handleSendText,
            icon: Icon(
              Icons.send,
              color: widget.isProcessing
                  ? AppTheme.textTertiary
                  : AppTheme.neonGreen,
            ),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
