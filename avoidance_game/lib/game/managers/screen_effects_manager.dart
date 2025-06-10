import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../avoidance_game.dart';

class ScreenEffectsManager extends Component with HasGameRef<AvoidanceGame> {
  // Screen shake properties
  double _shakeIntensity = 0;
  double _shakeDuration = 0;
  double _shakeTimer = 0;
  final math.Random _random = math.Random();
  Vector2 _originalCameraPosition = Vector2.zero();
  
  // Flash effect properties
  double _flashOpacity = 0;
  double _flashDuration = 0;
  double _flashTimer = 0;
  Color _flashColor = Colors.white;
  
  // Flash overlay component
  late RectangleComponent _flashOverlay;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Create flash overlay
    _flashOverlay = RectangleComponent(
      size: gameRef.size,
      paint: Paint()..color = Colors.transparent,
      priority: 100, // High priority to render on top
    );
    gameRef.add(_flashOverlay);
    
    // Store original camera position
    _originalCameraPosition = gameRef.camera.viewfinder.position.clone();
  }
  
  void triggerShieldHit() {
    // Trigger both shake and flash effects
    triggerScreenShake(intensity: 8.0, duration: 0.3);
    triggerFlash(color: Colors.white, duration: 0.1);
  }
  
  void triggerScreenShake({
    required double intensity,
    required double duration,
  }) {
    _shakeIntensity = intensity;
    _shakeDuration = duration;
    _shakeTimer = 0;
  }
  
  void triggerFlash({
    required Color color,
    required double duration,
    double opacity = 0.5,
  }) {
    _flashColor = color;
    _flashDuration = duration;
    _flashTimer = 0;
    _flashOpacity = opacity;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update screen shake
    if (_shakeTimer < _shakeDuration) {
      _shakeTimer += dt;
      
      // Calculate shake offset
      final progress = _shakeTimer / _shakeDuration;
      final currentIntensity = _shakeIntensity * (1 - progress); // Fade out
      
      final offsetX = (_random.nextDouble() - 0.5) * 2 * currentIntensity;
      final offsetY = (_random.nextDouble() - 0.5) * 2 * currentIntensity;
      
      // Apply shake to camera
      gameRef.camera.viewfinder.position = _originalCameraPosition + Vector2(offsetX, offsetY);
    } else if (_shakeTimer >= _shakeDuration && _shakeIntensity > 0) {
      // Reset camera position
      gameRef.camera.viewfinder.position = _originalCameraPosition.clone();
      _shakeIntensity = 0;
    }
    
    // Update flash effect
    if (_flashTimer < _flashDuration) {
      _flashTimer += dt;
      
      // Calculate flash opacity (fade out)
      final progress = _flashTimer / _flashDuration;
      final currentOpacity = _flashOpacity * (1 - progress);
      
      _flashOverlay.paint.color = _flashColor.withOpacity(currentOpacity);
    } else if (_flashTimer >= _flashDuration && _flashOpacity > 0) {
      // Clear flash
      _flashOverlay.paint.color = Colors.transparent;
      _flashOpacity = 0;
    }
  }
  
  @override
  void onRemove() {
    // Clean up flash overlay
    _flashOverlay.removeFromParent();
    super.onRemove();
  }
}