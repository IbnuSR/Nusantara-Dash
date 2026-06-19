import 'package:shared_preferences/shared_preferences.dart';

class GamePrefs {
  static const String _prologueKey = 'has_watched_prologue';

  static Future<bool> hasWatchedPrologue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prologueKey) ?? false;
  }

  static Future<void> markPrologueWatched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prologueKey, true);
  }

  static Future<void> resetPrologue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prologueKey);
  }
}
