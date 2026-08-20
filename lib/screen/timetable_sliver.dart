import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:salah/Database/app_database.dart';

class TimetableSliverView extends StatefulWidget {
  final AppDatabase db;

  const TimetableSliverView({super.key, required this.db});

  @override
  State<TimetableSliverView> createState() => _TimetableSliverViewState();
}

class _TimetableSliverViewState extends State<TimetableSliverView> {
  late Future<Map<DateTime, Map<String, String>>> _groupedTimetableFuture;

  @override
  void initState() {
    super.initState();
    _groupedTimetableFuture = _fetchAndGroupTimetable();
  }

  /// Fetches all rows and groups 5 prayers under their respective DateTime key
  Future<Map<DateTime, Map<String, String>>> _fetchAndGroupTimetable() async {
    final allRows =
        await (widget.db.select(widget.db.salahTimeTables)..orderBy([
              (t) => OrderingTerm(expression: t.date, mode: OrderingMode.asc),
            ]))
            .get();

    final Map<DateTime, Map<String, String>> grouped = {};

    for (var row in allRows) {
      // Normalize date to remove time components
      final dayKey = DateTime(row.date.year, row.date.month, row.date.day);

      grouped.putIfAbsent(dayKey, () => {});
      grouped[dayKey]![row.salahName] = row.timeString;
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: FutureBuilder<Map<DateTime, Map<String, String>>>(
        future: _groupedTimetableFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final groupedData = snapshot.data ?? {};

          if (groupedData.isEmpty) {
            return const Center(child: Text("No timetable data found."));
          }

          final dates = groupedData.keys.toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'PRAYER TIMETABLE (${dates.length} DAYS)',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final date = dates[index];
                    final prayers = groupedData[date]!;
                    final dateStr =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _prayerColumn(
                                  'Fajr',
                                  prayers['Fajr'] ?? '--:--',
                                ),
                                _prayerColumn(
                                  'Dhuhr',
                                  prayers['Dhuhr'] ?? '--:--',
                                ),
                                _prayerColumn('Asr', prayers['Asr'] ?? '--:--'),
                                _prayerColumn(
                                  'Maghrib',
                                  prayers['Maghrib'] ?? '--:--',
                                ),
                                _prayerColumn(
                                  'Isha',
                                  prayers['Isha'] ?? '--:--',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: dates.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _prayerColumn(String title, String time) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
