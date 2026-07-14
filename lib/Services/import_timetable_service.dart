import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/time_parser.dart';

class ImportTimetableService {
  // 1. handleImport must be marked 'async' to allow 'await' inside it
  void handleImport(File file, String fileType) async {
    List<TimetableEntry> results = [];
    DateTime selectedDate = DateTime.now();

    if (fileType == 'csv') {
      String content = await file.readAsString();
      results = UnstructuredParser.parseCSV(content, selectedDate);
    } else if (fileType == 'txt') {
      String content = await file.readAsString();
      results = UnstructuredParser.parseRawText(content, selectedDate);
    } else if (fileType == 'image') {
      // Process with Google ML Kit
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Pass to our spatial alignment parser
      results = SpatialOcrParser.parseOcrBlocks(recognizedText, selectedDate);
      textRecognizer.close();
    }

    // Next up: Save 'results' into your SQLite database!
    // Added 'await' here because database operations run in the background
    await _saveToDatabase(results);
  }

  // 2. MOVED: This helper function is now inside the Service class where it can be called
  Future<void> _saveToDatabase(List<TimetableEntry> entries) async {
    if (entries.isEmpty) return;

    final database = AppDatabase();

    try {
      await database.saveTimetableEntries(entries);
      print("Successfully saved ${entries.length} salah times to database");
    } catch (e) {
      print("Failed to save salah times to database: $e");
    } finally {
      await database.close();
    }
  }
}

class TimetableEntry {
  final String salahName;
  final DateTime date;
  final String timeString;

  TimetableEntry(this.salahName, this.date, this.timeString);
}
