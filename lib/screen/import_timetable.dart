import 'dart:io';

import 'package:file_picker/file_picker.dart'; // Standard official package
import 'package:flutter/material.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/time_parser.dart';

class ImportTimeTable extends StatefulWidget {
  const ImportTimeTable({super.key});

  @override
  State<ImportTimeTable> createState() => _ImportTimeTableState();
}

class _KeepStatus {
  bool isProcessing = false;
  String statusMessage = "Select a timetable file (CSV, PDF or Image) to begin";
}

class _ImportTimeTableState extends State<ImportTimeTable> {
  final _KeepStatus _status = _KeepStatus();

  Future<void> _pickAndProcessFile() async {
    setState(() {
      _status.isProcessing = true;
      _status.statusMessage = "Opening file picker...";
    });

    try {
      // 1. Call the static method directly on the class
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'pdf', 'jpg', 'jpeg', 'png'],
      );

      // If null, user closed the picker dialog
      if (result == null || result.files.isEmpty) {
        setState(() {
          _status.isProcessing = false;
          _status.statusMessage = "Import Cancelled";
        });
        return;
      }

      setState(() {
        _status.statusMessage = "Processing and parsing file...";
      });

      // 2. Grab the picked file metadata
      final PlatformFile pickedFile = result.files.first;

      if (pickedFile.path == null) {
        throw Exception("Could not resolve local file path.");
      }

      // Create a native dart:io File from the string path
      final File file = File(pickedFile.path!);
      final String fileContent = await file.readAsString();

      // Determine the extension format cleanly
      String fileType = 'csv';
      final lowerName = (pickedFile.extension ?? '').toLowerCase();
      if (lowerName == 'pdf') {
        fileType = 'pdf';
      } else if (lowerName == 'jpg' ||
          lowerName == 'jpeg' ||
          lowerName == 'png') {
        fileType = 'image';
      }

      // 3. Send raw string contents straight to your custom parser
      await handleImportFromContent(fileContent, fileType);

      setState(() {
        _status.isProcessing = false;
        _status.statusMessage =
            "Timetable successfully imported to your database!";
      });
    } catch (e) {
      setState(() {
        _status.isProcessing = false;
        _status.statusMessage = "Error reading file: $e";
      });
    }
  }

  Future<void> handleImportFromContent(String content, String fileType) async {
    final database = AppDatabase();
    List<dynamic> results = [];
    DateTime selectedDate = DateTime.now();

    if (fileType == 'csv') {
      results = UnstructuredParser.parseCSV(content, selectedDate);
    }

    if (results.isNotEmpty) {
      await database.saveTimetableEntries(results);
      print('Successfully wrote ${results.length} rows to the local database!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.upload_file, size: 80),
          const SizedBox(height: 24),
          Text(
            _status.statusMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          if (_status.isProcessing)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton.icon(
              onPressed: _pickAndProcessFile,
              icon: const Icon(Icons.search),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text("Pick Timetable File"),
              ),
            ),
        ],
      ),
    );
  }
}
