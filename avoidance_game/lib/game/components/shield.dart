import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class Shield extends PositionComponent {
  final bool isVertical;
  int health = 3;
  final int maxHealth = 3;
  
  Shield({
    required Vector2 position,
    required this.isVertical,
  }) : super(
    position: position,
    size: isVertical 
        ? Vector2(GameSizes.shieldWidth, GameSizes.shieldHeight)
        : Vector2(GameSizes.shieldHeight, GameSizes.shieldWidth),
    anchor: Anchor.center,
  );

  @override
  void render(Canvas canvas) {
    if (health <= 0) return;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Color based on health
    switch (health) {
      case 3:
        paint.color = GameColors.shieldGreen;
        break;
      case 2:
        paint.color = GameColors.shieldYellow;
        break;
      case 1:
        paint.color = GameColors.shieldRed;
        break;
    }
    
    // Draw curved shield shape
    final path = Path();
    
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
}