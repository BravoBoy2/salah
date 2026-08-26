import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salah/models/salah.dart';
import 'package:salah/models/timetable_entry.dart';

import '../Services/salah_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String appTitle = "Salah App";

  TimetableEntry? _todayEntry;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTodayTimetable();
  }

  Future<void> _fetchTodayTimetable() async {
    try {
      final entries = await SalahApiService.fetchTimetable();
      if (entries.isNotEmpty) {
        // For demonstration, grab the first entry (or match by current date)
        setState(() {
          _todayEntry = entries.first;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No timetable entries found.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to load prayer times.";
        _isLoading = false;
      });
    }
  }

  /// Helper to convert a time string like "6:46" or "14:18" into a DateTime object for today
  DateTime _parseTimeString(String? timeStr) {
    final now = DateTime.now();
    if (timeStr == null || timeStr.isEmpty) return now;

    final parts = timeStr.trim().split(':');
    if (parts.length < 2) return now;

    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;

    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Calculates the current Salah based on parsed prayer times
  Salah _getCurrentSalah() {
    if (_todayEntry == null) return Salah.fajr;

    final now = DateTime.now();
    return Salah.getCurrentSalah(
      now: now,
      fajrTime: _parseTimeString(_todayEntry!.getTime(Salah.fajr)),
      dhuhrTime: _parseTimeString(_todayEntry!.getTime(Salah.dhuhr)),
      asrTime: _parseTimeString(_todayEntry!.getTime(Salah.asr)),
      maghribTime: _parseTimeString(_todayEntry!.getTime(Salah.maghrib)),
      ishaTime: _parseTimeString(_todayEntry!.getTime(Salah.isha)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!),
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
    final currentSalahTime = _todayEntry?.getTime(currentSalah) ?? '--:--';

    return Focus(
      autofocus: true,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // Display Current Active Salah Name
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Current \n ${currentSalah.displaySalahName}",
                    style: GoogleFonts.juliusSansOne(fontSize: 28),
                  ),
                ),
              ),
            ),

            // Display Start Time & Placeholder Timer
            SliverToBoxAdapter(child: _salahTime(context, currentSalahTime)),

            // List of All Prayer Times
            SliverFillRemaining(
              hasScrollBody: false,
              child: _upcomingSalah(context),
            ),
          ],
        ),
      ),
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

  Widget _upcomingSalah(BuildContext context) {
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
                  _todayEntry?.getTime(salah) ?? '--:--',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalahRow(BuildContext context, Salah salah, String time) {
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
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
