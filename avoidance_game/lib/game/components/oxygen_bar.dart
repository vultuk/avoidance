import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class OxygenBar extends PositionComponent {
  double _currentOxygen = GameConstants.maxOxygen;
  late RectangleComponent background;
  late RectangleComponent oxygenFill;
  late TextComponent oxygenText;
  
  OxygenBar({required Vector2 position}) : super(
    position: position,
    size: Vector2(200, 30),
    anchor: Anchor.topCenter,
  );
  
  double get currentOxygen => _currentOxygen;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Background bar
    background = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.grey[800]!
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(background);
    
    // Oxygen fill
    oxygenFill = RectangleComponent(
      size: Vector2(size.x - 4, size.y - 4),
      position: Vector2(2, 2),
      paint: Paint()..color = Colors.lightBlue,
    );
    add(oxygenFill);
    
    // Oxygen text
    oxygenText = TextComponent(
      text: 'O₂: 100%',
      position: Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(oxygenText);
  }
  
  void updateOxygen(double amount) {
    _currentOxygen = (_currentOxygen + amount).clamp(0, GameConstants.maxOxygen);
    
    // Update fill width
    final fillPercentage = _currentOxygen / GameConstants.maxOxygen;
    oxygenFill.size.x = (size.x - 4) * fillPercentage;
    
    // Update color based on oxygen level
    if (_currentOxygen <= GameConstants.oxygenWarningThreshold) {
      oxygenFill.paint.color = Colors.red;
      // Flash effect for critical oxygen
      if (_currentOxygen <= 10) {
        oxygenFill.paint.color = DateTime.now().millisecondsSinceEpoch % 500 < 250
            ? Colors.red
            : Colors.orange;
      }
    } else if (_currentOxygen <= 50) {
      oxygenFill.paint.color = Colors.orange;
    } else {
      oxygenFill.paint.color = Colors.lightBlue;
    }
    
    // Update text
    oxygenText.text = 'O₂: ${_currentOxygen.toInt()}%';
  }
  
  void depleteOxygen(double dt) {
    updateOxygen(-GameConstants.oxygenDepletionRate * dt);
  }
  
  void refillOxygen() {
    updateOxygen(GameConstants.maxOxygen);
  }
  
  bool isOxygenDepleted() {
    return _currentOxygen <= 0;
  }
}