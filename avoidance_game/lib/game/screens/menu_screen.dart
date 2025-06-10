import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _starController;
  Map<Difficulty, int> highScores = {};

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var difficulty in Difficulty.values) {
        highScores[difficulty] = prefs.getInt('highScore_${difficulty.name}') ?? 0;
      }
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  void _startGame(Difficulty difficulty) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GameScreen(difficulty: difficulty),
      ),
    );
  }

  void _showHighScores() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameColors.background.withOpacity(0.9),
        title: const Text(
          'HIGH SCORES',
          style: TextStyle(
            color: GameColors.uiText,
            fontSize: GameSizes.titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((difficulty) {
            final score = highScores[difficulty] ?? 0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    difficulty.displayName,
                    style: const TextStyle(
                      color: GameColors.uiText,
                      fontSize: GameSizes.fontSize,
                    ),
                  ),
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      color: GameColors.blue,
                      fontSize: GameSizes.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CLOSE',
              style: TextStyle(color: GameColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Animated star field background
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: StarFieldPainter(
                  animationValue: _starController.value,
                ),
              );
            },
          ),
          // Menu content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                const Text(
                  'AVOIDANCE',
                  style: TextStyle(
                    color: GameColors.uiText,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 60),
                // Difficulty buttons
                ...Difficulty.values.map((difficulty) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: _MenuButton(
                    text: difficulty.displayName,
                    color: difficulty == Difficulty.easy || difficulty == Difficulty.hard
                        ? GameColors.blue
                        : GameColors.orange,
                    onPressed: () => _startGame(difficulty),
                  ),
                )),
                const SizedBox(height: 40),
                // Bottom buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _MenuButton(
                      text: 'LEADERBOARD',
                      color: GameColors.uiText,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    _MenuButton(
                      text: 'HIGH SCORES',
                      color: GameColors.uiText,
                      onPressed: _showHighScores,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GameSizes.buttonWidth,
      height: GameSizes.buttonHeight,
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
            fontSize: GameSizes.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class StarFieldPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars = [];

  StarFieldPainter({required this.animationValue}) {
    // Generate stars if empty
    if (stars.isEmpty) {
      final random = DateTime.now().millisecondsSinceEpoch;
      for (int i = 0; i < 100; i++) {
        stars.add(Star(
          x: (random * (i + 1)) % 1000 / 1000,
          y: (random * (i + 7)) % 1000 / 1000,
          size: (random * (i + 13)) % 3 + 1,
          speed: (random * (i + 19)) % 50 / 100 + 0.1,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GameColors.uiText
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      final x = star.x * size.width;
      final y = ((star.y + animationValue * star.speed) % 1) * size.height;
      
      paint.color = GameColors.uiText.withOpacity(0.3 + star.size * 0.2);
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) => true;
}

class Star {
  final double x;
  final double y;
  final double size;
  final double speed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
  });
}