import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ThemeType {
  lightMode,
  darkMode,
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
  static ThemeType defaultTheme = ThemeType.lightMode;

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
  Color errorTxt;

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
    required this.errorTxt,
  });

  /// fromType factory constructor
  factory AppTheme.fromType(ThemeType t) {
    switch (t) {
      case ThemeType.lightMode:
        return AppTheme(
          isDark: false,
          txt: Colors.black,
          accentTxt: Colors.black,
          errorTxt: Colors.white,
          bg1: Colors.white,
          bg2: const Color(0xfffbfbfb),
          surface: Colors.white,
          accent1: const Color(0xff888888),
          accent1Dark: const Color(0xff9e9e9e),
          accent1Darker: const Color(0xff888888),
          accent2: Colors.black,
          accent3: Colors.blueGrey,
          greyWeak: const Color(0xff777777),
          grey: const Color(0xff333333),
          greyStrong: const Color(0xff252525),
          error: const Color(0xffE57777),
          focus: Colors.blueGrey,
        );

      case ThemeType.darkMode:
        return AppTheme(
          isDark: true,
          txt: Colors.white,
          accentTxt: const Color(0xffffffff),
          errorTxt: Colors.white,
          bg1: const Color(0xff222222),
          bg2: const Color(0xff353535),
          surface: const Color(0xff222222),
          accent1: const Color(0xff8a8a8a),
          accent1Dark: const Color(0xffababab),
          accent1Darker: const Color(0xfffbfbfb),
          accent2: Colors.white,
          accent3: Colors.grey,
          greyWeak: const Color(0xff777777),
          grey: const Color(0xffaaaaaa),
          greyStrong: const Color(0xffcccccc),
          error: const Color(0xffE57777),
          focus: Colors.blueGrey,
        );
    }
  }

  TextTheme _customTextTheme(TextTheme base) {
    return base
        .copyWith(
          headline1: base.headline5!.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 28.0,
          ),
          headline2: base.headline5!.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 28.0,
          ),
          headline3: base.headline5!.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 24.0,
          ),
          headline4: base.headline5!.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 22.0,
          ),
          headline5: base.headline5!.copyWith(
            letterSpacing: 2.5,
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
          headline6: base.headline6!.copyWith(
            fontSize: 20.0,
            fontWeight: FontWeight.normal,
          ),
          caption: base.caption!.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 20.0,
          ),
          bodyText1: base.bodyText1!.copyWith(
            fontWeight: FontWeight.normal,
            fontSize: 16.0,
          ),
        )
        .apply(fontFamily: GoogleFonts.poppins().fontFamily);
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
          onError: errorTxt,
          onPrimary: accentTxt,
          onSecondary: accentTxt,
          error: error),
    );
    return t.copyWith(
        textTheme: _customTextTheme(
            (isDark ? ThemeData.dark() : ThemeData.light()).textTheme));
  }

  Color shift(Color c, double d) =>
      ColorUtils.shiftHsl(c, d * (isDark ? -1 : 1));
}
