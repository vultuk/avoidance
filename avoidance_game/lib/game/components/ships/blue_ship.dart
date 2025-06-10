import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../particle_wave.dart';
import '../shield.dart';
import '../../avoidance_game.dart';

class BlueShip extends PositionComponent with DragCallbacks, CollisionCallbacks {
  final Vector2 gameSize;
  
  BlueShip({
    required Vector2 position,
    required this.gameSize,
  }) : super(
    position: position,
    size: Vector2.all(GameSizes.shipSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision detection
    add(RectangleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.blue
      ..style = PaintingStyle.fill;

    // Draw arrow-shaped ship pointing up
    final path = Path();
    
    // Start from bottom center
    path.moveTo(size.x / 2, size.y);
    
    // Draw left side
    path.lineTo(0, size.y * 0.7);
    path.lineTo(0, size.y * 0.3);
    
    // Draw top point
    path.lineTo(size.x / 2, 0);
    
    // Draw right side
    path.lineTo(size.x, size.y * 0.3);
    path.lineTo(size.x, size.y * 0.7);
    
    // Close the path
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add a subtle glow effect
    paint.color = GameColors.blue.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, paint);
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    // Update position based on drag
    position.add(event.localDelta);
    
    // Keep ship within screen bounds
    position.x = position.x.clamp(size.x / 2, gameSize.x - size.x / 2);
    position.y = position.y.clamp(size.y / 2, gameSize.y - size.y / 2);
    
    return true;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Check if collision is with a particle wave
    if (other is ParticleWave) {
      final game = findParent<AvoidanceGame>();
      if (game != null) {
        // In Hard mode, check if shields can absorb the hit
        if (game.difficulty == Difficulty.hard && game.shields.isNotEmpty) {
          bool shieldHit = false;
          for (final shield in game.shields) {
            if (!shield.isDestroyed) {
              shield.takeDamage();
              shieldHit = true;
              // TODO: Add screen shake and flash effects
              break;
            }
          }
          
          // If no shields left, game over
          if (!shieldHit) {
            game.gameOver();
          }
        } else {
          // Easy/Medium mode - direct game over
          game.gameOver();
        }
      }
    }
  }
}