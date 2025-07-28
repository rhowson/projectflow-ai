import 'package:flutter/material.dart';

class AppColors {
  // Modern UI Kit inspired primary colors - Beautiful teal/mint green
  static const Color primary = Color.fromRGBO(86, 215, 188, 1); // #56D7BC
  static const Color primaryLight = Color.fromRGBO(108, 228, 205, 1);
  static const Color primaryDark = Color.fromRGBO(64, 180, 155, 1);
  static const Color primaryAccent = Color.fromRGBO(86, 215, 188, 0.8);
  
  // AI Chat colors
  static const Color chatBubbleUser = Color(0xFF6366F1);
  static const Color chatBubbleAI = Color(0xFFF3F4F6);
  static const Color chatBubbleAIDark = Color(0xFF374151);
  
  // Modern secondary colors
  static const Color secondary = Color(0xFF06B6D4);
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color accent = Color(0xFFEC4899);
  static const Color accentLight = Color(0xFFF472B6);
  
  // Modern background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F7);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  // Modern dark theme colors
  static const Color backgroundDark = Color(0xFF0A0A0B);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2E);
  static const Color surfaceElevatedDark = Color(0xFF1C1C1E);
  static const Color cardBackgroundDark = Color(0xFF1C1C1E);
  
  // Modern text colors
  static const Color textPrimary = Color(0xFF1D1D1F);
  static const Color textSecondary = Color(0xFF86868B);
  static const Color textTertiary = Color(0xFFB0B0B5);
  static const Color textDisabled = Color(0xFFD1D1D6);
  
  // Modern dark theme text colors
  static const Color textPrimaryDark = Color(0xFFF2F2F7);
  static const Color textSecondaryDark = Color(0xFF98989D);
  static const Color textTertiaryDark = Color(0xFF636366);
  static const Color textDisabledDark = Color(0xFF48484A);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Task priority colors
  static const Color priorityLow = Color(0xFF6B7280);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityUrgent = Color(0xFF991B1B);
  
  // Task status colors
  static const Color statusTodo = Color(0xFF6B7280);
  static const Color statusInProgress = Color(0xFF3B82F6);
  static const Color statusReview = Color(0xFFF59E0B);
  static const Color statusCompleted = Color(0xFF10B981);
  static const Color statusBlocked = Color(0xFFEF4444);
  
  // Project status colors
  static const Color projectPlanning = Color(0xFF8B5CF6);
  static const Color projectInProgress = Color(0xFF3B82F6);
  static const Color projectCompleted = Color(0xFF10B981);
  static const Color projectOnHold = Color(0xFFF59E0B);
  static const Color projectCancelled = Color(0xFFEF4444);
  
  // Modern gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFEC4899),
    Color(0xFFF59E0B),
  ];
  
  static const List<Color> aiGradient = [
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
  ];
  
  // Modern border colors
  static const Color border = Color(0xFFE5E5E7);
  static const Color borderLight = Color(0xFFF2F2F7);
  static const Color borderDark = Color(0xFF38383A);
  
  // Modern shadow colors
  static const Color shadow = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x29000000);
  
  // Glass morphism effects
  static const Color glassMorphism = Color(0x1AFFFFFF);
  static const Color glassMorphismDark = Color(0x1A000000);
}