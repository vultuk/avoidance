# Avoidance \- Complete Game Design Document

## Game Overview

**Platform**: iOS and Android (phones and tablets)  
**Orientation**: Landscape  
**Art Style**: Pixel art  
**Genre**: Endless survival/avoidance  
**Price**: Free (no ads, no IAP)

## Core Mechanics

### Scoring System

- **Base Score**: 1 point per second survived  
- **Difficulty Multipliers**:  
  - Easy: 1x  
  - Medium: 2x  
  - Hard: 3x  
  - Ultra: 5x  
- Score displays in real-time at top center of screen

### Wave Mechanics

- **Wave Speed Progression**: Every 5 waves, speed increases by 15%  
- **Wave Thickness**: 40 pixels  
- **Gap Size**:  
  - Easy: Ship width \+ 30%  
  - Medium/Hard/Ultra: Ship width \+ 20%  
- **Wave Frequency**: 1 wave every 2 seconds (base speed)

### Power-Up System (Hard & Ultra modes)

- **Spawn Rate**: After every 4th particle wave  
- **Entry**: Floats in from top of screen at 50% of wave speed  
- **Size**: 30x30 pixels with pulsing glow effect  
- **Collection**: Instant use, restores shields/oxygen to 100%

## Difficulty Modes

### Easy Mode

- Single blue ship (30x30 pixels)  
- Blue particle waves from top only  
- Touch to drag ship, release to hold position  
- Game over on particle collision

### Medium Mode

- Blue ship \+ Orange ship (both 30x30 pixels)  
- Blue waves from top, orange waves from left  
- Visual indicators:  
  - Blue ship: Orange shield sprites on left/right sides  
  - Orange ship: Blue shield sprites on top/bottom sides  
- Ships can be controlled simultaneously (multi-touch)  
- Game over if either ship hits matching color particles

### Hard Mode

- Same as Medium plus:  
- Shield System:  
  - Each shield has 3 hit points  
  - Visual degradation: 100% opacity → 66% → 33% → destroyed  
  - Shield hit \= screen shake \+ flash effect  
  - Ships can pass through opposite-color gaps safely  
- Power-ups restore all shields to full

### Ultra Mode

- Same as Hard plus:  
- Astronaut Character (25x25 pixels):  
  - Controlled via gyroscope tilt  
  - Floats with momentum (max speed: 200 pixels/second)  
  - Oxygen bar (100 units, depletes 1 unit/second)  
  - Death on screen edge collision or oxygen depletion  
  - Priority for power-up collection over ships

## Visual Specifications

### Color Palette

- Background: Deep space black (\#0A0A0A) with star field  
- Blue elements: \#00A2FF  
- Orange elements: \#FF6A00  
- Power-ups: Pulsing green (\#00FF00)  
- UI Text: White (\#FFFFFF)  
- Shields: Semi-transparent overlays of protective color

### Sprite Requirements

- Blue ship: 30x30px arrow shape  
- Orange ship: 30x30px arrow shape (rotated 90°)  
- Astronaut: 25x25px humanoid figure  
- Shield sprites: 15x30px curved barriers  
- Power-up box: 30x30px glowing cube  
- Particle waves: Repeating 40px tall pattern with gaps

## UI/UX Design

### Main Menu

- Title: "AVOIDANCE" in pixel font  
- Four difficulty buttons: \[EASY\] \[MEDIUM\] \[HARD\] \[ULTRA\]  
- \[HIGH SCORES\] button  
- \[SHARE\] button  
- Simple space background with floating particles

### In-Game HUD

- Score (top center)  
- Pause button (top right corner)  
- Shield indicators (near each ship in Hard/Ultra)  
- Oxygen bar (bottom center in Ultra mode)

### Game Over Screen

- "GAME OVER" title  
- Final score with difficulty mode  
- Personal best score  
- \[RETRY\] \[MENU\] \[SHARE\] buttons

## Control Schemes

### Touch Controls

- Ships: Direct finger tracking, no offset  
- Multi-touch support for controlling both ships  
- Pause: Tap pause button or use system back button

### Gyroscope (Ultra mode)

- Tilt sensitivity: Adjustable in settings  
- Calibration on mode start  
- Dead zone: ±5 degrees from neutral

## Audio Design

- Background: Ambient space music (loopable)  
- SFX:  
  - Wave approach warning (subtle beep)  
  - Shield hit (energy discharge)  
  - Power-up collection (positive chime)  
  - Ship destruction (explosion)  
  - Oxygen warning (below 20%)

## Social Features

- **Personal Leaderboard**: Top 10 scores per difficulty  
- **Share Functionality**:  
  - Screenshot of final score  
  - Pre-filled text: "I survived \[X\] seconds on \[DIFFICULTY\] mode in Avoidance\! Can you beat my score?"  
  - Share to standard iOS/Android share sheets

## Implementation Technology

### Framework: Flutter \+ Flame Engine

**Language**: Dart  
**Game Engine**: Flame 1.10.0+  
**Development**: 100% code-based (no visual editors required)

### Key Benefits:

- **Single Codebase**: Write once, deploy to both iOS and Android natively  
- **Native Performance**: Compiles to native ARM code  
- **Hot Reload**: Instant preview of changes during development  
- **Small App Size**: \~5-10MB final build  
- **Free & Open Source**: No licensing costs

### Project Structure:

```
avoidance_game/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── game/
│   │   ├── avoidance_game.dart   # Main game class
│   │   ├── components/
│   │   │   ├── ships/
│   │   │   │   ├── blue_ship.dart
│   │   │   │   └── orange_ship.dart
│   │   │   ├── astronaut.dart
│   │   │   ├── particle_wave.dart
│   │   │   └── power_up.dart
│   │   ├── managers/
│   │   │   ├── wave_manager.dart
│   │   │   └── score_manager.dart
│   │   └── screens/
│   │       ├── menu_screen.dart
│   │       └── game_over_screen.dart
│   └── utils/
│       ├── constants.dart        # Colors, sizes, speeds
│       └── storage.dart          # High score persistence
├── assets/
│   ├── images/                   # Pixel art sprites
│   └── audio/                    # Sound effects
└── pubspec.yaml                  # Dependencies
```

### Core Dependencies:

```
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.10.0          # Game engine
  sensors_plus: ^3.0.0    # Gyroscope access
  shared_preferences: ^2.2.0  # Local storage
  share_plus: ^7.0.0      # Social sharing
```

### Development Setup:

1. Install Flutter SDK (free from flutter.dev)  
2. Create new project: `flutter create avoidance_game`  
3. Add Flame dependency  
4. Code in VS Code or Android Studio  
5. Test with: `flutter run`  
6. Build releases:  
   - Android: `flutter build apk --release`  
   - iOS: `flutter build ios --release`

## Development Priorities

### Phase 1 \- Core Game

1. Easy mode implementation  
2. Basic UI and menu system  
3. Score tracking

### Phase 2 \- Expanded Gameplay

1. Medium and Hard modes  
2. Power-up system  
3. Visual polish and effects

### Phase 3 \- Advanced Features

1. Ultra mode with gyroscope  
2. Audio implementation  
3. Social sharing  
4. Performance optimization

## Technical Specifications

- **Target FPS**: 60fps on mid-range devices  
- **Min OS**: iOS 12.0 / Android 6.0  
- **Orientation Lock**: Landscape only  
- **Save System**: Local storage for high scores using SharedPreferences  
- **Analytics**: Basic play session tracking (optional)  
- **Build Output**: Native apps for Google Play Store and Apple App Store
