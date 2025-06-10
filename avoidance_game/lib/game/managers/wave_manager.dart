import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../components/particle_wave.dart';
import '../components/power_up.dart';
import '../avoidance_game.dart';

class WaveManager extends Component with HasGameRef<AvoidanceGame> {
  final Vector2 gameSize;
  final Difficulty difficulty;
  final double shipWidth;
  
  double _timeSinceLastWave = 0;
  double _currentWaveSpeed = GameConstants.baseWaveSpeed;
  int _waveCount = 0;
  int _wavesSinceLastPowerUp = 0;
  ParticleWave? _currentBlueWave;
  ParticleWave? _currentOrangeWave;
  
  WaveManager({
    required this.gameSize,
    required this.difficulty,
    required this.shipWidth,
  });

  @override
  void update(double dt) {
    if (gameRef.isGameOver || gameRef.isPaused) return;
    
    // Check if blue wave has moved off screen or been removed
    if (_currentBlueWave != null) {
      if (!_currentBlueWave!.isMounted || _currentBlueWave!.position.y > gameSize.y) {
        _currentBlueWave = null;
      }
    }
    
    // Check if orange wave has moved off screen or been removed
    if (_currentOrangeWave != null) {
      if (!_currentOrangeWave!.isMounted || _currentOrangeWave!.position.x > gameSize.x) {
        _currentOrangeWave = null;
      }
    }
    
    // For Easy mode, only spawn if no blue wave is active
    if (difficulty == Difficulty.easy && _currentBlueWave != null) {
      return;
    }
    
    _timeSinceLastWave += dt;
    
    // Check if it's time to spawn a new wave
    if (_timeSinceLastWave >= GameConstants.waveFrequency) {
      _spawnWave();
      _timeSinceLastWave = 0;
      _waveCount++;
      
      // Increase wave speed every N waves
      if (_waveCount % GameConstants.wavesPerSpeedIncrease == 0) {
        _currentWaveSpeed *= (1 + GameConstants.waveSpeedIncreaseRate);
      }
      
      // Check if it's time to spawn a power-up (for Hard and Ultra modes)
      if ((difficulty == Difficulty.hard || difficulty == Difficulty.ultra) &&
          _wavesSinceLastPowerUp >= GameConstants.wavesPerPowerUp) {
        _spawnPowerUp();
        _wavesSinceLastPowerUp = 0;
      }
    }
  }

  void _spawnWave() {
    // Calculate gap size based on difficulty
    final gapSize = shipWidth * difficulty.gapMultiplier;
    
    // Generate wave based on difficulty
    switch (difficulty) {
      case Difficulty.easy:
        if (_currentBlueWave == null) {
          _spawnBlueWaveFromTop(gapSize);
        }
        break;
        
      case Difficulty.medium:
      case Difficulty.hard:
      case Difficulty.ultra:
        // For Medium+ modes, spawn blue and orange waves independently
        // Alternate between them, but allow both to be on screen
        if (_waveCount % 2 == 0) {
          if (_currentBlueWave == null) {
            _spawnBlueWaveFromTop(gapSize);
          }
        } else {
          if (_currentOrangeWave == null) {
            _spawnOrangeWaveFromLeft(gapSize);
          }
        }
        break;
    }
    
    _wavesSinceLastPowerUp++;
  }

  void _spawnBlueWaveFromTop(double gapSize) {
    final gapPosition = ParticleWave.generateGapPosition(
      gameSize, 
      gapSize, 
      WaveDirection.fromTop,
    );
    
    final wave = ParticleWave(
      color: GameColors.blue,
      direction: WaveDirection.fromTop,
      speed: _currentWaveSpeed,
      gapPosition: gapPosition,
      gapSize: gapSize,
      gameSize: gameSize,
    );
    
    _currentBlueWave = wave;
    gameRef.add(wave);
  }

  void _spawnOrangeWaveFromLeft(double gapSize) {
    final gapPosition = ParticleWave.generateGapPosition(
      gameSize, 
      gapSize, 
      WaveDirection.fromLeft,
    );
    
    final wave = ParticleWave(
      color: GameColors.orange,
      direction: WaveDirection.fromLeft,
      speed: _currentWaveSpeed,
      gapPosition: gapPosition,
      gapSize: gapSize,
      gameSize: gameSize,
    );
    
    _currentOrangeWave = wave;
    gameRef.add(wave);
  }

  void _spawnPowerUp() {
    // Spawn power-up in the center of the screen
    final powerUp = PowerUp(
      position: Vector2(gameSize.x / 2, -GameSizes.powerUpSize),
      gameSize: gameSize,
      speed: _currentWaveSpeed * GameConstants.powerUpSpeed,
    );
    
    gameRef.add(powerUp);
  }
}