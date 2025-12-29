import 'package:aura_heallth/state/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImagePreviewScreen extends ConsumerWidget {

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final imageFile = ref.watch(capturedImageProvider);
    final isUploading = ref.watch(isUploadingProvider);

    if (imageFile == null) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          ref.read(capturedImageProvider.notifier).state = null;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.contain),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            //Cross Button...
            Positioned(
              top: 50,
              left: 20,
              child: IconButton(
                onPressed: () {
                  ref.read(capturedImageProvider.notifier).state = null;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),

            //Upload Button....
            Positioned(
              bottom: 40,
              right: 20,
              left: 20,
              child: ElevatedButton(
                onPressed: isUploading ? null : () async {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  padding: const EdgeInsetsGeometry.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Analyze Food",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
