import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../avoidance_game.dart';
import 'ships/blue_ship.dart';
import 'ships/orange_ship.dart';

class PowerUp extends PositionComponent with CollisionCallbacks {
  final Vector2 gameSize;
  final double speed;
  double _pulseTime = 0;
  double _glowRadius = 0;
  
  PowerUp({
    required Vector2 position,
    required this.gameSize,
    required this.speed,
  }) : super(
    position: position,
    size: Vector2.all(GameSizes.powerUpSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add circular hitbox
    add(CircleHitbox());
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = GameColors.powerUpGreen
      ..style = PaintingStyle.fill;
    
    // Draw pulsing glow effect
    final glowPaint = Paint()
      ..color = GameColors.powerUpGreen.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, _glowRadius);
    
    // Draw glow
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 + _glowRadius,
      glowPaint,
    );
    
    // Draw main power-up circle
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );
    
    // Draw inner star pattern
    paint.color = GameColors.background;
    final center = Offset(size.x / 2, size.y / 2);
    final path = Path();
    
    // Create star shape
    const int points = 8;
    const double innerRadius = 8;
    const double outerRadius = 12;
    
    for (int i = 0; i < points * 2; i++) {
      final angle = i * pi / points;
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    // Update pulse animation
    _pulseTime += dt;
    _glowRadius = 5 + 10 * sin(_pulseTime * 2 * pi / GameConstants.powerUpPulseDuration.inSeconds);
    
    // Move down the screen
    position.y += speed * dt;
    
    // Remove when off screen
    if (position.y > gameSize.y + size.y) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Check if collision is with a ship
    if (other is BlueShip || other is OrangeShip) {
      // Restore shields
      final game = findParent<AvoidanceGame>();
      if (game != null && game.difficulty == Difficulty.hard) {
        for (final shield in game.shields) {
          shield.restore();
        }
      }
      
      // Remove power-up
      removeFromParent();
    }
  }
}