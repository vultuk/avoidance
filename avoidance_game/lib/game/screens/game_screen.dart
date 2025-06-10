import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../utils/constants.dart';
import '../avoidance_game.dart';
import 'game_over_screen.dart';

class GameScreen extends StatelessWidget {
  final Difficulty difficulty;
  
  const GameScreen({
    super.key,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    final game = AvoidanceGame(difficulty: difficulty);
    
    return Scaffold(
      backgroundColor: GameColors.background,
      body: GameWidget(
        game: game,
        overlayBuilderMap: {
          'gameOver': (BuildContext context, AvoidanceGame game) {
            return GameOverScreen(game: game);
          },
        },
      ),
    );
  }
}