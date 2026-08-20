import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/import_timetable_service.dart';

class UnstructuredParser {
  /// Parses CSV string content into a flat list of TimetableEntry items.
  static List<TimetableEntry> parseCSV(String rawCsv, DateTime selectedDate) {
    final List<TimetableEntry> entries = [];
    final lines = rawCsv.split(RegExp(r'\r?\n'));

    bool headerFound = false;

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',').map((e) => e.trim()).toList();

      // 1. Skip metadata rows until we reach the header row starting with "Month" and "Date"
      if (!headerFound) {
        if (parts.length >= 2 &&
            parts[0].toLowerCase() == 'month' &&
            parts[1].toLowerCase() == 'date') {
          headerFound = true;
        }
        continue; // Skip the metadata line or header line itself
      }

      // 2. Parse prayer rows (Month, Date, Fajr, Sunrise, Duhr, Asr, Maghrib, Isha)
      if (parts.length >= 8) {
        final monthStr = parts[0];
        final dayStr = parts[1];

        final monthNum = _getMonthNumber(monthStr);
        final dayNum = int.tryParse(dayStr);

        // Skip invalid rows or footer text
        if (dayNum == null) continue;

        // Construct the row's date using the current year from selectedDate
        final rowDate = DateTime(selectedDate.year, monthNum, dayNum);

        // Map individual prayers into TimetableEntry instances
        // Column indices: 2=Fajr, 4=Duhr (skipping 3=Sunrise), 5=Asr, 6=Maghrib, 7=Isha
        final map = {
          'Fajr': parts[2],
          'Dhuhr': parts[4],
          'Asr': parts[5],
          'Maghrib': parts[6],
          'Isha': parts[7],
        };

        map.forEach((salahName, timeString) {
          if (timeString.isNotEmpty) {
            entries.add(TimetableEntry(salahName, rowDate, timeString));
          }
        });
      }
    }

    return entries;
  }

  /// Helper to convert month names (Jan, Feb, etc.) to 1-12 integers
  static int _getMonthNumber(String month) {
    const months = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };

    if (month.isEmpty) return 1;
    final clean = month.length >= 3
        ? month.substring(0, 3).toLowerCase()
        : month.toLowerCase();
    return months[clean] ?? 1;
  }

  static List<TimetableEntry> parseRawText(
    String rawText,
    DateTime selectedDate,
  ) {
    // Keep your existing parseRawText implementation here
    return [];
  }

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

  // static List<TimetableEntry> parseCSV(String rawCsv, DateTime targetDate) {
  //   List<TimetableEntry> entries = [];
  //
  //   final rows = csv.decode(rawCsv);
  //
  //   for (final row in rows) {
  //     if (row.isEmpty) continue;
  //
  //     for (int i = 0; i < row.length; i++) {
  //       final cellValue = row[i].toString().trim().toLowerCase();
  //
  //       if (targetKeywords.contains(cellValue)) {
  //         for (int j = i + 1; j < row.length; j++) {
  //           final possibleTime = row[j].toString().trim();
  //
  //           if (timeRegex.hasMatch(possibleTime)) {
  //             entries.add(
  //               TimetableEntry(
  //                 _capitalize(cellValue),
  //                 targetDate,
  //                 _normalizeTime(possibleTime),
  //               ),
  //             );
  //             break;
  //           }
  //         }
  //       }
  //     }
  //   }
  //   return entries;
  // }

  /* ==========================================
  // STRATEGY 2: REGEX/TEXT-STREAM PARSING (PDF/Plain Text)
  ===========================================
  */
  // static List<TimetableEntry> parseRawText(
  //   String rawText,
  //   DateTime targetDate,
  // ) {
  //   List<TimetableEntry> entries = [];
  //   final lines = rawText.split('\n');
  //
  //   for (var line in lines) {
  //     final cleanLine = line.trim().toLowerCase();
  //     if (cleanLine.isEmpty) continue;
  //
  //     // Check if this line contains a prayer name
  //     for (var keyword in targetKeywords) {
  //       if (cleanLine.contains(keyword)) {
  //         // Find any times on this same line
  //         final matches = timeRegex.allMatches(line);
  //         if (matches.isNotEmpty) {
  //           // Take the first matching time on the line
  //           final timeMatch = matches.first.group(0)!;
  //           entries.add(
  //             TimetableEntry(
  //               _capitalize(keyword),
  //               targetDate,
  //               _normalizeTime(timeMatch),
  //             ),
  //           );
  //         }
  //       }
  //     }
  //   }
  //   return entries;
  // }

  static String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  static String _normalizeTime(String rawTime) {
    rawTime = rawTime.toUpperCase().trim();
    final isPM = rawTime.contains('PM');
    final isAM = rawTime.contains('AM');

    // final digitsOnly = rawTime.replaceAll(RegExp(r'[0-9:]'), '');
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

class TimeParser {
  static List<SalahTimeTablesCompanion> parse(String rawString) {
    final List<SalahTimeTablesCompanion> companions = [];

    try {
      final decoded = jsonDecode(rawString);

      if (decoded is List) {
        for (final item in decoded) {
          companions.add(
            SalahTimeTablesCompanion(
              salahName: Value(item['salahName'] ?? 'Unknown'),
              date: Value(
                DateTime.tryParse(item['date'] ?? '') ?? DateTime.now(),
              ),
              timeString: Value(item['timeString'] ?? '00:00'),
            ),
          );
        }
      }
    } catch (e) {
      print('Parser error: $e');
    }
    return companions;
  }
}
