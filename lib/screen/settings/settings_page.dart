import 'package:flutter/material.dart';
import 'package:salah/screen/settings/user_location.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: UserLocation());
  }
}
