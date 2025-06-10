# Avoidance Game v1.0.1 - Critical Bug Fixes

## 🐛 Bug Fixes

This release fixes two critical gameplay issues that were reported in v1.0.0:

### Fixed Issues:
1. **Collision Detection**: Game now properly ends when the blue ship collides with a particle wave
2. **Wave Spawning**: Fixed issue where multiple waves could appear on screen simultaneously - now only one wave appears at a time as intended

### Technical Changes:
- Updated collision detection logic in BlueShip component to properly handle ParticleWave collisions
- Added wave tracking in WaveManager to ensure only one wave is active at any time
- Wave spawning now waits for the current wave to leave the screen before spawning the next one

## 🎮 Game Features (Unchanged)
- Easy Mode with blue ship and particle waves from top
- Touch controls - drag to move ship
- Progressive difficulty - wave speed increases 15% every 5 waves
- Real-time scoring - 1 point per second
- High score tracking
- Pause functionality
- Game over screen with retry option

## 📱 Installation:
1. Download the APK file: `avoidance-game-v1.0.1-bugfix.apk`
2. Enable "Install from Unknown Sources" in your Android settings
3. Open the APK file to install
4. Launch "Avoidance" from your app drawer

## 🔧 Technical Details:
- Built with Flutter & Flame game engine
- Minimum Android version: 6.0 (API 23)
- Target FPS: 60fps
- APK Size: ~20MB

## 🚀 Coming Next:
- Phase 2: Medium & Hard modes with dual ships and shield system
- Phase 3: Ultra mode with gyroscope controls and oxygen management

Thank you for testing and reporting the issues!