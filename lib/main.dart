import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah/screen/adaptive-screens.dart';


void main() {
  runApp(const SalahApp());
}

class SalahApp extends StatelessWidget {

  const SalahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fallbackColorScheme = ColorScheme.fromSeed(
        seedColor: const Color(0xFF32BB56));

    return DynamicColorBuilder(

        builder: (ColorScheme? lighDynamic, ColorScheme? darkDynamic) {
          return MaterialApp(
            title: 'Salah App',
            themeMode: ThemeMode.system,

            theme: ThemeData(
              useMaterial3: true,
              colorScheme: lighDynamic ?? fallbackColorScheme,
              textTheme: GoogleFonts.juliusSansOneTextTheme(),
            ),


            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic ?? ColorScheme.fromSeed(
                  seedColor: const Color(0xFF32BB56),
                  brightness: Brightness.dark),
              textTheme: GoogleFonts.juliusSansOneTextTheme(),
            ),
            home: const AdaptiveScreens(),
          );
  }
    );
}


}

// Returns Salah names with names and etc...

class SalahInfo extends StatelessWidget {
  const SalahInfo({super.key});


  @override
  Widget build(BuildContext context) {
// TODO: implement build
    throw UnimplementedError();
  }
}