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
    // Standardized extension check for file_picker v12
    final extension = pickedFile.name.contains('.')
        ? pickedFile.name.split('.').last.toLowerCase()
        : '';

    final DateTime selectedDate = DateTime.now();
    List<TimetableEntry> results = [];

    // --- 1. CSV & TXT File Processing ---
    if (extension == 'csv' || extension == 'txt') {
      final String content = await _readFileContentAsString(pickedFile);

      if (extension == 'csv') {
        results = await compute(
          (String data) => UnstructuredParser.parseCSV(data, selectedDate),
          content,
        );
      } else {
        results = await compute(
          (String data) => UnstructuredParser.parseRawText(data, selectedDate),
          content,
        );
      }
    }
    // --- 2. Image OCR Processing (Native Only) ---
    else if (['jpg', 'jpeg', 'png'].contains(extension)) {
      if (kIsWeb) {
        throw UnsupportedError(
          "ML Kit OCR image parsing is not supported on Web.",
        );
      }

      if (pickedFile.path == null) {
        throw Exception("File path required for ML Kit image processing.");
      }

      final inputImage = InputImage.fromFilePath(pickedFile.path!);
      final textRecognizer = TextRecognizer();

      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(
          inputImage,
        );
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
