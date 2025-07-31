import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:car_oil/services/vin_service.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  String _detectedVin = "";
  bool _isDetecting = false;
  bool _isInitializing = true;
  bool _hasPermission = false;
  String? _errorMessage;
  late TextRecognizer _textRecognizer;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _requestPermissionAndInitialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _requestPermissionAndInitialize() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();

      if (status == PermissionStatus.granted) {
        setState(() => _hasPermission = true);
        await _initializeCamera();
      } else {
        setState(() {
          _hasPermission = false;
          _isInitializing = false;
          _errorMessage = 'Camera permission is required to scan VIN numbers';
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Error requesting permission: $e';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

      // Use back camera if available, otherwise use first camera
      final camera = _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // Better for Android OCR
      );

      await _controller!.initialize();

      if (mounted) {
        setState(() => _isInitializing = false);
        _startImageStream();
      }
    } catch (e) {
      print('Camera initialization error: $e');
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  void _startImageStream() {
    if (_controller?.value.isInitialized == true) {
      _controller!.startImageStream((CameraImage image) {
        if (!_isDetecting && mounted) {
          _isDetecting = true;
          _processImage(image).then((_) {
            if (mounted) {
              _isDetecting = false;
            }
          });
        }
      });
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        final recognizedText = await _textRecognizer.processImage(inputImage);

        String? foundVin;
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            for (TextElement element in line.elements) {
              final cleanText = VinService.cleanVin(element.text);
              if (cleanText.length == 17 && VinService.isValidVin(cleanText)) {
                foundVin = cleanText;
                break;
              }
            }
            if (foundVin != null) break;
          }
          if (foundVin != null) break;
        }

        if (foundVin != null && foundVin != _detectedVin && mounted) {
          HapticFeedback.lightImpact(); // Provide haptic feedback
          setState(() {
            _detectedVin = foundVin!;
          });
        }
      }
    } catch (e) {
      print('Text recognition error: $e');
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    try {
      final bytes = _concatenatePlanes(image.planes);

      // Determine rotation based on device orientation
      final rotation = _getImageRotation();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );
      return inputImage;
    } catch (e) {
      print('Input image creation error: $e');
      return null;
    }
  }

  InputImageRotation _getImageRotation() {
    // Simple rotation logic - can be enhanced based on device orientation
    if (_controller?.description.lensDirection == CameraLensDirection.front) {
      return InputImageRotation.rotation270deg;
    } else {
      return InputImageRotation.rotation90deg;
    }
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('مسح رقم الشاصي'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasPermission) {
      return _buildPermissionError();
    }

    if (_isInitializing) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_controller!),
        ),

        // Overlay for VIN detection area
        Positioned.fill(
          child: CustomPaint(
            painter: VinOverlayPainter(),
          ),
        ),

        // Bottom panel
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: _buildBottomPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 64, color: Colors.white70),
            SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'We need camera access to scan VIN numbers from your vehicle.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'جاري تحضير الكاميرا...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Camera Error',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_detectedVin.isNotEmpty) ...[
          Text(
            'رقم الشاصي المكتشف:',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Text(
              _detectedVin,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _detectedVin.isNotEmpty
                    ? () => _useDetectedVin()
                    : null,
                icon: Icon(Icons.check),
                label: Text('استخدم هذا الرقم'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(Icons.close),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),

        SizedBox(height: 8),
        Text(
          'وجه الكاميرا نحو رقم الشاصي',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _useDetectedVin() {
    if (_detectedVin.isNotEmpty) {
      Navigator.pop(context, _detectedVin);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller?.value.isInitialized == true) {
      try {
        await _controller!.setFlashMode(
          _controller!.value.flashMode == FlashMode.off
              ? FlashMode.torch
              : FlashMode.off,
        );
      } catch (e) {
        print('Flash toggle error: $e');
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream();
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }
}

class VinOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw scanning rectangle
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: 60,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(8)),
      paint,
    );

    // Draw corner brackets
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );

    // Draw instruction text
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ضع رقم الشاصي هنا',
        style: TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 4,
              color: Colors.black54,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.rtl,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        rect.top - 40,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}