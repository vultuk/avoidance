import 'package:flutter/material.dart';

class GameColors {
  static const Color background = Color(0xFF0A0A0A);
  static const Color blue = Color(0xFF00A2FF);
  static const Color orange = Color(0xFFFF6A00);
  static const Color powerUpGreen = Color(0xFF00FF00);
  static const Color uiText = Color(0xFFFFFFFF);
  
  // Shield colors
  static const Color shieldGreen = Color(0xFF00FF00);
  static const Color shieldYellow = Color(0xFFFFFF00);
  static const Color shieldRed = Color(0xFFFF0000);
}

class GameSizes {
  // Ship dimensions
  static const double shipSize = 30.0;
  static const double astronautSize = 25.0;
  
  // Shield dimensions
  static const double shieldWidth = 15.0;
  static const double shieldHeight = 30.0;
  
  // Wave properties
  static const double waveThickness = 40.0;
  
  // Power-up
  static const double powerUpSize = 30.0;
  
  // UI elements
  static const double buttonHeight = 50.0;
  static const double buttonWidth = 150.0;
  static const double fontSize = 20.0;
  static const double titleFontSize = 36.0;
}

class GameConstants {
  // Scoring
  static const int baseScorePerSecond = 1;
  static const int easyMultiplier = 1;
  static const int mediumMultiplier = 2;
  static const int hardMultiplier = 3;
  static const int ultraMultiplier = 5;
  
  // Wave properties
  static const double baseWaveSpeed = 100.0; // pixels per second
  static const double waveSpeedIncreaseRate = 0.15; // 15% increase
  static const int wavesPerSpeedIncrease = 5;
  static const double waveFrequency = 2.0; // seconds between waves
  
  // Gap sizes (multiplier of ship width)
  static const double easyGapMultiplier = 1.3; // Ship width + 30%
  static const double normalGapMultiplier = 1.2; // Ship width + 20%
  
  // Power-ups
  static const int wavesPerPowerUp = 4;
  static const double powerUpSpeed = 0.5; // 50% of wave speed
  
  // Shield system
  static const int maxShieldHp = 3;
  
  // Oxygen system (Ultra mode)
  static const double maxOxygen = 100.0;
  static const double oxygenDepletionRate = 1.0; // units per second
  static const double oxygenWarningThreshold = 20.0;
  
  // Astronaut movement (Ultra mode)
  static const double astronautMaxSpeed = 200.0; // pixels per second
  static const double gyroscopeDeadZone = 5.0; // degrees
  
  // Animation durations
  static const Duration screenShakeDuration = Duration(milliseconds: 300);
  static const Duration flashDuration = Duration(milliseconds: 200);
  static const Duration powerUpPulseDuration = Duration(seconds: 1);
}

enum Difficulty {
  easy,
  medium,
  hard,
  ultra,
}

extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'EASY';
      case Difficulty.medium:
        return 'MEDIUM';
      case Difficulty.hard:
        return 'HARD';
      case Difficulty.ultra:
        return 'ULTRA';
    }
  }
  
  int get scoreMultiplier {
    switch (this) {
      case Difficulty.easy:
        return GameConstants.easyMultiplier;
      case Difficulty.medium:
        return GameConstants.mediumMultiplier;
      case Difficulty.hard:
        return GameConstants.hardMultiplier;
      case Difficulty.ultra:
        return GameConstants.ultraMultiplier;
    }
  }
  
  double get gapMultiplier {
    switch (this) {
      case Difficulty.easy:
        return GameConstants.easyGapMultiplier;
      case Difficulty.medium:
      case Difficulty.hard:
      case Difficulty.ultra:
        return GameConstants.normalGapMultiplier;
    }
  }
}