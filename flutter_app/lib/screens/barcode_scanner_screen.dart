import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController controller = MobileScannerController(
    formats: [
      BarcodeFormat.ean13, // Most food products
      BarcodeFormat.ean8, // Smaller food items
      BarcodeFormat.upcA, // US food products
      BarcodeFormat.upcE, // Compact US barcodes
    ],
    detectionSpeed: DetectionSpeed.noDuplicates,
    detectionTimeoutMs: 250,
    returnImage: false,
  );

  bool _isScanning = true;
  String? _scannedBarcode;
  bool _isTorchOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        setState(() {
          _isScanning = false;
          _scannedBarcode = barcode.rawValue!;
        });

        // Return the scanned barcode to the previous screen
        Navigator.pop(context, barcode.rawValue!);
      }
    }
  }

  void _toggleFlash() {
    controller.toggleTorch();
    setState(() {
      _isTorchOn = !_isTorchOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: controller,
            onDetect: _onBarcodeDetect,
          ),

          // Scanning overlay with cutout
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: AppTheme.primaryGreen,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Position the barcode within the frame to scan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom scanner overlay shape
class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    required this.borderColor,
    required this.borderWidth,
    required this.borderLength,
    required this.borderRadius,
    required this.cutOutSize,
  });

  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top + borderRadius)
        ..quadraticBezierTo(
            rect.left, rect.top, rect.left + borderRadius, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    Path getRightTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right - borderRadius, rect.top)
        ..quadraticBezierTo(
            rect.right, rect.top, rect.right, rect.top + borderRadius)
        ..lineTo(rect.right, rect.bottom);
    }

    Path getRightBottomPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.right, rect.bottom - borderRadius)
        ..quadraticBezierTo(
            rect.right, rect.bottom, rect.right - borderRadius, rect.bottom)
        ..lineTo(rect.left, rect.bottom);
    }

    Path getLeftBottomPath(Rect rect) {
      return Path()
        ..moveTo(rect.right, rect.bottom)
        ..lineTo(rect.left + borderRadius, rect.bottom)
        ..quadraticBezierTo(
            rect.left, rect.bottom, rect.left, rect.bottom - borderRadius)
        ..lineTo(rect.left, rect.top);
    }

    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderHeightSize = height / 2;
    final cutOutWidth = cutOutSize < width ? cutOutSize : width - borderWidth;
    final cutOutHeight =
        cutOutSize < height ? cutOutSize : height - borderWidth;

    final cutOutRect = Rect.fromLTWH(
      rect.left + (width - cutOutWidth) / 2 + borderWidth / 2,
      rect.top + (height - cutOutHeight) / 2 + borderWidth / 2,
      cutOutWidth - borderWidth,
      cutOutHeight - borderWidth,
    );

    final cutOutTLCorner = Rect.fromLTWH(
      cutOutRect.left,
      cutOutRect.top,
      borderLength,
      borderLength,
    );

    final cutOutTRCorner = Rect.fromLTWH(
      cutOutRect.right - borderLength,
      cutOutRect.top,
      borderLength,
      borderLength,
    );

    final cutOutBLCorner = Rect.fromLTWH(
      cutOutRect.left,
      cutOutRect.bottom - borderLength,
      borderLength,
      borderLength,
    );

    final cutOutBRCorner = Rect.fromLTWH(
      cutOutRect.right - borderLength,
      cutOutRect.bottom - borderLength,
      borderLength,
      borderLength,
    );

    return Path.combine(
      PathOperation.difference,
      Path()..addRect(rect),
      Path.combine(
        PathOperation.union,
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              cutOutRect, Radius.circular(borderRadius))),
        Path.combine(
          PathOperation.union,
          Path.combine(
            PathOperation.union,
            Path.combine(
              PathOperation.union,
              getLeftTopPath(cutOutTLCorner),
              getRightTopPath(cutOutTRCorner),
            ),
            getLeftBottomPath(cutOutBLCorner),
          ),
          getRightBottomPath(cutOutBRCorner),
        ),
      ),
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape(
        borderColor: borderColor,
        borderWidth: borderWidth,
        borderLength: borderLength,
        borderRadius: borderRadius,
        cutOutSize: cutOutSize,
      );
}
