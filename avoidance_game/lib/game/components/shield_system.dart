import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'shield.dart';
import 'particle_wave.dart';

class ShieldSystem {
  final List<Shield> shields;
  final Color waveColor; // Color of the wave this system protects from
  int _currentHealth = 3;
  final int maxHealth = 3;
  
  // Track which waves have already damaged this shield system
  final Set<ParticleWave> _processedWaves = {};
  
  ShieldSystem({
    required this.shields,
    required this.waveColor,
  });
  
  int get currentHealth => _currentHealth;
  
  bool get isDestroyed => _currentHealth <= 0;
  
  void takeDamageFromWave(ParticleWave wave) {
    // Only take damage once per wave
    if (_processedWaves.contains(wave)) {
      return;
    }
    
    if (_currentHealth > 0) {
      _currentHealth--;
      _processedWaves.add(wave);
      
      // Update all shields in the system
      for (final shield in shields) {
        shield.health = _currentHealth;
      }
    }
  }
  
  void restore() {
    _currentHealth = maxHealth;
    _processedWaves.clear();
    
    for (final shield in shields) {
      shield.restore();
    }
  }
  
  void clearProcessedWaves() {
    // Remove waves that are no longer active
    _processedWaves.removeWhere((wave) => !wave.isMounted);
  }
}