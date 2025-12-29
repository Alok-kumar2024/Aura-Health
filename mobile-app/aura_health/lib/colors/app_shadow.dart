import 'package:flutter/material.dart';

class AppShadows {
  // ===========================================================================
  // 🌑 STANDARD SHADOWS (Tailwind-style)
  // ===========================================================================

  // shadow-sm (Subtle)
  static final List<BoxShadow> sm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  // shadow (Default)
  static final List<BoxShadow> def = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  // shadow-md (Medium)
  static final List<BoxShadow> md = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ];

  // shadow-lg (Large - Used for "Active Medications", "Timeline")
  static final List<BoxShadow> lg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -2,
    ),
  ];

  // shadow-xl (Extra Large - Used for "Scan Meal Button", "Digital Twin")
  static final List<BoxShadow> xl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(0, 10),
      blurRadius: 10,
      spreadRadius: -5,
    ),
  ];

  // shadow-2xl (Huge - Used for Hover states or Modal/Alerts)
  static final List<BoxShadow> xxl = [
    BoxShadow(
      color: Colors.black.withOpacity(0.25),
      offset: const Offset(0, 25),
      blurRadius: 50,
      spreadRadius: -12,
    ),
  ];

  // ===========================================================================
  // 🎨 COLORED GLOWS (For your Gradient Buttons)
  // ===========================================================================

  // Blue Glow (For Primary Buttons)
  static final List<BoxShadow> blueGlow = [
    BoxShadow(
      color: Color(0xFF2563EB).withOpacity(0.5), // blue-600 with opacity
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Purple Glow (For Accent Buttons)
  static final List<BoxShadow> purpleGlow = [
    BoxShadow(
      color: Color(0xFF9333EA).withOpacity(0.5), // purple-600 with opacity
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Green Glow (For Success Badges)
  static final List<BoxShadow> greenGlow = [
    BoxShadow(
      color: Color(0xFF10B981).withOpacity(0.4),
      offset: const Offset(0, 4),
      blurRadius: 10,
    ),
  ];
}