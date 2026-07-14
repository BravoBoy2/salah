import 'package:flutter/material.dart';
import 'package:salah/screen/navigation_layout.dart';

const largeScreenMinWidth = 600;

class AdaptiveScreens extends StatefulWidget {
  const AdaptiveScreens({super.key});

  @override
  State<AdaptiveScreens> createState() => _AdaptiveScreensState();
}

class _AdaptiveScreensState extends State<AdaptiveScreens> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > largeScreenMinWidth;
        if (isLargeScreen) {
          return NavigationLayout();
        } else {
          return NavigationLayout();
        }
      },
    );
  }
}
