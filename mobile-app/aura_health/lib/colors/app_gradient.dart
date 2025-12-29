import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  // 🌌 Main App Background
  // "from-slate-900 via-blue-900 to-purple-900"
  static const LinearGradient mainBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.bgSlate900,
      AppColors.bgBlue900,
      AppColors.bgPurple900,
    ],
  );

  // 📱 Status Bar / Header
  // "from-blue-600 via-purple-600 to-pink-600"
  static const LinearGradient header = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.primaryBlue,
      AppColors.primaryPurple,
      AppColors.primaryPink,
    ],
  );

  // 🛡️ Premium Safety Dashboard Card
  // "from-emerald-500 via-green-500 to-teal-600"
  static const LinearGradient safetyCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.safeEmerald500,
      AppColors.safeGreen500,
      Color(0xFF0D9488), // teal-600
    ],
  );

  // 🔄 Floating Scan Button / Scan Inner Button
  // "from-blue-500 via-purple-500 to-pink-500"
  static const LinearGradient scanButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // blue-500
      Color(0xFFA855F7), // purple-500
      Color(0xFFEC4899), // pink-500
    ],
  );

  // ⚠️ Warning Card
  // "from-amber-500 via-orange-500 to-red-500"
  static const LinearGradient warningCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.warnAmber500,
      AppColors.warnOrange500,
      AppColors.dangerRed500,
    ],
  );

  // 🩺 Medication Cards
  // "from-blue-50 to-purple-50"
  static const LinearGradient medicationCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.bgBlue50,
      AppColors.bgPurple50,
    ],
  );
}