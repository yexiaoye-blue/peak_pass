import 'package:flutter/material.dart';

ThemeData createLightTheme(BuildContext context) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: colorScheme.brightness,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansSC'],
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Roboto'),
      displayMedium: TextStyle(fontFamily: 'Roboto'),
      bodyLarge: TextStyle(fontFamily: 'Roboto'),
    ).apply(fontFamily: 'Roboto'),
    sliderTheme: SliderThemeData(showValueIndicator: ShowValueIndicator.always),
    appBarTheme: AppBarTheme(
      titleTextStyle: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),
    ),
  );
}

ThemeData createDarkTheme(BuildContext context) {
  final colorScheme = ColorScheme.dark(
    primary: Color(0xffbb86fc),
    onPrimary: Colors.white,
    surfaceContainer: Color(0xFF242426),
    onSurface: Colors.white,
    secondaryContainer: Color(0xFF2f2f2f),
    onSecondary: Colors.white,
    outlineVariant: Color.fromARGB(255, 61, 61, 61),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: colorScheme.brightness,
    fontFamily: 'Roboto',
    fontFamilyFallback: ['NotoSansSC'],
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Roboto'),
      displayMedium: TextStyle(fontFamily: 'Roboto'),
      bodyLarge: TextStyle(fontFamily: 'Roboto'),
    ).apply(fontFamily: 'Roboto'),
    scaffoldBackgroundColor: Color(0xFF1a1a1a),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1a1a1a),
      foregroundColor: Colors.white,
      titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    sliderTheme: SliderThemeData(
      showValueIndicator: ShowValueIndicator.always,
      inactiveTrackColor: Theme.of(context).colorScheme.secondaryContainer,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),
    ),
  );
}
