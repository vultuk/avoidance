# Avoidance Game Development Todo List

## Phase 1: Core Game Foundation (Easy Mode)

### High Priority - Initial Setup
- [x] Setup Flutter development environment and create new project 'avoidance_game'
- [x] Add core dependencies (flame, sensors_plus, shared_preferences, share_plus) to pubspec.yaml
- [x] Create project directory structure (lib/game/, components/, managers/, screens/, utils/)
- [x] Implement main.dart entry point with landscape orientation lock
- [x] Create constants.dart with color palette, sizes, and game constants

### High Priority - Basic Game Implementation
- [x] Implement main menu screen with difficulty selection buttons
- [x] Create base AvoidanceGame class extending FlameGame
- [x] Implement blue_ship.dart component with touch-drag controls
- [x] Create particle_wave.dart component with gap generation logic
- [x] Implement wave_manager.dart for spawning waves from top with timing
- [x] Add collision detection between ship and particle waves
- [x] Implement score_manager.dart with real-time scoring (1 point/second)
- [x] Create game over screen with score display and retry/menu buttons
- [x] Implement storage.dart for high score persistence using SharedPreferences

### Medium Priority - Polish & Features
- [x] Add pause functionality with pause button in top-right corner
- [x] Implement wave speed progression (15% increase every 5 waves)
- [ ] Create pixel art sprites for blue ship (30x30px arrow shape)

### Low Priority - Visual Enhancements
- [x] Add star field background to all screens

### Testing
- [x] Test Easy mode gameplay for 60fps performance

## Phase 2: Expanded Gameplay (Medium & Hard Modes)

### Medium Priority - Medium Mode
- [x] Implement orange_ship.dart component (rotated 90°)
- [ ] Add multi-touch support for controlling both ships simultaneously
- [x] Modify wave_manager.dart to spawn orange waves from left
- [x] Create shield sprites (15x30px curved barriers) for visual indicators

### Medium Priority - Hard Mode
- [x] Implement shield system with 3 HP and visual degradation
- [ ] Add screen shake and flash effects for shield hits
- [x] Create power_up.dart component with pulsing green glow effect
- [x] Implement power-up spawning logic (after every 4th wave)
- [x] Add power-up collection mechanics (restore shields to 100%)

### Testing
- [ ] Test Medium and Hard modes thoroughly

## Phase 3: Advanced Features (Ultra Mode & Polish)

### Low Priority - Ultra Mode
- [x] Create astronaut.dart component (25x25px humanoid sprite)
- [x] Implement gyroscope controls with calibration and dead zone
- [x] Add momentum-based movement for astronaut (max 200px/s)
- [x] Implement oxygen system with depletion and UI bar
- [x] Add screen edge collision detection for astronaut
- [x] Implement power-up priority system for Ultra mode

### Low Priority - Audio
- [ ] Create ambient space music (loopable background track)
- [ ] Add sound effects (wave warning, shield hit, power-up, destruction, oxygen warning)

### Low Priority - Social Features
- [ ] Implement personal leaderboard (top 10 scores per difficulty)
- [ ] Add social sharing functionality with screenshot and pre-filled text

## Final Polish & Release

### High Priority - Optimization
- [ ] Optimize sprite rendering and collision detection for 60fps on mid-range devices

### Medium Priority - Quality Assurance
- [ ] Write comprehensive unit tests for game logic

### High Priority - Device Testing
- [ ] Perform device testing on various iOS and Android devices

### Low Priority - Release Preparation
- [ ] Build and prepare release APK for Google Play Store
- [ ] Build and prepare release IPA for Apple App Store

## Notes
- Items are organized by development phase and priority
- Complete Phase 1 before moving to Phase 2
- Each item can be checked off when completed
- High priority items are critical for basic functionality
- Medium priority items enhance gameplay
- Low priority items are nice-to-have features