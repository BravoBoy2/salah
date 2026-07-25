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

  String getTime(Salah salah) => times[salah] ?? '';
}
