import 'package:flutter/material.dart';

import 'screens/auth_screens.dart';
import 'theme/app_colors.dart';

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Wordle',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(primary: kGreen),
      appBarTheme: const AppBarTheme(
        backgroundColor: kBg,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    home: const SplashScreen(),
  );
}
