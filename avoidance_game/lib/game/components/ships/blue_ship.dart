import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../particle_wave.dart';
import '../shield.dart';
import '../shield_system.dart';
import '../../avoidance_game.dart';

class BlueShip extends PositionComponent with CollisionCallbacks {
  final Vector2 gameSize;
  Shield? leftShield;
  Shield? rightShield;
  ShieldSystem? shieldSystem;
  
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
    
    // Add shields if in Medium, Hard, or Ultra mode
    final game = findParent<AvoidanceGame>();
    if (game != null && (game.difficulty == Difficulty.medium || game.difficulty == Difficulty.hard || game.difficulty == Difficulty.ultra)) {
      // Left shield (protects from orange waves)
      leftShield = Shield(
        shieldPosition: ShieldPosition.left,
        baseColor: GameColors.orange,
      );
      // Position shield to the left of ship with proper spacing
      // Ship has center anchor, so (0,0) is ship center
      // Left shield should be: -shipSize/2 - gap - shieldWidth/2
      final leftShieldX = -(GameSizes.shipSize/2) - 8 - (GameSizes.shieldWidth/2);
      leftShield!.position = Vector2(leftShieldX, 0);
      add(leftShield!);
      
      // Right shield (protects from orange waves)
      rightShield = Shield(
        shieldPosition: ShieldPosition.right,
        baseColor: GameColors.orange,
      );
      // Right shield should be: shipSize/2 + gap + shieldWidth/2
      final rightShieldX = (GameSizes.shipSize/2) + 8 + (GameSizes.shieldWidth/2);
      rightShield!.position = Vector2(rightShieldX, 0);
      add(rightShield!);
      
      // Create shield system linking both shields
      shieldSystem = ShieldSystem(
        shields: [leftShield!, rightShield!],
        waveColor: GameColors.orange,
      );
      
      // Set up callbacks for wave hits
      leftShield!.onWaveHit = (wave) => shieldSystem!.takeDamageFromWave(wave);
      rightShield!.onWaveHit = (wave) => shieldSystem!.takeDamageFromWave(wave);
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

  // Drag handling is now managed by AvoidanceGame's multi-touch system for all modes
  
  @override
  void update(double dt) {
    super.update(dt);
    // Clean up processed waves periodically
    shieldSystem?.clearProcessedWaves();
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