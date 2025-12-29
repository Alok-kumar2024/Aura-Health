import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/legacy.dart';

final capturedImageProvider = StateProvider<File?>((ref) => null);

final isFlashOn = StateProvider<FlashMode>((_ref) => FlashMode.off);
final isUploadingProvider = StateProvider<bool>((ref) => false);