import 'package:flutter/material.dart';
import 'package:salah/screen/settings/settings_page.dart';

import 'home_screen.dart';
import 'import_timetable.dart';

class NavigationLayout extends StatefulWidget {
  const NavigationLayout({super.key});

  @override
  State<NavigationLayout> createState() => _NavigationLayoutState();
}

class _NavigationLayoutState extends State<NavigationLayout> {
  int _currentIndex = 0;

  // TODO: implement rest of the Navigation system

  @override
  Widget build(BuildContext context) {
    // Define pages inside build so they can adapt to the system settings cleanly
    final List<Widget> pages = [
      const HomeScreen(key: ValueKey('home_page')),
      const SettingsPage(key: ValueKey('settings')),
      const Scaffold(
        key: ValueKey('placement_page'),
        body: Center(child: Text('Placement')),
      ),
      ImportTimeTable(key: ValueKey('Import Timetable')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salah App',
          style: TextStyle(
            fontSize: 32,
            letterSpacing: 32 * 0.17,
            color: Color(0xFF32BB56) // Your signature brand green color
          ),
        ),
        centerTitle: true,
      ),

      // Fully native-driven NavigationDrawer
      drawer: _navDrawer(),

      // IndexedStack fixes focus exceptions and keeps screen memory intact
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: pages),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.watch_later_outlined),
            label: 'Salah Time',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
          NavigationDestination(icon: Icon(Icons.place), label: 'Placement'),
          NavigationDestination(icon: Icon(Icons.import_export), label: 'Import Timetable')
        ],
      ),
    );
  }

  // Inside your _NavigationLayoutState class:

  Widget _navDrawer() {
    return NavigationDrawer(
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _currentIndex = index;
        });
        Navigator.pop(context); // Automatically closes drawer on tap
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 16, 10),
          child: Text(
            'Menu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ), // Adapts to light/dark natively
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Divider(),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.watch_later_outlined),
          selectedIcon: Icon(Icons.watch_later),
          label: Text('Salah Time'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.place),
          selectedIcon: Icon(Icons.place_rounded),
          label: Text('Placement'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.import_export),
          selectedIcon: Icon(Icons.import_export_rounded),
          label: Text('Import Timetable'),
        ),
      ],
    );
  }
}
