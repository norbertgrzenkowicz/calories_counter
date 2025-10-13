import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../core/app_logger.dart';

class ChatInputBar extends StatefulWidget {
  final Function(String text) onSendText;
  final Function(File image) onSendImage;
  final Function(File audio, String format) onSendAudio;
  final bool isProcessing;

  const ChatInputBar({
    super.key,
    required this.onSendText,
    required this.onSendImage,
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

  Future<void> _handleImagePicker() async {
    if (widget.isProcessing) return;

    try {
      final source = await _showPhotoSourceDialog();
      if (source == null) return;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        AppLogger.debug('Image picked: ${pickedFile.path}');
        widget.onSendImage(File(pickedFile.path));
      }
    } catch (e) {
      AppLogger.error('Image picker error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showPhotoSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          title: const Text('Select Photo Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppTheme.neonBlue),
                title: const Text('Take Photo'),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppTheme.neonBlue),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Audio recording temporarily disabled due to package compatibility issues
  Future<void> _handleAudioRecording() async {
    if (widget.isProcessing) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Audio recording temporarily unavailable'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _handleSendText() {
    if (widget.isProcessing) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

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
          // Image button
          IconButton(
            onPressed: widget.isProcessing ? null : _handleImagePicker,
            icon: Icon(
              Icons.camera_alt,
              color: widget.isProcessing
                  ? AppTheme.textTertiary
                  : AppTheme.neonBlue,
            ),
            tooltip: 'Add image',
          ),
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
              enabled: !widget.isProcessing,
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
            icon: widget.isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
                    ),
                  )
                : const Icon(
                    Icons.send,
                    color: AppTheme.neonGreen,
                  ),
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
