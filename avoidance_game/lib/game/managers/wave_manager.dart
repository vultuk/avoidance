import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../components/particle_wave.dart';
import '../avoidance_game.dart';

class WaveManager extends Component with HasGameRef<AvoidanceGame> {
  final Vector2 gameSize;
  final Difficulty difficulty;
  final double shipWidth;
  
  double _timeSinceLastWave = 0;
  double _currentWaveSpeed = GameConstants.baseWaveSpeed;
  int _waveCount = 0;
  int _wavesSinceLastPowerUp = 0;
  ParticleWave? _currentWave;
  
  WaveManager({
    required this.gameSize,
    required this.difficulty,
    required this.shipWidth,
  });

  @override
  void update(double dt) {
    if (gameRef.isGameOver || gameRef.isPaused) return;
    
    // Check if current wave is still on screen
    if (_currentWave != null && _currentWave!.isMounted) {
      // For Easy mode, check if wave has moved off screen
      if (difficulty == Difficulty.easy) {
        if (_currentWave!.position.y > gameSize.y) {
          _currentWave = null;
        }
      }
      // Don't spawn new wave if current wave is still active
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
        _spawnBlueWaveFromTop(gapSize);
        break;
        
      case Difficulty.medium:
      case Difficulty.hard:
      case Difficulty.ultra:
        // Alternate between blue waves from top and orange waves from left
        if (_waveCount % 2 == 0) {
          _spawnBlueWaveFromTop(gapSize);
        } else {
          _spawnOrangeWaveFromLeft(gapSize);
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
    
    _currentWave = wave;
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
    
    _currentWave = wave;
    gameRef.add(wave);
  }

  void _spawnPowerUp() {
    // TODO: Implement power-up spawning for Hard and Ultra modes
  }
}