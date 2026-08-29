import 'package:salah/Database/app_database.dart';
import 'package:salah/models/salah.dart';

class TimetableEntry {
  final int? id;
  final String? mosqueName, month, date;

  final Map<Salah, String> times;

  TimetableEntry({
    this.id,
    this.mosqueName,
    this.date,
    this.month,
    required this.times,
  });

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    return TimetableEntry(
      id: json['id'],
      mosqueName: json['mosque_name'],
      month: json['month'],
      date: json['date'],
      times: {
        Salah.fajr: json['fajr'] ?? '',
        Salah.dhuhr: json['zuhr'] ?? '',
        Salah.asr: json['asr'] ?? '',
        Salah.maghrib: json['maghrib'] ?? '',
        Salah.isha: json['isha'] ?? '',
      },
    );
  }

  factory TimetableEntry.fromDb(List<SalahTimeTable> rows) {
    final Map<Salah, String> times = {};
    for (var row in rows) {
      final enumValue = Salah.values.firstWhere(
        (e) => e.name.toLowerCase() == row.salahName.toLowerCase(),
        orElse: () => Salah.fajr,
      );
      times[enumValue] = row.timeString;
    }
    final firstRow = rows.first;

    return TimetableEntry(
      id: firstRow.id,
      date: firstRow.date.toString(),
      times: times,
    );
  }

  String getTime(Salah salah) => times[salah] ?? '';
}
