import 'package:flutter/material.dart';

import '../../models/time_format_mode.dart';

class SettingsPage extends StatefulWidget {

  final TimeFormatMode currentMode;
  final ValueChanged<TimeFormatMode> onTimeFormatChanged;

  const SettingsPage({super.key
    , required this.currentMode,
    required this.onTimeFormatChanged});


  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late TimeFormatMode _timeFormatMode;

  @override
  void initState() {
    super.initState();
    _timeFormatMode = widget.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text("Time Format", style: TextStyle(fontSize: 14),
            ),
          ),
          ListTile(
            leading: Checkbox(
              value: _timeFormatMode == TimeFormatMode.system,
              onChanged: (_) => _updateMode(TimeFormatMode.system),
            ),
            title: const Text('System Default'),
            subtitle: const Text('Adopt native device time settings'),
            onTap: () => _updateMode(TimeFormatMode.system),
          ),
          // 2. 12-Hour Clock Tile
          ListTile(
            leading: Checkbox(
              value: _timeFormatMode == TimeFormatMode.twelveHour,
              onChanged: (_) => _updateMode(TimeFormatMode.twelveHour),
            ),
            title: const Text('12-Hour Clock'),
            subtitle: const Text('e.g., 8:14 PM'),
            onTap: () => _updateMode(TimeFormatMode.twelveHour),
          ),

// 3. 24-Hour Clock Tile
          ListTile(
            leading: Checkbox(
              value: _timeFormatMode == TimeFormatMode.twentyFourHour,
              onChanged: (_) => _updateMode(TimeFormatMode.twentyFourHour),
            ),
            title: const Text('24-Hour Clock'),
            subtitle: const Text('e.g., 20:14'),
            onTap: () => _updateMode(TimeFormatMode.twentyFourHour),
          ),
        ],
      ),
    );
  }


  void _updateMode(TimeFormatMode mode) {
    setState(() {
      _timeFormatMode = mode;
    });
  }
}
