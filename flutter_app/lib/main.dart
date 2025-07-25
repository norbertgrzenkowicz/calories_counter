import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    print('Camera error: $e');
  }
  runApp(FoodScannerApp(cameras: cameras));
}

class FoodScannerApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  
  const FoodScannerApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Scanner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CameraScreen(cameras: cameras),
    );
  }
}

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
      _controller!.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isLoading = true);
    
    try {
      final image = await _controller!.takePicture();
      await _uploadImage(image.path);
    } catch (e) {
      _showError('Failed to take picture: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _uploadImage(String imagePath) async {
    try {
      Uint8List imageBytes = await File(imagePath).readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      var response = await http.post(
        Uri.parse('http://localhost:5001/analyze_food'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'image': base64Image}),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _result = json.decode(response.body);
        });
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Upload failed: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Food Scanner')),
        body: const Center(child: Text('No camera available')),
      );
    }
    
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Food Scanner')),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: CameraPreview(_controller!),
          ),
          if (_result != null)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description:', style: Theme.of(context).textTheme.titleMedium),
                    Text(_result!['description'] ?? ''),
                    const SizedBox(height: 8),
                    Text('Calories:', style: Theme.of(context).textTheme.titleMedium),
                    Text(_result!['calories'] ?? ''),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _takePicture,
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Scan Food'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}