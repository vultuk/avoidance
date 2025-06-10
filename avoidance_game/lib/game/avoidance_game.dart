import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'components/ships/blue_ship.dart';
import 'components/ships/orange_ship.dart';
import 'components/astronaut.dart';
import 'components/oxygen_bar.dart';
import 'components/shield.dart';
import 'managers/wave_manager.dart';
import 'managers/score_manager.dart';
import 'managers/gyroscope_manager.dart';
import 'screens/game_over_screen.dart';
import 'package:flame/camera.dart';

class AvoidanceGame extends FlameGame with DragCallbacks, HasCollisionDetection {
  final Difficulty difficulty;
  late ScoreManager scoreManager;
  late WaveManager waveManager;
  late BlueShip blueShip;
  OrangeShip? orangeShip;
  Astronaut? astronaut;
  OxygenBar? oxygenBar;
  GyroscopeManager? gyroscopeManager;
  bool isGameOver = false;
  bool isPaused = false;

  AvoidanceGame({required this.difficulty});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Set up camera with fixed resolution
    camera.viewfinder.visibleGameSize = size;
    
    // Add background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = GameColors.background,
      priority: -1,
    ));

    // Add star field background
    add(StarFieldComponent(gameSize: size));

    // Initialize managers
    scoreManager = ScoreManager(difficulty: difficulty);
    add(scoreManager);

    waveManager = WaveManager(
      gameSize: size,
      difficulty: difficulty,
      shipWidth: GameSizes.shipSize,
    );
    add(waveManager);

    // Add ships based on difficulty
    switch (difficulty) {
      case Difficulty.easy:
        _setupEasyMode();
        break;
      case Difficulty.medium:
        _setupMediumMode();
        break;
      case Difficulty.hard:
        _setupHardMode();
        break;
      case Difficulty.ultra:
        _setupUltraMode();
        break;
    }

    // Add HUD
    _addHUD();
  }

  void _setupEasyMode() {
    blueShip = BlueShip(
      position: Vector2(size.x / 2, size.y - 100),
      gameSize: size,
    );
    add(blueShip);
  }

  void _setupMediumMode() {
    // Add blue ship (controls vertical movement)
    blueShip = BlueShip(
      position: Vector2(size.x / 2, size.y - 100),
      gameSize: size,
    );
    add(blueShip);
    
    // Add orange ship (controls horizontal movement)
    orangeShip = OrangeShip(
      position: Vector2(100, size.y / 2),
      gameSize: size,
    );
    add(orangeShip!);
  }

  void _setupHardMode() {
    // Add both ships
    blueShip = BlueShip(
      position: Vector2(size.x / 2, size.y - 100),
      gameSize: size,
    );
    add(blueShip);
    
    orangeShip = OrangeShip(
      position: Vector2(100, size.y / 2),
      gameSize: size,
    );
    add(orangeShip!);
  }

  void _setupUltraMode() {
    // Add astronaut
    astronaut = Astronaut(
      position: Vector2(size.x / 2, size.y / 2),
    );
    add(astronaut!);
    
    // Add oxygen bar
    oxygenBar = OxygenBar(
      position: Vector2(size.x / 2 - 100, size.y - 50),
    );
    add(oxygenBar!);
    
    // Initialize gyroscope manager
    gyroscopeManager = GyroscopeManager();
    gyroscopeManager!.onGyroscopeUpdate = (x, y) {
      astronaut?.updateTargetVelocity(x, y);
    };
    gyroscopeManager!.startListening();
  }

  void _addHUD() {
    // Score display
    add(TextComponent(
      text: 'Score: 0',
      position: Vector2(size.x / 2, 30),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameColors.uiText,
          fontSize: GameSizes.fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    )..priority = 10);

    // Pause button
    add(PauseButton(
      position: Vector2(size.x - 60, 30),
      onPressed: togglePause,
    ));
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      pauseEngine();
    } else {
      resumeEngine();
    }
  }

  void gameOver() {
    if (isGameOver) return;
    
    isGameOver = true;
    pauseEngine();
    
    overlays.add('gameOver');
  }

  void restartGame() {
    overlays.remove('gameOver');
    // The game will be recreated by the navigation
  }
  
  bool areAllShieldsDestroyed() {
    if (difficulty != Difficulty.hard) return false;
    
    // Check blue ship shields
    bool blueShieldsDestroyed = true;
    if (blueShip.leftShield != null && !blueShip.leftShield!.isDestroyed) {
      blueShieldsDestroyed = false;
    }
    if (blueShip.rightShield != null && !blueShip.rightShield!.isDestroyed) {
      blueShieldsDestroyed = false;
    }
    
    // Check orange ship shields
    bool orangeShieldsDestroyed = true;
    if (orangeShip != null) {
      if (orangeShip!.topShield != null && !orangeShip!.topShield!.isDestroyed) {
        orangeShieldsDestroyed = false;
      }
      if (orangeShip!.bottomShield != null && !orangeShip!.bottomShield!.isDestroyed) {
        orangeShieldsDestroyed = false;
      }
    }
    
    return blueShieldsDestroyed && orangeShieldsDestroyed;
  }
  
  void checkShieldGameOver() {
    if (difficulty == Difficulty.hard && areAllShieldsDestroyed()) {
      gameOver();
    }
  }

  @override
  void update(double dt) {
    if (isGameOver || isPaused) return;
    
    super.update(dt);

    // Update score display
    final scoreText = children.whereType<TextComponent>().firstWhere(
      (component) => component.text.startsWith('Score:'),
      orElse: () => TextComponent(text: 'Score: 0'),
    );
    scoreText.text = 'Score: ${scoreManager.currentScore}';
    
    // Update oxygen in Ultra mode
    if (difficulty == Difficulty.ultra && oxygenBar != null) {
      oxygenBar!.depleteOxygen(dt);
      
      // Check for oxygen depletion
      if (oxygenBar!.isOxygenDepleted()) {
        gameOver();
      }
    }
  }
  
  @override
  void onRemove() {
    gyroscopeManager?.dispose();
    super.onRemove();
  }
}

class StarFieldComponent extends Component {
  final Vector2 gameSize;
  final List<Star> stars = [];
  
  StarFieldComponent({required this.gameSize});

  @override
  Future<void> onLoad() async {
    // Generate random stars
    for (int i = 0; i < 50; i++) {
      stars.add(Star(
        position: Vector2(
          gameSize.x * (i * 17 % 100) / 100,
          gameSize.y * (i * 23 % 100) / 100,
        ),
        size: (i % 3) + 1,
        speed: 20 + (i % 30),
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.uiText
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      paint.color = GameColors.uiText.withOpacity(0.3 + star.size * 0.1);
      canvas.drawCircle(star.position.toOffset(), star.size.toDouble(), paint);
    }
  }

  @override
  void update(double dt) {
    for (final star in stars) {
      star.position.y += star.speed * dt;
      
      // Wrap around when star goes off screen
      if (star.position.y > gameSize.y) {
        star.position.y = 0;
        star.position.x = gameSize.x * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000;
      }
    }
  }
}

class Star {
  Vector2 position;
  final int size;
  final double speed;

  Star({
    required this.position,
    required this.size,
    required this.speed,
  });
}

class PauseButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  
  PauseButton({
    required Vector2 position,
    required this.onPressed,
  }) : super(
    position: position,
    size: Vector2.all(40),
    anchor: Anchor.center,
  );

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.uiText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw circle button
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );

    // Draw pause bars
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.3, size.y * 0.3, size.x * 0.15, size.y * 0.4),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.x * 0.55, size.y * 0.3, size.x * 0.15, size.y * 0.4),
      paint,
    );
  }

  @override
  bool onTapUp(TapUpEvent event) {
    onPressed();
    return true;
  }
}