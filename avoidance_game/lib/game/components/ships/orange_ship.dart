import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../particle_wave.dart';
import '../../avoidance_game.dart';

class OrangeShip extends PositionComponent with DragCallbacks, CollisionCallbacks {
  final Vector2 gameSize;
  bool isDragging = false;
  
  OrangeShip({
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
      ..color = GameColors.orange
      ..style = PaintingStyle.fill;

    // Draw arrow-shaped ship pointing right (90° rotation)
    final path = Path();
    
    // Start from left center
    path.moveTo(0, size.y / 2);
    
    // Draw top side
    path.lineTo(size.x * 0.3, 0);
    path.lineTo(size.x * 0.7, 0);
    
    // Draw right point
    path.lineTo(size.x, size.y / 2);
    
    // Draw bottom side
    path.lineTo(size.x * 0.7, size.y);
    path.lineTo(size.x * 0.3, size.y);
    
    // Close the path
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Add a subtle glow effect
    paint.color = GameColors.orange.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path, paint);
  }

  @override
  bool onDragStart(DragStartEvent event) {
    isDragging = true;
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (isDragging) {
      // Update position based on drag
      position.add(event.localDelta);
      
      // Keep ship within screen bounds
      position.x = position.x.clamp(size.x / 2, gameSize.x - size.x / 2);
      position.y = position.y.clamp(size.y / 2, gameSize.y - size.y / 2);
    }
    
    return true;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    isDragging = false;
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
      // Trigger game over for Medium mode
      final game = findParent<AvoidanceGame>();
      game?.gameOver();
    }
  }
}