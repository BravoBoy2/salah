import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/time_parser.dart';

class ImportTimetableService {
  final AppDatabase db;

  ImportTimetableService(this.db);

  /// Main entry point for processing a picked file
  Future<bool> processPickedFile(PlatformFile pickedFile) async {
    final lowerName = (pickedFile.extension ?? '').toLowerCase();
    DateTime selectedDate = DateTime.now();
    List<TimetableEntry> results = [];

    // --- 1. CSV Processing ---
    if (lowerName == 'csv') {
      String content = '';
      if (kIsWeb || pickedFile.bytes != null) {
        content = utf8.decode(pickedFile.bytes!);
      } else if (pickedFile.path != null) {
        content = await File(pickedFile.path!).readAsString();
      }

      results = await compute(
            (String data) => UnstructuredParser.parseCSV(data, selectedDate),
        content,
      );
    }
    // --- 2. Text File Processing ---
    else if (lowerName == 'txt') {
      String content = '';
      if (kIsWeb || pickedFile.bytes != null) {
        content = utf8.decode(pickedFile.bytes!);
      } else if (pickedFile.path != null) {
        content = await File(pickedFile.path!).readAsString();
      }

      results = await compute(
            (String data) => UnstructuredParser.parseRawText(data, selectedDate),
        content,
      );
    }
    // --- 3. Image OCR Processing (Native Only) ---
    else if (['jpg', 'jpeg', 'png'].contains(lowerName)) {
      if (kIsWeb) {
        throw UnsupportedError("ML Kit OCR image parsing is not supported on Web.");
      }

      if (pickedFile.path == null) {
        throw Exception("File path required for ML Kit image processing.");
      }

      final inputImage = InputImage.fromFilePath(pickedFile.path!);
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        // Process directly on the main isolate to avoid object serialization issues across Isolates
        results = SpatialOcrParser.parseOcrBlocks(recognizedText, selectedDate);
      } finally {
        await textRecognizer.close();
      }
    }

    // Save extracted results to database
    if (results.isNotEmpty) {
      await saveEntriesToDatabase(results);
      return true;
    }

    return false;
  }

  /// Save extracted TimetableEntry list using the injected database instance
  Future<void> saveEntriesToDatabase(List<TimetableEntry> entries) async {
    if (entries.isEmpty) return;

    try {
      await db.saveTimetableEntries(entries);
      print("Successfully saved ${entries.length} timetable entries to database.");
    } catch (e) {
      print("Failed to save entries to database: $e");
      rethrow;
    }
    // DO NOT close db here; it's managed at the app level.
  }

  /// Raw String Importer
  Future<bool> importFromRawData(String rawString) async {
    try {
      final List<SalahTimeTablesCompanion> entries = TimeParser.parse(rawString);
      if (entries.isEmpty) return false;

      await db.transaction(() async {
        for (final entry in entries) {
          await db.into(db.salahTimeTables).insertOnConflictUpdate(entry);
        }
      });

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