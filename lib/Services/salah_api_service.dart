import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:salah/models/timetable_entry.dart';

class SalahApiService {
  // Base host authority for local development
  static const String _authority = '127.0.0.1:8000';

  /// Endpoint 1: Upload CSV file and save timetable entries to database
  static Future<List<TimetableEntry>> uploadCsvTimetable(File file) async {
    final uri = Uri.http(_authority, '/api/v1/parse-timetable');
    final request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => TimetableEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to upload CSV: ${response.body}');
    }
  }

  /// Endpoint 2: Fetch all saved timetable entries from SQLite database
  static Future<List<TimetableEntry>> fetchTimetable() async {
    final uri = Uri.http(_authority, '/api/v1/timetable');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => TimetableEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch timetable: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> fetchCurrentSalah() async {
    final uri = Uri.http(_authority, '/api/v1/current-salah');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch current salah: ${response.body}');
    }
  }
}
