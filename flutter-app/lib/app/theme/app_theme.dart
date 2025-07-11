import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme/theme_manager.dart';

class AppTheme {
  // 전북 특색을 담은 현대적 색상 팔레트
  static const Color _primaryGreen = Color(0xFF4CAF50); // 더 밝고 현대적인 녹색
  static const Color _secondaryGreen = Color(0xFF81C784); // 보조 녹색
  static const Color _accentBlue = Color(0xFF2196F3); // 더 선명한 파란색
  static const Color _deepBlue = Color(0xFF1565C0); // 진한 파란색
  static const Color _warningOrange = Color(0xFFFF9800); // 경고/알림용
  static const Color _errorRed = Color(0xFFF44336); // 오류/위험용
  static const Color _successGreen = Color(0xFF4CAF50); // 성공용
  static const Color _surfaceLight = Color(0xFFFAFAFA); // 밝은 표면색
  static const Color _surfaceDark = Color(0xFF121212); // 어두운 표면색

  static ColorScheme get _lightColorScheme => ColorScheme.fromSeed(
    seedColor: _primaryGreen,
    brightness: Brightness.light,
    primary: _primaryGreen,
    secondary: _secondaryGreen,
    tertiary: _accentBlue,
    error: _errorRed,
    surface: _surfaceLight,
    onSurface: const Color(0xFF1A1A1A),
    surfaceContainerHighest: const Color(0xFFF5F5F5),
  );

  static ColorScheme get _darkColorScheme => ColorScheme.fromSeed(
    seedColor: _primaryGreen,
    brightness: Brightness.dark,
    primary: _primaryGreen,
    secondary: _secondaryGreen,
    tertiary: _accentBlue,
    error: _errorRed,
    surface: _surfaceDark,
    onSurface: const Color(0xFFE0E0E0),
    surfaceContainerHighest: const Color(0xFF2A2A2A),
  );

  static ThemeData get lightTheme {
    final colorScheme = _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // 기본 텍스트 테마 (웹 호환성)
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
        fontFamily: kIsWeb ? 'Roboto' : null, // 웹에서는 Roboto 사용
      ),

      // AppBar 테마
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card 테마
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      // Input 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      // Dialog 테마
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),

      // FAB 테마
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        elevation: 6,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = _darkColorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // 기본 텍스트 테마 (웹 호환성)
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
        fontFamily: kIsWeb ? 'Roboto' : null, // 웹에서는 Roboto 사용
      ),

      // AppBar 테마
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),

      // 버튼 테마
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card 테마
      cardTheme: const CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),

      // Input 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),

      // Dialog 테마
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        contentTextStyle: TextStyle(fontSize: 16, color: colorScheme.onSurface),
      ),

      // FAB 테마
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        elevation: 6,
      ),
    );
  }

  /// 동적 폰트 크기를 적용한 라이트 테마
  static ThemeData getLightTheme({double? fontSize}) {
    final colorScheme = _lightColorScheme;
    final baseFontSize = fontSize ?? 16.0;
    final textTheme = _buildTextTheme(baseFontSize, colorScheme.onSurface);

    return lightTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: lightTheme.appBarTheme?.copyWith(
        titleTextStyle: TextStyle(
          fontSize: baseFontSize + 2,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: lightTheme.elevatedButtonTheme?.style?.copyWith(
          textStyle: WidgetStateProperty.all(
            TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// 동적 폰트 크기를 적용한 다크 테마
  static ThemeData getDarkTheme({double? fontSize}) {
    final colorScheme = _darkColorScheme;
    final baseFontSize = fontSize ?? 16.0;
    final textTheme = _buildTextTheme(baseFontSize, colorScheme.onSurface);

    return darkTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: darkTheme.appBarTheme?.copyWith(
        titleTextStyle: TextStyle(
          fontSize: baseFontSize + 2,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: darkTheme.elevatedButtonTheme?.style?.copyWith(
          textStyle: WidgetStateProperty.all(
            TextStyle(fontSize: baseFontSize, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  /// 폰트 크기에 맞는 텍스트 테마 생성
  static TextTheme _buildTextTheme(double baseFontSize, Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: baseFontSize + 16,
        fontWeight: FontWeight.w300,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontSize: baseFontSize + 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontSize: baseFontSize + 8,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineLarge: TextStyle(
        fontSize: baseFontSize + 6,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineSmall: TextStyle(
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      titleSmall: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontSize: baseFontSize,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontSize: baseFontSize - 4,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontSize: baseFontSize - 4,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontSize: baseFontSize - 6,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
    );
  }
}
