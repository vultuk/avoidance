import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class Astronaut extends PositionComponent {
  static const double maxSpeed = 600.0; // pixels per second - increased for faster movement
  static const double friction = 0.95; // momentum friction - increased for more drifting
  static const double accelerationRate = 50.0; // acceleration multiplier for gyroscope input - increased for stronger thrust
  
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
    
    // Add a subtle glow to make astronaut visible
    add(CircleComponent(
      radius: size.x / 2,
      position: size / 2,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.cyan.withOpacity(0.2),
    ));
    
    // Scale components to new astronaut size (40px)
    final scale = size.x / 25; // Original was 25px
    
    // Main body (torso)
    body = RectangleComponent(
      size: Vector2(15, 18) * scale,
      position: Vector2(5, 4) * scale,
      paint: Paint()..color = Colors.white,
    );
    add(body);
    
    // Helmet (circular appearance)
    helmet = RectangleComponent(
      size: Vector2(12, 10) * scale,
      position: Vector2(6.5, 0) * scale,
      paint: Paint()..color = Colors.white.withOpacity(0.9),
    );
    add(helmet);
    
    // Visor (blue tint)
    visor = RectangleComponent(
      size: Vector2(8, 6) * scale,
      position: Vector2(8.5, 2) * scale,
      paint: Paint()..color = Colors.lightBlue.withOpacity(0.7),
    );
    add(visor);
    
    // Backpack (life support)
    backpack = RectangleComponent(
      size: Vector2(5, 10) * scale,
      position: Vector2(20, 7) * scale,
      paint: Paint()..color = Colors.grey[700]!,
    );
    add(backpack);
    
    // Arms (left and right)
    add(RectangleComponent(
      size: Vector2(3, 12) * scale,
      position: Vector2(2, 6) * scale,
      paint: Paint()..color = Colors.white,
    ));
    add(RectangleComponent(
      size: Vector2(3, 12) * scale,
      position: Vector2(20, 6) * scale,
      paint: Paint()..color = Colors.white,
    ));
    
    // Legs (left and right)
    add(RectangleComponent(
      size: Vector2(4, 8) * scale,
      position: Vector2(6, 17) * scale,
      paint: Paint()..color = Colors.white,
    ));
    add(RectangleComponent(
      size: Vector2(4, 8) * scale,
      position: Vector2(15, 17) * scale,
      paint: Paint()..color = Colors.white,
    ));
    
    // No collision detection - astronaut is just visual
  }

  void updateTargetVelocity(double x, double y) {
    // x and y are gyroscope values typically between -1 and 1
    // Apply acceleration to existing velocity for momentum-based movement
    Vector2 acceleration = Vector2(x, y) * accelerationRate;
    targetVelocity = acceleration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Add acceleration to velocity for true drifting
    velocity += targetVelocity * dt;
    
    // Apply friction
    velocity *= friction;
    
    // Clamp to max speed
    if (velocity.length > maxSpeed) {
      velocity = velocity.normalized() * maxSpeed;
    }
    
    // Update position
    position += velocity * dt;
  }
  
  bool isOffScreen(Vector2 gameSize) {
    // Check if astronaut is completely off screen
    return position.x < -size.x/2 || 
           position.x > gameSize.x + size.x/2 ||
           position.y < -size.y/2 || 
           position.y > gameSize.y + size.y/2;
  }
}