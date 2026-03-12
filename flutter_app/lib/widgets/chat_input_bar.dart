import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
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

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  bool _isRecording = false;
  int _recordingSeconds = 0;

  // Pulsing animation for the mic button while recording
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.7,
    upperBound: 1.0,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _textController.dispose();
    _recorder.dispose();
    _pulseController.dispose();
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

  Future<void> _handleMicTap() async {
    if (widget.isProcessing) return;

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        AppSnackbar.error(context, 'Microphone permission denied');
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      // Tick the recording timer every second
      _tickRecordingTimer();

      HapticFeedback.mediumImpact();
      AppLogger.debug('Voice recording started: $path');
    } catch (e) {
      AppLogger.error('Failed to start recording', e);
      if (mounted) {
        AppSnackbar.error(context, 'Failed to start recording: $e');
      }
    }
  }

  void _tickRecordingTimer() {
    if (!_isRecording) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || !_isRecording) return;
      setState(() => _recordingSeconds++);
      _tickRecordingTimer();
    });
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stop();

      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });

      HapticFeedback.mediumImpact();

      if (path == null) {
        AppLogger.warning('Recording stopped but no file path returned');
        return;
      }

      final audioFile = File(path);
      if (!audioFile.existsSync() || audioFile.lengthSync() == 0) {
        AppLogger.warning('Recorded file is empty or missing: $path');
        if (mounted) {
          AppSnackbar.warning(context, 'Recording too short — try again');
        }
        return;
      }

      AppLogger.debug('Voice recording stopped: $path');
      widget.onSendAudio(audioFile, 'm4a');
    } catch (e) {
      AppLogger.error('Failed to stop recording', e);
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
      });
      if (mounted) {
        AppSnackbar.error(context, 'Failed to save recording: $e');
      }
    }
  }

  void _handleSendText() {
    if (widget.isProcessing) return;

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    widget.onSendText(text);
    _textController.clear();
  }

  String get _recordingLabel {
    final m = _recordingSeconds ~/ 60;
    final s = _recordingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
          // Mic button — tap to record, tap again to stop & send
          ScaleTransition(
            scale: _isRecording ? _pulseController : const AlwaysStoppedAnimation(1.0),
            child: IconButton(
              onPressed: widget.isProcessing ? null : _handleMicTap,
              icon: Icon(
                _isRecording ? Icons.stop_circle : Icons.mic,
                color: _isRecording
                    ? Colors.redAccent
                    : widget.isProcessing
                        ? AppTheme.textTertiary
                        : AppTheme.neonGreen,
              ),
              tooltip: _isRecording ? 'Stop recording' : 'Record voice message',
            ),
          ),

          // Recording timer — shown in place of camera when recording
          if (_isRecording)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                _recordingLabel,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
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
                hintText: _isRecording ? 'Recording...' : 'Describe your food...',
                hintStyle: TextStyle(
                  color: _isRecording ? Colors.redAccent : AppTheme.textTertiary,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: _isRecording ? Colors.redAccent : AppTheme.borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: _isRecording ? Colors.redAccent : AppTheme.borderColor,
                  ),
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
              enabled: !_isRecording,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSendText(),
            ),
          ),

          // Send button
          IconButton(
            onPressed: (widget.isProcessing || _isRecording) ? null : _handleSendText,
            icon: Icon(
              Icons.send,
              color: (widget.isProcessing || _isRecording)
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
