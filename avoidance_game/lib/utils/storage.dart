import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class Storage {
  static const String _highScorePrefix = 'highScore_';
  
  static Future<int> getHighScore(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_highScorePrefix${difficulty.name}') ?? 0;
  }
  
  static Future<void> setHighScore(Difficulty difficulty, int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_highScorePrefix${difficulty.name}', score);
  }
  
  static Future<Map<Difficulty, int>> getAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = <Difficulty, int>{};
    
    for (final difficulty in Difficulty.values) {
      scores[difficulty] = prefs.getInt('$_highScorePrefix${difficulty.name}') ?? 0;
    }
    
    return scores;
  }
  
  static Future<void> clearAllHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (final difficulty in Difficulty.values) {
      await prefs.remove('$_highScorePrefix${difficulty.name}');
    }
  }
}