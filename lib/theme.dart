import 'package:flutter/material.dart';

enum ThemeType {
  LightMode,
  DarkMode,
}

class ColorUtils {
  static Color shiftHsl(Color c, [double amt = 0]) {
    var hslc = HSLColor.fromColor(c);
    return hslc.withLightness((hslc.lightness + amt).clamp(0.0, 1.0)).toColor();
  }

  static Color parseHex(String value) =>
      Color(int.parse(value.substring(1, 7), radix: 16) + 0xFF000000);

  static Color blend(Color dst, Color src, double opacity) {
    return Color.fromARGB(
      255,
      (dst.red.toDouble() * (1.0 - opacity) + src.red.toDouble() * opacity)
          .toInt(),
      (dst.green.toDouble() * (1.0 - opacity) + src.green.toDouble() * opacity)
          .toInt(),
      (dst.blue.toDouble() * (1.0 - opacity) + src.blue.toDouble() * opacity)
          .toInt(),
    );
  }
}

class AppTheme {
  static ThemeType defaultTheme = ThemeType.LightMode;

  bool isDark;
  Color bg1; //
  Color surface; //
  Color bg2;
  Color accent1;
  Color accent1Dark;
  Color accent1Darker;
  Color accent2;
  Color accent3;
  Color grey;
  Color greyStrong;
  Color greyWeak;
  Color error;
  Color focus;

  Color txt;
  Color accentTxt;

  /// Default constructor
  AppTheme({
    required this.isDark,
    required this.bg1,
    required this.surface,
    required this.bg2,
    required this.accent1,
    required this.accent1Dark,
    required this.accent1Darker,
    required this.accent2,
    required this.accent3,
    required this.grey,
    required this.greyStrong,
    required this.greyWeak,
    required this.error,
    required this.focus,
    required this.txt,
    required this.accentTxt,
  });

  /// fromType factory constructor
  factory AppTheme.fromType(ThemeType t) {
    switch (t) {
      case ThemeType.LightMode:
        return AppTheme(
          isDark: false,
          txt: Colors.black,
          accentTxt: Colors.black,
          bg1: Colors.white,
          bg2: Color(0xfffbfbfb),
          surface: Colors.white,
          accent1: Colors.blueGrey.shade400,
          accent1Dark: Colors.blueGrey,
          accent1Darker: Colors.blueGrey.shade900,
          accent2: Colors.black,
          accent3: Colors.redAccent.shade100,
          greyWeak: Colors.grey.shade300,
          grey: Colors.grey.shade500,
          greyStrong: Colors.grey.shade900,
          error: Colors.red.shade900,
          focus: Colors.blueGrey,
        );

      case ThemeType.DarkMode:
        return AppTheme(
          isDark: true,
          txt: Colors.white,
          accentTxt: Colors.blueGrey.shade100,
          bg1: Colors.black54,
          bg2: Colors.black38,
          surface: Colors.black12,
          accent1: Colors.blueGrey.shade50,
          accent1Dark: Colors.blueGrey,
          accent1Darker: Colors.blueGrey.shade900,
          accent2: Colors.black,
          accent3: Colors.redAccent.shade100,
          greyWeak: Colors.grey.shade300,
          grey: Colors.grey.shade500,
          greyStrong: Colors.grey.shade900,
          error: Colors.red.shade900,
          focus: Colors.blueGrey,
        );
    }
  }

  ThemeData get themeData {
    var t = ThemeData.from(
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme,
      colorScheme: ColorScheme(
          brightness: isDark ? Brightness.dark : Brightness.light,
          primary: accent1,
          primaryVariant: accent1Darker,
          secondary: accent2,
          secondaryVariant: ColorUtils.shiftHsl(accent2, -.2),
          background: bg1,
          surface: surface,
          onBackground: txt,
          onSurface: txt,
          onError: txt,
          onPrimary: accentTxt,
          onSecondary: accentTxt,
          error: error),
    );
    return t;
  }

  Color shift(Color c, double d) =>
      ColorUtils.shiftHsl(c, d * (isDark ? -1 : 1));
}
