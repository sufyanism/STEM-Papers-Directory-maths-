import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReadingHistoryService {
  static const String key = "reading_history";

  /// SAVE PAPER TO HISTORY
  static Future<void> addPaper(Map<String, dynamic> paper) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> stored = prefs.getStringList(key) ?? [];

    /// avoid duplicates
    stored.removeWhere((e) {
      final decoded = jsonDecode(e);
      return decoded["link"] == paper["link"];
    });

    stored.insert(0, jsonEncode(paper)); // latest on top

    await prefs.setStringList(key, stored);
  }

  /// GET HISTORY
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(key) ?? [];

    return stored.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// CLEAR HISTORY
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}