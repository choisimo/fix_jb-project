import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme/theme_manager.dart';

class AppTheme {
  // 전북 특색을 담은 색상 팔레트
  static const Color _primaryGreen = Color(0xFF2E7D32); // 전북의 자연을 상징하는 녹색
  static const Color _accentBlue = Color(0xFF1976D2); // 전북의 하늘을 상징하는 파란색
  static const Color _warningOrange = Color(0xFFFF9800); // 경고/알림용
  static const Color _errorRed = Color(0xFFD32F2F); // 오류/위험용

  static ColorScheme get _lightColorScheme => ColorScheme.fromSeed(
    seedColor: _primaryGreen,
    brightness: Brightness.light,
    primary: _primaryGreen,
    secondary: _accentBlue,
    tertiary: _warningOrange,
    error: _errorRed,
  );

  static ColorScheme get _darkColorScheme => ColorScheme.fromSeed(
    seedColor: _primaryGreen,
    brightness: Brightness.dark,
    primary: _primaryGreen,
    secondary: _accentBlue,
    tertiary: _warningOrange,
    error: _errorRed,
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
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card 테마
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Input 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card 테마
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Input 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
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
