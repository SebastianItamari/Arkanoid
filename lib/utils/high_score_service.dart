import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const _key = 'high_score';
  static int _highScore = 0;
  static bool _loaded = false;

  static Future<int> load() async {
    if (_loaded) return _highScore;
    final prefs = await SharedPreferences.getInstance();
    _highScore = prefs.getInt(_key) ?? 0;
    _loaded = true;
    return _highScore;
  }

  static Future<void> saveIfHigher(int score) async {
    if (score <= _highScore) return;
    _highScore = score;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, score);
  }

  static int get current => _highScore;
}
