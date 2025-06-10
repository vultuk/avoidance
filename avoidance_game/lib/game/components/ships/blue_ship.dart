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
  Shield? leftShield;
  Shield? rightShield;
  
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
    
    // Add shields if in Hard mode
    final game = findParent<AvoidanceGame>();
    if (game != null && game.difficulty == Difficulty.hard) {
      // Left shield (protects from orange waves)
      leftShield = Shield(
        shieldPosition: ShieldPosition.left,
        baseColor: GameColors.orange,
      );
      leftShield!.position = Vector2(-size.x/2 - GameSizes.shieldWidth/2, 0);
      add(leftShield!);
      
      // Right shield (protects from orange waves)
      rightShield = Shield(
        shieldPosition: ShieldPosition.right,
        baseColor: GameColors.orange,
      );
      rightShield!.position = Vector2(size.x/2 + GameSizes.shieldWidth/2, 0);
      add(rightShield!);
    }
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
    final game = findParent<AvoidanceGame>();
    
    // In Easy mode, handle drag normally
    // In Medium/Hard modes, this is handled by multi-touch in AvoidanceGame
    if (game?.difficulty == Difficulty.easy) {
      // Update position based on drag
      position.add(event.localDelta);
      
      // Keep ship within screen bounds
      position.x = position.x.clamp(size.x / 2, gameSize.x - size.x / 2);
      position.y = position.y.clamp(size.y / 2, gameSize.y - size.y / 2);
      
      return true;
    }
    
    return false;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Check if collision is with a particle wave
    if (other is ParticleWave) {
      // Blue ship only collides with blue waves (from top)
      if (other.color == GameColors.blue) {
        final game = findParent<AvoidanceGame>();
        if (game != null) {
          game.gameOver();
        }
      }
    }
  }
}