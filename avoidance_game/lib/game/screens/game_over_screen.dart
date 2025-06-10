import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/constants.dart';
import '../avoidance_game.dart';
import 'menu_screen.dart';
import 'game_screen.dart';

class GameOverScreen extends StatefulWidget {
  final AvoidanceGame game;
  
  const GameOverScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  int? highScore;
  bool isNewHighScore = false;

  @override
  void initState() {
    super.initState();
    _checkHighScore();
  }

  Future<void> _checkHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'highScore_${widget.game.difficulty.name}';
    final currentHighScore = prefs.getInt(key) ?? 0;
    
    setState(() {
      highScore = currentHighScore;
      if (widget.game.scoreManager.currentScore > currentHighScore) {
        isNewHighScore = true;
        highScore = widget.game.scoreManager.currentScore;
        prefs.setInt(key, widget.game.scoreManager.currentScore);
      }
    });
  }

  void _retry() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(difficulty: widget.game.difficulty),
      ),
    );
  }

  void _returnToMenu() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MenuScreen(),
      ),
    );
  }

  void _share() {
    final score = widget.game.scoreManager.currentScore;
    final difficulty = widget.game.difficulty.displayName;
    Share.share(
      'I survived $score seconds on $difficulty mode in Avoidance! Can you beat my score?',
      subject: 'Avoidance Game Score',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withOpacity(0.9),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: GameColors.background,
            border: Border.all(color: GameColors.blue, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: GameColors.uiText,
                  fontSize: GameSizes.titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Final Score: ${widget.game.scoreManager.currentScore}',
                style: const TextStyle(
                  color: GameColors.blue,
                  fontSize: GameSizes.fontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Difficulty: ${widget.game.difficulty.displayName}',
                style: const TextStyle(
                  color: GameColors.uiText,
                  fontSize: GameSizes.fontSize,
                ),
              ),
              if (highScore != null) ...[
                const SizedBox(height: 10),
                Text(
                  isNewHighScore ? 'NEW HIGH SCORE!' : 'Best: $highScore',
                  style: TextStyle(
                    color: isNewHighScore ? GameColors.powerUpGreen : GameColors.orange,
                    fontSize: GameSizes.fontSize,
                    fontWeight: isNewHighScore ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GameOverButton(
                    text: 'RETRY',
                    color: GameColors.blue,
                    onPressed: _retry,
                  ),
                  const SizedBox(width: 16),
                  _GameOverButton(
                    text: 'MENU',
                    color: GameColors.orange,
                    onPressed: _returnToMenu,
                  ),
                  const SizedBox(width: 16),
                  _GameOverButton(
                    text: 'SHARE',
                    color: GameColors.powerUpGreen,
                    onPressed: _share,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameOverButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _GameOverButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}