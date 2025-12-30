import 'dart:io';

import 'package:aura_heallth/presentation/screens/home_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../state/camera_provider.dart';
import 'image_preview_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreen();
}

class _CameraScreen extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {

  // Camera State
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  double _currentZoom = 1.0;
  double _maxZoom = 1.0;
  Offset? _focusPoint;

  // Animation State
  // late AnimationController _scanAnimationController;
  // late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setUpCameraController();

    // Scanning Line Animation
    // _scanAnimationController = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 2),
    // )..repeat(reverse: true);

    // _scanAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
    //   CurvedAnimation(parent: _scanAnimationController, curve: Curves.easeInOut),
    // );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    // _scanAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _setUpCameraController();
    }
  }

  Future<void> _setUpCameraController() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      // Select the first rear camera
      final rearCamera = cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first
      );

      cameraController = CameraController(
        rearCamera,
        ResolutionPreset.max, // Highest quality for food analysis
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      try {
        await cameraController!.initialize();
        _maxZoom = await cameraController!.getMaxZoomLevel();
        if (mounted) setState(() {});
      } catch (e) {
        debugPrint("Camera Error: $e");
      }
    }
  }

  // --- ACTIONS ---

  Future<void> _onTapFocus(TapDownDetails details, BoxConstraints constraints) async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    final offset = details.localPosition;
    final point = Offset(
      offset.dx / constraints.maxWidth,
      offset.dy / constraints.maxHeight,
    );

    // Show visual indicator
    setState(() {
      _focusPoint = offset;
    });

    // Reset visual indicator after 1 second
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _focusPoint = null);
    });

    try {
      await cameraController!.setFocusPoint(point);
      await cameraController!.setExposurePoint(point);
    } catch (e) {
      debugPrint("Focus Error: $e");
    }
  }

  Future<void> _setZoom(double zoom) async {
    if (cameraController == null) return;
    final z = zoom.clamp(1.0, _maxZoom); // Ensure within bounds
    await cameraController!.setZoomLevel(z);
    setState(() => _currentZoom = z);
  }

  Future<void> _toggleFlash() async {
    final flash = ref.read(isFlashOn);
    if (cameraController == null) return;

    FlashMode newMode = (flash == FlashMode.off) ? FlashMode.torch : FlashMode.off;
    await cameraController!.setFlashMode(newMode);
    ref.read(isFlashOn.notifier).state = newMode;
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      ref.read(capturedImageProvider.notifier).state = File(image.path);


      debugPrint("Gallery Image Selected: ${image.path}");
      Navigator.push(context, MaterialPageRoute(builder: (_) => ImagePreviewScreen()));
    }
  }

  Future<void> _captureImage() async {
    if (cameraController == null || !cameraController!.value.isInitialized) return;
    try {
      final XFile image = await cameraController!.takePicture();
      ref.read(capturedImageProvider.notifier).state = File(image.path);

      debugPrint("Captured: ${image.path}");
      Navigator.push(context, MaterialPageRoute(builder: (_) => ImagePreviewScreen()));
    } catch (e) {
      debugPrint("Capture Error: $e");
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Camera Preview
              GestureDetector(
                onTapDown: (details) => _onTapFocus(details, constraints),
                onScaleUpdate: (details) {
                  // Simple pinch to zoom logic
                  _setZoom(_currentZoom * details.scale);
                },
                child: CameraPreview(cameraController!),
              ),

              // 2. Focus Indicator (Visual only)
              if (_focusPoint != null)
                Positioned(
                  left: _focusPoint!.dx - 25,
                  top: _focusPoint!.dy - 25,
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 300),
                    tween: Tween<double>(begin: 40, end: 30),
                    builder: (context, double size, child) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.yellowAccent, width: 2),
                        ),
                      );
                    },
                  ),
                ),

              // 3. Scanner Overlay (Darkens edges, highlights center)
              // Positioned.fill(
              //   child: CustomPaint(
              //     painter: ScannerOverlayPainter(
              //       scanWindow: Rect.fromCenter(
              //         center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2 - 50),
              //         width: 280,
              //         height: 280,
              //       ),
              //     ),
              //   ),
              // ),

              // 4. Animated Scanning Line
              // AnimatedBuilder(
              //   animation: _scanAnimation,
              //   builder: (context, child) {
              //     return Positioned(
              //       top: (constraints.maxHeight / 2 - 190) + (280 * _scanAnimation.value),
              //       left: (constraints.maxWidth - 280) / 2,
              //       child: Container(
              //         width: 280,
              //         height: 2,
              //         decoration: BoxDecoration(
              //           color: Colors.greenAccent,
              //           boxShadow: [
              //             BoxShadow(
              //               color: Colors.greenAccent.withOpacity(0.6),
              //               blurRadius: 10,
              //               spreadRadius: 2,
              //             )
              //           ],
              //         ),
              //       ),
              //     );
              //   },
              // ),

              // 5. Top Bar
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        shape: const CircleBorder(),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Snap a photo or tap the mic to log meals",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance spacing
                  ],
                ),
              ),

              // 6. Hint Text
              // Positioned(
              //   top: (constraints.maxHeight / 2) - 230,
              //   left: 0,
              //   right: 0,
              //   child: const Center(
              //     child: Text(
              //       "Align food within the frame",
              //       style: TextStyle(
              //         color: Colors.white70,
              //         fontSize: 14,
              //         fontWeight: FontWeight.w500,
              //         shadows: [Shadow(color: Colors.black, blurRadius: 4)],
              //       ),
              //     ),
              //   ),
              // ),

              // 7. Bottom Controls Area
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom Slider
                      SizedBox(
                        width: 250,
                        child: Row(
                          children: [
                            const Icon(Icons.zoom_out, color: Colors.white70, size: 20),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  trackHeight: 2,
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                ),
                                child: Slider(
                                  value: _currentZoom,
                                  min: 1.0,
                                  max: _maxZoom > 5.0 ? 5.0 : _maxZoom, // Cap zoom at 5x
                                  activeColor: Colors.white,
                                  inactiveColor: Colors.white24,
                                  onChanged: _setZoom,
                                ),
                              ),
                            ),
                            const Icon(Icons.zoom_in, color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Main Controls Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Gallery
                          _buildCircleButton(
                            icon: Icons.photo_library_outlined,
                            onTap: _pickFromGallery,
                          ),

                          // Shutter Button
                          GestureDetector(
                            onTap: _captureImage,
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                color: Colors.white24,
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),

                          // Flash
                          Consumer(
                            builder: (context, ref, child) {
                              final flashMode = ref.watch(isFlashOn);
                              return _buildCircleButton(
                                icon: flashMode == FlashMode.off
                                    ? Icons.flash_off
                                    : Icons.flash_on,
                                isActive: flashMode == FlashMode.torch,
                                onTap: _toggleFlash,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? Colors.yellowAccent.withOpacity(0.2) : Colors.black26,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? Colors.yellowAccent : Colors.white24,
          ),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.yellowAccent : Colors.white,
          size: 24,
        ),
      ),
    );
  }
}

// --- CUSTOM PAINTER FOR SCANNING FRAME ---

// class ScannerOverlayPainter extends CustomPainter {
//   final Rect scanWindow;
//
//   ScannerOverlayPainter({required this.scanWindow});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final backgroundPath = Path()
//       ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     final cutoutPath = Path()
//       ..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)));
//
//     final backgroundPaint = Paint()
//       ..color = Colors.black.withOpacity(0.5)
//       ..style = PaintingStyle.fill
//       ..blendMode = BlendMode.dstOut; // This creates the "hole" effect
//
//     // Draw the dark overlay with the cutout
//     canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
//     canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.black54);
//     canvas.drawPath(cutoutPath, Paint()..blendMode = BlendMode.clear);
//     canvas.restore();
//
//     // Draw the White Corners
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 3.0
//       ..strokeCap = StrokeCap.round;
//
//     const double cornerLength = 30.0;
//
//     // Top Left
//     canvas.drawPath(
//       Path()
//         ..moveTo(scanWindow.left, scanWindow.top + cornerLength)
//         ..lineTo(scanWindow.left, scanWindow.top)
//         ..lineTo(scanWindow.left + cornerLength, scanWindow.top),
//       borderPaint,
//     );
//
//     // Top Right
//     canvas.drawPath(
//       Path()
//         ..moveTo(scanWindow.right - cornerLength, scanWindow.top)
//         ..lineTo(scanWindow.right, scanWindow.top)
//         ..lineTo(scanWindow.right, scanWindow.top + cornerLength),
//       borderPaint,
//     );
//
//     // Bottom Left
//     canvas.drawPath(
//       Path()
//         ..moveTo(scanWindow.left, scanWindow.bottom - cornerLength)
//         ..lineTo(scanWindow.left, scanWindow.bottom)
//         ..lineTo(scanWindow.left + cornerLength, scanWindow.bottom),
//       borderPaint,
//     );
//
//     // Bottom Right
//     canvas.drawPath(
//       Path()
//         ..moveTo(scanWindow.right - cornerLength, scanWindow.bottom)
//         ..lineTo(scanWindow.right, scanWindow.bottom)
//         ..lineTo(scanWindow.right, scanWindow.bottom - cornerLength),
//       borderPaint,
//     );
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }