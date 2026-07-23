import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/time_parser.dart';

class ImportTimetableService {

  final AppDatabase db;

  ImportTimetableService(this.db);

  // 1. handleImport must be marked 'async' to allow 'await' inside it
  void handleImport(File file, String fileType) async {
    List<TimetableEntry> results = [];
    DateTime selectedDate = DateTime.now();

    if (fileType == 'csv') {
      String content = await file.readAsString();
      results = await compute((String data)=> UnstructuredParser.parseCSV(data, selectedDate), content);
    } else if (fileType == 'txt') {
      String content = await file.readAsString();
      results = await compute((String data)=> UnstructuredParser.parseRawText(data, selectedDate), content);
    } else if (fileType == 'image') {
      // Process with Google ML Kit
      final inputImage = InputImage.fromFile(file);
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);


      
      // Pass to our spatial alignment parser
      results = await Isolate.run(()=> SpatialOcrParser.parseOcrBlocks(recognizedText, selectedDate));
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

  Future<bool> importFromRawData(String rawString) async {
    try {
      final List<SalahTimeTablesCompanion> entries = TimeParser.parse(rawString);
      if(entries.isEmpty) return false;

      await db.transaction(() async {
        for(final entry in entries){
          await db.into(db.salahTimeTables).insertOnConflictUpdate(entry);
        }
      });

      return true;
    } catch(e){
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
