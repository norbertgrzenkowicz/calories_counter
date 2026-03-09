import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../core/app_logger.dart';
import '../utils/app_snackbar.dart';
import '../utils/file_upload_validator.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String text) onSendText;
  final Function(File audio, String format) onSendAudio;
  final Function(File image) onSendImage;
  final bool isProcessing;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendAudio,
    required this.onSendImage,
    this.isProcessing = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleImagePicker() async {
    if (widget.isProcessing) return;

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: const Text('Send Photo', style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.neonGreen),
              title: const Text('Camera', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.neonGreen),
              title: const Text('Gallery', style: TextStyle(color: AppTheme.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final xFile = await _imagePicker.pickImage(source: source, imageQuality: 85);
      if (xFile == null) return;

      final validationResult = await FileUploadValidator.validateImageFile(xFile);
      if (validationResult != FileValidationResult.valid) {
        if (mounted) {
          AppSnackbar.error(context, FileUploadValidator.getErrorMessage(validationResult));
        }
        return;
      }

      AppLogger.debug('Image picked for chat: ${xFile.path}');
      widget.onSendImage(File(xFile.path));
    } catch (e) {
      AppLogger.error('Image picker error', e);
      if (mounted) {
        AppSnackbar.error(context, 'Failed to pick image: $e');
      }
    }
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
          // Camera button
          IconButton(
            onPressed: widget.isProcessing ? null : _handleImagePicker,
            icon: Icon(
              Icons.camera_alt,
              color: widget.isProcessing ? AppTheme.textTertiary : AppTheme.neonGreen,
            ),
            tooltip: 'Send photo for analysis',
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
