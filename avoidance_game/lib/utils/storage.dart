import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class Storage {
  static const String _highScorePrefix = 'highScore_';
  static const String _leaderboardPrefix = 'leaderboard_';
  static const int _maxLeaderboardEntries = 10;
  
  static Future<int> getHighScore(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_highScorePrefix${difficulty.name}') ?? 0;
  }
  
  static Future<void> setHighScore(Difficulty difficulty, int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_highScorePrefix${difficulty.name}', score);
    
    // Also update leaderboard
    await _updateLeaderboard(difficulty, score);
  }
  
  static Future<void> _updateLeaderboard(Difficulty difficulty, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_leaderboardPrefix${difficulty.name}';
    
    // Get current leaderboard
    final currentScores = prefs.getStringList(key) ?? [];
    final scores = currentScores.map((s) => int.parse(s)).toList();
    
    // Add new score and sort
    scores.add(score);
    scores.sort((a, b) => b.compareTo(a)); // Descending order
    
    // Keep only top 10
    if (scores.length > _maxLeaderboardEntries) {
      scores.removeRange(_maxLeaderboardEntries, scores.length);
    }
    
    // Save back to storage
    await prefs.setStringList(key, scores.map((s) => s.toString()).toList());
  }
  
  static Future<List<int>> getTopScores(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_leaderboardPrefix${difficulty.name}';
    final scoreStrings = prefs.getStringList(key) ?? [];
    return scoreStrings.map((s) => int.parse(s)).toList();
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