import 'dart:io';

import 'package:flutter/material.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/import_timetable_service.dart';
import 'package:salah/Services/time_parser.dart';

class ImportTimeTable extends StatelessWidget {

  final AppDatabase database = AppDatabase();

  ImportTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Text('Import Timetable'),
    );
  }

  void handleImport(File file, String fileType) async {
    List<TimetableEntry> results = [];
    DateTime selectedDate = DateTime.now();


    if (fileType == 'csv') {
      String content = await file.readAsString();
      results = UnstructuredParser.parseCSV(content, selectedDate);
    }

    if (results.isNotEmpty) {
      await database.saveTimetableEntries(results);
      print("Successfully wrote ${results.length} rows to the local database!");
    }
  }
}
