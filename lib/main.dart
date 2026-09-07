import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:salah/screen/adaptive_screens.dart';

void main() {
  runApp(const SalahApp());
}

class SalahApp extends StatelessWidget {
  const SalahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Salah',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,

          ),

          darkTheme: ThemeData(
            useMaterial3: true,
          ),

          home: AdaptiveScreens(),
        );
      },
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
