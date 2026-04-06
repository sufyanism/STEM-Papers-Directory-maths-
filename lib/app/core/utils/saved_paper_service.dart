import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPapersService {
  static const String key = "saved_papers";

  /// ================= GET =================
  static Future<List<Map<String, dynamic>>> getSavedPapers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();
  }

  /// ================= SAVE =================
  static Future<void> savePaper(Map<String, dynamic> paper) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    final exists = data.any((e) {
      final decoded = jsonDecode(e);
      return decoded["link"] == paper["link"];
    });

    if (!exists) {
      paper["type"] = paper["type"] ?? "all"; // ✅ IMPORTANT
      data.add(jsonEncode(paper));
      await prefs.setStringList(key, data);
    }
  }

  /// ================= REMOVE =================
  static Future<void> removePaper(String link) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    data.removeWhere((e) {
      final decoded = jsonDecode(e);
      return decoded["link"] == link;
    });

    await prefs.setStringList(key, data);
  }

  /// ================= CHECK =================
  static Future<bool> isSaved(String link) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    return data.any((e) {
      final decoded = jsonDecode(e);
      return decoded["link"] == link;
    });
  }

  /// ================= UPDATE =================
  static Future<void> updatePaper(Map<String, dynamic> paper) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];

    final updated = data.map((e) {
      final decoded = jsonDecode(e);

      if (decoded["link"] == paper["link"]) {
        return jsonEncode(paper); // replace correct item
      }
      return e;
    }).toList();

    await prefs.setStringList(key, updated);
  }

  /// ================= CLEAR =================
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}