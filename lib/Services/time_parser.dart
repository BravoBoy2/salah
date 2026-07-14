import 'package:csv/csv.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:salah/Services/import_timetable_service.dart';

class UnstructuredParser {
  /*
  Regular expression for time format.
  Based on 12 hours or 24 hours
  including AM/PM

   */
  static final RegExp timeRegex = RegExp(
    r'\b((?:[01]?\d|2[0-3]):[0-5]\d)\s*(AM|PM|am|pm)?\b',
  );

  static final List<String> targetKeywords = [
    'fajr',
    'sunrise',
    'dhuhr',
    'asr',
    'maghrib',
    'isha',
  ];

  /*
  CSV Parsing
   */

  static List<TimetableEntry> parseCSV(String rawCsv, DateTime targetDate) {
    List<TimetableEntry> entries = [];

    final rows = csv.decode(rawCsv);

    for (final row in rows) {
      if (row.isEmpty) continue;

      for (int i = 0; i < row.length; i++) {
        final cellValue = row[i].toString().trim().toLowerCase();

        if (targetKeywords.contains(cellValue)) {
          for (int j = i + 1; j < row.length; j++) {
            final possibleTime = row[j].toString().trim();

            if (timeRegex.hasMatch(possibleTime)) {
              entries.add(
                TimetableEntry(
                  _capitalize(cellValue),
                  targetDate,
                  _normalizeTime(possibleTime),
                ),
              );
              break;
            }
          }
        }
      }
    }
    return entries;
  }

  /* ==========================================
  // STRATEGY 2: REGEX/TEXT-STREAM PARSING (PDF/Plain Text)
  ===========================================
  */
  static List<TimetableEntry> parseRawText(
    String rawText,
    DateTime targetDate,
  ) {
    List<TimetableEntry> entries = [];
    final lines = rawText.split('\n');

    for (var line in lines) {
      final cleanLine = line.trim().toLowerCase();
      if (cleanLine.isEmpty) continue;

      // Check if this line contains a prayer name
      for (var keyword in targetKeywords) {
        if (cleanLine.contains(keyword)) {
          // Find any times on this same line
          final matches = timeRegex.allMatches(line);
          if (matches.isNotEmpty) {
            // Take the first matching time on the line
            final timeMatch = matches.first.group(0)!;
            entries.add(
              TimetableEntry(
                _capitalize(keyword),
                targetDate,
                _normalizeTime(timeMatch),
              ),
            );
          }
        }
      }
    }
    return entries;
  }

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static String _normalizeTime(String rawTime) {
    rawTime = rawTime.toUpperCase().trim();
    final isPM = rawTime.contains('PM');
    final isAM = rawTime.contains('AM');

    final digitsOnly = rawTime.replaceAll(RegExp(r'[0-9:]'), '');
    final timeParts = rawTime.split(':');
    if (timeParts.length != 2) return rawTime;

    int hour = int.parse(timeParts[0]);
    final minutes = timeParts[1];

    if (isPM && hour < 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    return '${hour.toString().padLeft(2, '0')}: $minutes';
  }
}

class SpatialOcrParser {
  static List<TimetableEntry> parseOcrBlocks(
    RecognizedText recognizedText,
    DateTime targetDate,
  ) {
    List<TimetableEntry> entries = [];
    List<OcrElement> elements = [];

    // Extract every single word/block with its visual coordinates
    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        final text = line.text.trim();
        final boundingBox = line.boundingBox;

        elements.add(
          OcrElement(
            text: text,
            x: boundingBox.left,
            y: boundingBox.top,
            height: boundingBox.height,
          ),
        );
      }
    }

    // 1. Group items that are on the same visual horizontal row (similar Y values)
    // We sort vertically (Y) first
    elements.sort((a, b) => a.y.compareTo(b.y));

    List<List<OcrElement>> rows = [];
    for (var element in elements) {
      bool placed = false;
      for (var row in rows) {
        // If the element's Y-coordinate is within half a line-height of an existing row, group them
        if ((element.y - row.first.y).abs() < (element.height * 0.7)) {
          row.add(element);
          placed = true;
          break;
        }
      }
      if (!placed) {
        rows.add([element]);
      }
    }

    // 2. Sort each horizontal row from left to right (X values)
    for (var row in rows) {
      row.sort((a, b) => a.x.compareTo(b.x));

      // Now, evaluate the reconstructed rows
      String rowText = row.map((e) => e.text).join(" ");

      // Check if a prayer name exists on this reconstructed line
      for (var keyword in UnstructuredParser.targetKeywords) {
        if (rowText.toLowerCase().contains(keyword)) {
          final matches = UnstructuredParser.timeRegex.allMatches(rowText);
          if (matches.isNotEmpty) {
            final matchedTime = matches.first.group(0)!;
            entries.add(
              TimetableEntry(
                UnstructuredParser._capitalize(keyword),
                targetDate,
                UnstructuredParser._normalizeTime(matchedTime),
              ),
            );
          }
        }
      }
    }

    return entries;
  }
}

class OcrElement {
  final String text;
  final double x;
  final double y;
  final double height;

  OcrElement({
    required this.text,
    required this.x,
    required this.y,
    required this.height,
  });
}
