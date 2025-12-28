import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4A90E2); // Soft Blue
  static const Color primaryDark = Color(0xFF2E5C8A);
  static const Color primaryLight = Color(0xFF7AB8F5);

  // Accent Colors
  static const Color accent = Color(0xFFF5A623); // Warm Orange
  static const Color accentLight = Color(0xFFFFC107);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA); // Off-white
  static const Color surface = Colors.white;
  static const Color surfaceLight = Color(0xFFFAFAFA);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF1A2332); // Deep Navy
  static const Color surfaceDark = Color(0xFF2C3E50);
  static const Color surfaceDarkLight = Color(0xFF34495E);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF7F8C8D);
  static const Color textLight = Color(0xFFBDC3C7);
  static const Color textDark = Colors.white;

  // Mood Colors
  static const Color moodVeryUnhappy = Color(0xFFE74C3C); // Red
  static const Color moodUnhappy = Color(0xFFE67E22); // Orange
  static const Color moodOkay = Color(0xFFF39C12); // Yellow
  static const Color moodHappy = Color(0xFF2ECC71); // Green
  static const Color moodVeryHappy = Color(0xFF27AE60); // Dark Green

  // Status Colors
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Crisis/Emergency
  static const Color crisis = Color(0xFFFF3B30);
  static const Color crisisLight = Color(0xFFFF6B6B);

  // Chat Colors
  static const Color chatUserBubble = primary;
  static const Color chatBotBubble = Color(0xFFECF0F1);
  static const Color chatUserBubbleDark = primaryDark;
  static const Color chatBotBubbleDark = surfaceDark;

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient moodGradient = LinearGradient(
    colors: [moodVeryUnhappy, moodUnhappy, moodOkay, moodHappy, moodVeryHappy],
    stops: [0.0, 0.25, 0.5, 0.75, 1.0],
  );

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x40000000);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF455A64);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Category Colors (for meditation, community, etc.)
  static const Color categoryBreathing = Color(0xFF3498DB);
  static const Color categoryMeditation = Color(0xFF9B59B6);
  static const Color categoryYogaNidra = Color(0xFFE67E22);
  static const Color categoryMantras = Color(0xFFF39C12);
  static const Color categoryBodyScan = Color(0xFF1ABC9C);
  static const Color categoryAffirmations = Color(0xFFE91E63);

  // Community Group Colors
  static const List<Color> groupColors = [
    Color(0xFF3498DB),
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF2ECC71),
    Color(0xFFE74C3C),
    Color(0xFF1ABC9C),
    Color(0xFFF39C12),
    Color(0xFF34495E),
  ];

  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF37474F);
  static const Color shimmerHighlightDark = Color(0xFF455A64);

  // Helper Methods
  static Color getMoodColor(int moodLevel) {
    switch (moodLevel) {
      case 1:
        return moodVeryUnhappy;
      case 2:
        return moodUnhappy;
      case 3:
        return moodOkay;
      case 4:
        return moodHappy;
      case 5:
        return moodVeryHappy;
      default:
        return moodOkay;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'breathing':
        return categoryBreathing;
      case 'meditation':
        return categoryMeditation;
      case 'yoga_nidra':
        return categoryYogaNidra;
      case 'mantras':
        return categoryMantras;
      case 'body_scan':
        return categoryBodyScan;
      case 'affirmations':
        return categoryAffirmations;
      default:
        return primary;
    }
  }

  static Color getGroupColor(int index) {
    return groupColors[index % groupColors.length];
  }
}
