import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import '../../../utils/constants.dart';
import '../particle_wave.dart';
import '../shield.dart';
import '../shield_system.dart';
import '../../avoidance_game.dart';

class OrangeShip extends PositionComponent with CollisionCallbacks {
  final Vector2 gameSize;
  Shield? topShield;
  Shield? bottomShield;
  ShieldSystem? shieldSystem;
  
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
    
    // Add shields if in Medium, Hard, or Ultra mode
    final game = findParent<AvoidanceGame>();
    if (game != null && (game.difficulty == Difficulty.medium || game.difficulty == Difficulty.hard || game.difficulty == Difficulty.ultra)) {
      // Top shield (protects from blue waves)
      topShield = Shield(
        shieldPosition: ShieldPosition.top,
        baseColor: GameColors.blue,
      );
      // Position shield above ship with proper spacing
      // Ship has center anchor, so (0,0) is ship center
      // Top shield should be: -shipSize/2 - gap - shieldWidth/2
      final topShieldY = -(GameSizes.shipSize/2) - 8 - (GameSizes.shieldWidth/2);
      topShield!.position = Vector2(0, topShieldY);
      add(topShield!);
      
      // Bottom shield (protects from blue waves)
      bottomShield = Shield(
        shieldPosition: ShieldPosition.bottom,
        baseColor: GameColors.blue,
      );
      // Bottom shield should be: shipSize/2 + gap + shieldWidth/2
      final bottomShieldY = (GameSizes.shipSize/2) + 8 + (GameSizes.shieldWidth/2);
      bottomShield!.position = Vector2(0, bottomShieldY);
      add(bottomShield!);
      
      // Create shield system linking both shields
      shieldSystem = ShieldSystem(
        shields: [topShield!, bottomShield!],
        waveColor: GameColors.blue,
      );
      
      // Set up callbacks for wave hits
      topShield!.onWaveHit = (wave) => shieldSystem!.takeDamageFromWave(wave);
      bottomShield!.onWaveHit = (wave) => shieldSystem!.takeDamageFromWave(wave);
    }
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

  // Drag handling removed - now handled by AvoidanceGame's multi-touch system
  
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
      // Orange ship only collides with orange waves (from left)
      if (other.color == GameColors.orange) {
        final game = findParent<AvoidanceGame>();
        if (game != null) {
          game.gameOver();
        }
      }
    }
  }
}