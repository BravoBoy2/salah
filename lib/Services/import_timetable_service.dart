import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/time_parser.dart';

class ImportTimetableService {
  final AppDatabase db;

  ImportTimetableService(this.db);

  Future<bool> processPickedFile(PlatformFile pickedFile) async {
    final extension = pickedFile.name.contains('.')
        ? pickedFile.name.split('.').last.toLowerCase()
        : '';

    print("DEBUG: Picked file name: ${pickedFile.name}");
    print("DEBUG: File extension detected: $extension");

    final DateTime selectedDate = DateTime.now();
    List<TimetableEntry> results = [];

    if (extension == 'csv' || extension == 'txt') {
      try {
        final String content = await _readFileContentAsString(pickedFile);
        print("DEBUG: File raw content length: ${content.length} characters");

        if (extension == 'csv') {
          print("DEBUG: Sending content to UnstructuredParser.parseCSV...");
          results = await compute(
            (String data) => UnstructuredParser.parseCSV(data, selectedDate),
            content,
          );
        } else {
          results = await compute(
            (String data) =>
                UnstructuredParser.parseRawText(data, selectedDate),
            content,
          );
        }

        print("DEBUG: Parsing complete. Extracted ${results.length} entries.");
      } catch (e, stack) {
        print("DEBUG ERROR during file reading or parsing: $e");
        print("STACK TRACE: $stack");
        return false;
      }
    }

    // Save extracted results to database
    if (results.isNotEmpty) {
      print("DEBUG: Calling saveEntriesToDatabase...");
      await saveEntriesToDatabase(results);
      return true;
    } else {
      print("DEBUG: 'results' was empty. Nothing saved to database.");
    }

    return false;
  }

  /// Helper to safely extract string contents using file_picker v12 APIs
  Future<String> _readFileContentAsString(PlatformFile pickedFile) async {
    if (!kIsWeb && pickedFile.path != null) {
      return await File(pickedFile.path!).readAsString();
    }

    // v12 Async readAsBytes method replacing the old .bytes getter
    final Uint8List bytes = await pickedFile.readAsBytes();
    return utf8.decode(bytes);
  }

  /// Save extracted TimetableEntry list using the injected database instance
  Future<void> saveEntriesToDatabase(List<TimetableEntry> entries) async {
    if (entries.isEmpty) return;

    try {
      await db.saveTimetableEntries(entries);
      print(
        "Successfully saved ${entries.length} timetable entries to database.",
      );

      // --- DATABASE VERIFICATION LOGS ---
      final allEntries = await db.select(db.salahTimeTables).get();
      print("================ DATABASE VERIFICATION ================");
      print("Total records currently stored in SQLite: ${allEntries.length}");
      print("First 5 stored entries:");
      for (var entry in allEntries.take(5)) {
        print(
          " -> ${entry.salahName} | Date: ${entry.date} | Time: ${entry.timeString}",
        );
      }
      print("=======================================================");
    } catch (e) {
      print("Failed to save entries to database: $e");
      rethrow;
    }
  }

  /// Raw String Importer
  Future<bool> importFromRawData(String rawString) async {
    try {
      final List<SalahTimeTablesCompanion> entries = TimeParser.parse(
        rawString,
      );
      if (entries.isEmpty) return false;

      await db.transaction(() async {
        for (final entry in entries) {
          await db.into(db.salahTimeTables).insertOnConflictUpdate(entry);
        }
      });

      // Verification log for raw string imports
      final totalCount = await db.select(db.salahTimeTables).get();
      print(
        "Import success. Current total entries in DB: ${totalCount.length}",
      );

      return true;
    } catch (e) {
      print('Error importing timetable: $e');
      return false;
    }
  }
}

class TimetableEntry {
  final String salahName;
  final DateTime date;
  final String timeString;

  TimetableEntry(this.salahName, this.date, this.timeString);
}
