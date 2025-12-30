import 'dart:io';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? imagePath;
  final String name;
  final double radius;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.imagePath,
    required this.name,
    this.radius = 40,
    this.fontSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Logic: Check if we have a valid local image file
    ImageProvider? backgroundImage;
    if (imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        backgroundImage = FileImage(file);
      }
    }

    // 2. Build the Avatar
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE3F2FD), // Light Blue background
      backgroundImage: backgroundImage,
      // If no image is loaded, show Initials (child)
      child: backgroundImage == null
          ? Text(
        _getInitials(name),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1E88E5), // Blue Text
        ),
      )
          : null,
    );
  }

  // Helper to get initials (e.g. "John Doe" -> "JD")
  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}