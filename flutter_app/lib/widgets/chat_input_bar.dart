import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
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
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _recordingPath;

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
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

  Future<void> _handleAudioRecording() async {
    if (widget.isProcessing) return;

    if (_isRecording) {
      // Stop recording
      await _stopRecording();
    } else {
      // Start recording
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      // Request permission
      if (await _audioRecorder.hasPermission()) {
        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Start recording
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
          ),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _recordingPath = filePath;
        });

        AppLogger.debug('Recording started: $filePath');
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      AppLogger.error('Start recording error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        AppLogger.debug('Recording stopped: $path');
        // Send audio file (format: m4a)
        widget.onSendAudio(File(path), 'm4a');
      }
    } catch (e) {
      AppLogger.error('Stop recording error', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop recording: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          // Audio button
          IconButton(
            onPressed: widget.isProcessing ? null : _handleAudioRecording,
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: _isRecording
                  ? AppTheme.neonRed
                  : (widget.isProcessing
                      ? AppTheme.textTertiary
                      : AppTheme.neonYellow),
            ),
            tooltip: _isRecording ? 'Stop recording' : 'Record audio',
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
