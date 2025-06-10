import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../avoidance_game.dart';
import 'particle_wave.dart';
import 'power_up.dart';

class Astronaut extends PositionComponent with CollisionCallbacks, HasGameRef<AvoidanceGame> {
  static const double maxSpeed = 200.0; // pixels per second
  static const double friction = 0.85; // momentum friction
  static const double accelerationRate = 15.0; // acceleration multiplier for gyroscope input
  
  late RectangleComponent body;
  late RectangleComponent helmet;
  late RectangleComponent visor;
  late RectangleComponent backpack;
  
  Vector2 velocity = Vector2.zero();
  Vector2 targetVelocity = Vector2.zero();
  
  Astronaut({
    required Vector2 position,
  }) : super(
    position: position,
    size: Vector2(GameSizes.astronautSize, GameSizes.astronautSize),
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Main body (torso)
    body = RectangleComponent(
      size: Vector2(15, 18),
      position: Vector2(5, 4),
      paint: Paint()..color = Colors.white,
    );
    add(body);
    
    // Helmet (circular appearance)
    helmet = RectangleComponent(
      size: Vector2(12, 10),
      position: Vector2(6.5, 0),
      paint: Paint()..color = Colors.white.withOpacity(0.9),
    );
    add(helmet);
    
    // Visor (blue tint)
    visor = RectangleComponent(
      size: Vector2(8, 6),
      position: Vector2(8.5, 2),
      paint: Paint()..color = Colors.lightBlue.withOpacity(0.7),
    );
    add(visor);
    
    // Backpack (life support)
    backpack = RectangleComponent(
      size: Vector2(5, 10),
      position: Vector2(20, 7),
      paint: Paint()..color = Colors.grey[700]!,
    );
    add(backpack);
    
    // Arms (left and right)
    add(RectangleComponent(
      size: Vector2(3, 12),
      position: Vector2(2, 6),
      paint: Paint()..color = Colors.white,
    ));
    add(RectangleComponent(
      size: Vector2(3, 12),
      position: Vector2(20, 6),
      paint: Paint()..color = Colors.white,
    ));
    
    // Legs (left and right)
    add(RectangleComponent(
      size: Vector2(4, 8),
      position: Vector2(6, 17),
      paint: Paint()..color = Colors.white,
    ));
    add(RectangleComponent(
      size: Vector2(4, 8),
      position: Vector2(15, 17),
      paint: Paint()..color = Colors.white,
    ));
    
    // Add collision detection
    add(RectangleHitbox());
  }

  void updateTargetVelocity(double x, double y) {
    // x and y are gyroscope values typically between -1 and 1
    // Apply acceleration rate and clamp to max speed
    targetVelocity = Vector2(x, y) * accelerationRate;
    
    // Clamp to max speed
    if (targetVelocity.length > maxSpeed) {
      targetVelocity = targetVelocity.normalized() * maxSpeed;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Apply momentum-based movement
    velocity = velocity * friction + targetVelocity * (1 - friction);
    
    // Update position
    position += velocity * dt;
    
    // Keep astronaut within screen bounds
    final gameSize = gameRef.size;
    position.x = position.x.clamp(size.x / 2, gameSize.x - size.x / 2);
    position.y = position.y.clamp(size.y / 2, gameSize.y - size.y / 2);
    
    // If we hit the edge, reduce velocity in that direction
    if (position.x <= size.x / 2 || position.x >= gameSize.x - size.x / 2) {
      velocity.x *= 0.3; // Dampen horizontal velocity
    }
    if (position.y <= size.y / 2 || position.y >= gameSize.y - size.y / 2) {
      velocity.y *= 0.3; // Dampen vertical velocity
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    if (other is ParticleWave) {
      // Astronaut collides with both color waves
      final game = findParent<AvoidanceGame>();
      if (game != null) {
        game.gameOver();
      }
    } else if (other is PowerUp) {
      // Let the PowerUp handle the collision
    }
  }
}