import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'particle_wave.dart';
import '../avoidance_game.dart';

enum ShieldPosition { left, right, top, bottom }

class Shield extends PositionComponent with CollisionCallbacks {
  final ShieldPosition shieldPosition;
  final Color baseColor; // Color of the wave it protects from
  int health = 3;
  final int maxHealth = 3;
  
  Shield({
    required this.shieldPosition,
    required this.baseColor,
  }) : super(
    size: _getSize(shieldPosition),
    anchor: Anchor.center,
  );
  
  static Vector2 _getSize(ShieldPosition position) {
    switch (position) {
      case ShieldPosition.left:
      case ShieldPosition.right:
        return Vector2(GameSizes.shieldWidth, GameSizes.shieldHeight);
      case ShieldPosition.top:
      case ShieldPosition.bottom:
        return Vector2(GameSizes.shieldHeight, GameSizes.shieldWidth);
    }
  }

  @override
  void render(Canvas canvas) {
    if (health <= 0) return;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Color based on health, using the base color with varying opacity
    switch (health) {
      case 3:
        paint.color = baseColor;
        break;
      case 2:
        paint.color = baseColor.withOpacity(0.7);
        break;
      case 1:
        paint.color = baseColor.withOpacity(0.4);
        break;
    }
    
    // Draw curved shield shape
    final path = Path();
    
    final isVertical = shieldPosition == ShieldPosition.left || shieldPosition == ShieldPosition.right;
    
    if (isVertical) {
      // Vertical shield (curved on sides)
      path.moveTo(0, size.y * 0.1);
      path.quadraticBezierTo(
        -size.x * 0.2, size.y * 0.5,
        0, size.y * 0.9,
      );
      path.lineTo(size.x, size.y * 0.9);
      path.quadraticBezierTo(
        size.x + size.x * 0.2, size.y * 0.5,
        size.x, size.y * 0.1,
      );
      path.close();
    } else {
      // Horizontal shield (curved on top/bottom)
      path.moveTo(size.x * 0.1, 0);
      path.quadraticBezierTo(
        size.x * 0.5, -size.y * 0.2,
        size.x * 0.9, 0,
      );
      path.lineTo(size.x * 0.9, size.y);
      path.quadraticBezierTo(
        size.x * 0.5, size.y + size.y * 0.2,
        size.x * 0.1, size.y,
      );
      path.close();
    }
    
    canvas.drawPath(path, paint);
    
    // Add damage cracks for visual degradation
    if (health < maxHealth) {
      paint.color = Colors.black.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      
      // Draw cracks based on damage
      if (health <= 2) {
        canvas.drawLine(
          Offset(size.x * 0.2, size.y * 0.3),
          Offset(size.x * 0.6, size.y * 0.7),
          paint,
        );
      }
      if (health <= 1) {
        canvas.drawLine(
          Offset(size.x * 0.7, size.y * 0.2),
          Offset(size.x * 0.3, size.y * 0.8),
          paint,
        );
      }
    }
  }
  
  void takeDamage() {
    if (health > 0) {
      health--;
    }
  }
  
  void restore() {
    health = maxHealth;
  }
  
  bool get isDestroyed => health <= 0;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Add hitbox for collision detection
    add(RectangleHitbox());
  }
  
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Check if collision is with a particle wave of the same color
    if (other is ParticleWave && other.color == baseColor && !isDestroyed) {
      takeDamage();
      
      // Trigger screen effects for shield hit
      final game = findParent<AvoidanceGame>();
      game?.screenEffectsManager.triggerShieldHit();
      
      // Check if all shields are destroyed for game over
      game?.checkShieldGameOver();
      
      // The wave continues past the shield, so we don't remove it
    }
  }
}