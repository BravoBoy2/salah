import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:salah/Database/app_database.dart';
import 'package:salah/Services/import_timetable_service.dart';

class UnstructuredParser {
  static String normalizeTo24Hour(String salahName, String rawTime) {
    if (rawTime.trim().isEmpty) return '00:00';

    final upper = rawTime.toUpperCase().trim();
    final isPM = upper.contains('PM');
    final isAM = upper.contains('AM');

    // Match strictly the numbers (HH:mm)
    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(rawTime);
    if (timeMatch == null) return rawTime;

    int hour = int.parse(timeMatch.group(1)!);
    final minuteStr = timeMatch.group(2)!;

    // 1. Explicit AM/PM tags
    if (isPM && hour < 12) hour += 12;
    if (isAM && hour == 12) hour = 0;

    // 2. Fallback heuristic for standard prayer timelines when tags are absent
    if (!isAM && !isPM && hour < 13) {
      final name = salahName.toLowerCase();

      if (name.contains('fajr')) {
        if (hour == 12) hour = 0;
      } else if (name.contains('dhuhr') || name.contains('zuhr')) {
        if (hour < 11) {
          hour += 12; // e.g., 1:15 becomes 13:15, while 12:15 stays 12:15
        }
      } else if (name.contains('asr') ||
          name.contains('maghrib') ||
          name.contains('isha')) {
        if (hour < 12) hour += 12; // Afternoon/evening times offset to PM
      }
    }

    final formattedHour = hour.toString().padLeft(2, '0');
    return '$formattedHour:$minuteStr';
  }

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

      // 2. Parse prayer rows (Month, Date, Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha)
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
        // Column indices: 2=Fajr, 4=Dhuhr (skipping 3=Sunrise), 5=Asr, 6=Maghrib, 7=Isha
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
    r'\b(1[0-2]|0?[1-9]|2[0-3]):([0-5]\d)\s*(AM|PM|am|pm)?\b',
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

  // static String _normalizeTime(String rawTime) {
  //   rawTime = rawTime.toUpperCase().trim();
  //   final isPM = rawTime.contains('PM');
  //   final isAM = rawTime.contains('AM');
  //
  //   // final digitsOnly = rawTime.replaceAll(RegExp(r'[0-9:]'), '');
  //   final timeParts = rawTime.split(':');
  //   if (timeParts.length != 2) return rawTime;
  //
  //   int hour = int.parse(timeParts[0]);
  //   final minutes = timeParts[1];
  //
  //   if (isPM && hour < 12) hour += 12;
  //   if (isAM && hour == 12) hour = 0;
  //
  //   return '${hour.toString().padLeft(2, '0')}: $minutes';
  // }
}

class SpatialOcrParser {
  static List<TimetableEntry> parseOcrBlocks(
    RecognizedText recognizedText,
    DateTime targetDate,
  ) {
    List<TimetableEntry> entries = [];
    List<OcrElement> elements = [];

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

    // Sort top-to-bottom
    elements.sort((a, b) => a.y.compareTo(b.y));

    // Group into horizontal rows
    List<List<OcrElement>> rows = [];
    for (var element in elements) {
      bool placed = false;
      for (var row in rows) {
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

    // Process each row left-to-right
    for (var row in rows) {
      row.sort((a, b) => a.x.compareTo(b.x));

      for (int i = 0; i < row.length; i++) {
        final elementText = row[i].text.toLowerCase();

        for (var keyword in UnstructuredParser.targetKeywords) {
          if (elementText.contains(keyword)) {
            final capitalized = UnstructuredParser._capitalize(keyword);
            String? matchedTime;

            // 1. Check if the time string is in the same OCR box as the keyword
            final sameBoxMatch = UnstructuredParser.timeRegex.firstMatch(
              row[i].text,
            );
            if (sameBoxMatch != null) {
              matchedTime = sameBoxMatch.group(0);
            } else {
              // 2. Look forward in the same horizontal row for the immediate next time string
              for (int j = i + 1; j < row.length; j++) {
                final match = UnstructuredParser.timeRegex.firstMatch(
                  row[j].text,
                );
                if (match != null) {
                  matchedTime = match.group(0);
                  break; // Stop at the start time column (avoiding Iqamah column)
                }
              }
            }

            if (matchedTime != null) {
              final normalized = UnstructuredParser.normalizeTo24Hour(
                capitalized,
                matchedTime,
              );

              entries.add(TimetableEntry(capitalized, targetDate, normalized));
            }
            break;
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
      debugPrint('Parser error: $e');
    }
    return companions;
  }
}
