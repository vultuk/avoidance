import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

enum WaveDirection { fromTop, fromLeft }

class ParticleWave extends PositionComponent {
  final Color color;
  final WaveDirection direction;
  final double speed;
  final double gapPosition;
  final double gapSize;
  final Vector2 gameSize;
  
  ParticleWave({
    required this.color,
    required this.direction,
    required this.speed,
    required this.gapPosition,
    required this.gapSize,
    required this.gameSize,
  }) : super(
    position: _getInitialPosition(direction, gameSize),
    size: _getWaveSize(direction, gameSize),
    anchor: Anchor.topLeft,
  );

  static Vector2 _getInitialPosition(WaveDirection direction, Vector2 gameSize) {
    switch (direction) {
      case WaveDirection.fromTop:
        return Vector2(0, -GameSizes.waveThickness);
      case WaveDirection.fromLeft:
        return Vector2(-GameSizes.waveThickness, 0);
    }
  }

  static Vector2 _getWaveSize(WaveDirection direction, Vector2 gameSize) {
    switch (direction) {
      case WaveDirection.fromTop:
        return Vector2(gameSize.x, GameSizes.waveThickness);
      case WaveDirection.fromLeft:
        return Vector2(GameSizes.waveThickness, gameSize.y);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add collision boxes for the wave segments (excluding the gap)
    if (direction == WaveDirection.fromTop) {
      // Left segment
      if (gapPosition > 0) {
        add(RectangleHitbox(
          position: Vector2.zero(),
          size: Vector2(gapPosition, size.y),
        ));
      }
      
      // Right segment
      final rightStart = gapPosition + gapSize;
      if (rightStart < size.x) {
        add(RectangleHitbox(
          position: Vector2(rightStart, 0),
          size: Vector2(size.x - rightStart, size.y),
        ));
      }
    } else {
      // Top segment
      if (gapPosition > 0) {
        add(RectangleHitbox(
          position: Vector2.zero(),
          size: Vector2(size.x, gapPosition),
        ));
      }
      
      // Bottom segment
      final bottomStart = gapPosition + gapSize;
      if (bottomStart < size.y) {
        add(RectangleHitbox(
          position: Vector2(0, bottomStart),
          size: Vector2(size.x, size.y - bottomStart),
        ));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw particle wave with gap
    if (direction == WaveDirection.fromTop) {
      // Draw left segment
      if (gapPosition > 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, gapPosition, size.y),
          paint,
        );
      }
      
      // Draw right segment
      final rightStart = gapPosition + gapSize;
      if (rightStart < size.x) {
        canvas.drawRect(
          Rect.fromLTWH(rightStart, 0, size.x - rightStart, size.y),
          paint,
        );
      }
      
      // Add particle effect
      _drawParticles(canvas, paint);
    } else {
      // Draw top segment
      if (gapPosition > 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, 0, size.x, gapPosition),
          paint,
        );
      }
      
      // Draw bottom segment
      final bottomStart = gapPosition + gapSize;
      if (bottomStart < size.y) {
        canvas.drawRect(
          Rect.fromLTWH(0, bottomStart, size.x, size.y - bottomStart),
          paint,
        );
      }
      
      // Add particle effect
      _drawParticles(canvas, paint);
    }
  }

  void _drawParticles(Canvas canvas, Paint paint) {
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    paint.color = color.withOpacity(0.6);
    
    // Draw small particles for texture
    for (int i = 0; i < 20; i++) {
      final particleX = random.nextDouble() * size.x;
      final particleY = random.nextDouble() * size.y;
      final particleSize = random.nextDouble() * 3 + 1;
      
      // Skip particles in the gap
      if (direction == WaveDirection.fromTop) {
        if (particleX >= gapPosition && particleX <= gapPosition + gapSize) {
          continue;
        }
      } else {
        if (particleY >= gapPosition && particleY <= gapPosition + gapSize) {
          continue;
        }
      }
      
      canvas.drawCircle(
        Offset(particleX, particleY),
        particleSize,
        paint,
      );
    }
  }

  @override
  void update(double dt) {
    // Move the wave
    if (direction == WaveDirection.fromTop) {
      position.y += speed * dt;
      
      // Remove when off screen
      if (position.y > gameSize.y) {
        removeFromParent();
      }
    } else {
      position.x += speed * dt;
      
      // Remove when off screen
      if (position.x > gameSize.x) {
        removeFromParent();
      }
    }
  }

  static double generateGapPosition(Vector2 gameSize, double gapSize, WaveDirection direction) {
    final random = Random();
    final maxPosition = direction == WaveDirection.fromTop 
        ? gameSize.x - gapSize 
        : gameSize.y - gapSize;
    
    return random.nextDouble() * maxPosition;
  }
}