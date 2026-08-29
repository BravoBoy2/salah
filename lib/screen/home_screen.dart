import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah/models/salah.dart';
import 'package:salah/models/timetable_entry.dart';

import '../Database/app_database.dart';
import '../Services/salah_api_service.dart';
import '../models/time_format_mode.dart';

class HomeScreen extends StatefulWidget {
  final TimeFormatMode currentMode;


  const HomeScreen({
    super.key,
    required this.currentMode,

  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String appTitle = "Salah App";
  final AppDatabase _db = AppDatabase();

  TimetableEntry? _todayEntry;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTodayTimetable();
  }

  static bool resolve24HourFormat(BuildContext context, TimeFormatMode mode) {
    switch (mode) {
      case TimeFormatMode.twelveHour:
        return false;
      case TimeFormatMode.twentyFourHour:
        return true;
      case TimeFormatMode.system:
      default:
        return MediaQuery.alwaysUse24HourFormatOf(context);
    }
  }

  static String formatSalahTime(String time, Salah salah,
      {required bool use24HourFormat, required bool use24Hour}) {
    if (time.isEmpty || time == '--:--') return time;

    final cleanTime = time.trim().replaceAll(RegExp(r'[0-9:]'), '');
    final timeParts = cleanTime.split(':');
    if (timeParts.length < 2) return time;

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final minuteStr = minute.toString().padLeft(2, '0');


    if (salah == Salah.fajr) {
      if (hour == 12) hour = 0;
    } else {
      if (hour < 12) hour += 12;
    }
    if (use24HourFormat) {
      return "${hour.toString().padLeft(2, '0')}:$minuteStr";
    } else {
      int displayHour = hour % 12;
      if (displayHour == 0) displayHour = 12;
      return "$displayHour:$minuteStr";
    }
  }
  
  Future<void> _fetchTodayTimetable() async {
    final now = DateTime.now();

    try {
      final localEntries = await _db
          .watchTodayPrayers(now)
          .first;
      if (localEntries.isNotEmpty) {
        if (mounted) {
          setState(() {
            _todayEntry = TimetableEntry.fromDb(localEntries);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (dbError) {
      debugPrint("Local Database Error: $dbError");
    }

    try {
      final apiEntries = await SalahApiService.fetchTimetable();
      if (apiEntries.isNotEmpty) {
        await _db.saveTimetableEntries(apiEntries);
        final updatedEntries = await _db
            .watchTodayPrayers(now)
            .first;
        if (mounted) {
          setState(() {
            _todayEntry = updatedEntries.isNotEmpty
                ? TimetableEntry.fromDb(updatedEntries)
                : null;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "No timetable entries found.";
            _isLoading = false;
          });
        }
      }
    } catch (apiError) {
      debugPrint("API Fail-safe error: $apiError");
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load prayer times.";
          _isLoading = false;
        });
      }
    }
  }

  /// Calculates the current active Salah based on standard 24-hour time comparison
  Salah _getCurrentSalah() {
    if (_todayEntry == null) return Salah.isha;

    final now = DateTime.now();

    DateTime? parseTo24Hour(Salah salah) {
      final rawTime = _todayEntry!.getTime(salah);
      if (rawTime.isEmpty) return null;

      final clean = rawTime.trim().replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = clean.split(':');
      if (parts.length < 2) return null;

      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (salah == Salah.fajr) {
        if (hour == 12) hour = 0;
      } else {
        if (hour < 12) hour += 12;
      }

      return DateTime(now.year, now.month, now.day, hour, minute);
    }

    final fajr = parseTo24Hour(Salah.fajr);
    final dhuhr = parseTo24Hour(Salah.dhuhr);
    final asr = parseTo24Hour(Salah.asr);
    final maghrib = parseTo24Hour(Salah.maghrib);
    final isha = parseTo24Hour(Salah.isha);

    if (isha != null && now.isAfter(isha)) return Salah.isha;
    if (maghrib != null && now.isAfter(maghrib)) return Salah.maghrib;
    if (asr != null && now.isAfter(asr)) return Salah.asr;
    if (dhuhr != null && now.isAfter(dhuhr)) return Salah.dhuhr;
    if (fajr != null && now.isAfter(fajr)) return Salah.fajr;

    return Salah.isha;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // Resolve format setting for the build context
    final use24Hour = resolve24HourFormat(context, widget.currentMode);

    return StreamBuilder<List<SalahTimeTable>>(
      stream: AppDatabase().watchTodayPrayers(now),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && _isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final dbRows = snapshot.data ?? [];
        if (dbRows.isNotEmpty) {
          _todayEntry = TimetableEntry.fromDb(dbRows);
          _errorMessage = null;
        }

        if (_errorMessage != null || _todayEntry == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _errorMessage ??
                        "No timetable available. Please import a file.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchTodayTimetable,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        final currentSalah = _getCurrentSalah();
        final rawSalahTime = _todayEntry?.getTime(currentSalah) ?? '--:--';

        // Format current start time for display
        final formattedCurrentSalahTime = formatSalahTime(
          rawSalahTime,
          currentSalah,
          use24HourFormat: use24Hour, use24Hour: true,
        );

        return Focus(
          autofocus: true,
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "Current \n ${currentSalah.displaySalahName}",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.juliusSansOne(fontSize: 22),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _salahTime(context, formattedCurrentSalahTime),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _upcomingSalah(context, use24Hour),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _salahTime(BuildContext context, String startTime) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                await AppDatabase().clearAllData();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Database reset successfully!')),
                  );
                }
              },
              child: const Text('Clear Database'),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeCard(context, startTime),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Time Left',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTimeCard(context, '--:--:--'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(BuildContext context, String time) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSecondary,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Center(
        child: Text(
          time,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            textStyle: Theme.of(context).textTheme.bodyMedium,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _upcomingSalah(BuildContext context, bool use24Hour) {
    final theme = Theme.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainer,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final salah in Salah.values) ...[
                _buildSalahRow(
                  context,
                  salah,
                  formatSalahTime(
                    _todayEntry?.getTime(salah) ?? '--:--',
                    salah,
                    use24HourFormat: use24Hour, use24Hour: use24Hour,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalahRow(BuildContext context, Salah salah,
      String formattedTime) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            salah.displaySalahName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}


