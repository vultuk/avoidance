# Avoidance Game Development Guide

## Project Overview
Building a pixel art endless survival/avoidance game using Flutter and Flame engine for iOS and Android.

## Key Technical Details
- **Framework**: Flutter + Flame 1.10.0+
- **Language**: Dart
- **Orientation**: Landscape only
- **Target FPS**: 60fps
- **Art Style**: Pixel art
- **Platform**: iOS 12.0+ / Android 6.0+

## Core Game Mechanics

### Difficulty Modes
1. **Easy**: Single blue ship, blue waves from top
2. **Medium**: Blue + Orange ships, waves from top/left
3. **Hard**: Medium + shield system (3 HP) + power-ups
4. **Ultra**: Hard + gyroscope-controlled astronaut with oxygen

### Scoring System
- Base: 1 point/second
- Multipliers: Easy(1x), Medium(2x), Hard(3x), Ultra(5x)

### Wave Mechanics
- Speed increases 15% every 5 waves
- Wave thickness: 40px
- Frequency: 1 wave/2 seconds

## Development Commands
```bash
# Create project
flutter create avoidance_game

# Run development
flutter run

# Build releases
flutter build apk --release    # Android
flutter build ios --release    # iOS

# Run tests
flutter test

# Analyze code
flutter analyze
```

## Project Structure
```
avoidance_game/
├── lib/
│   ├── main.dart
│   ├── game/
│   │   ├── avoidance_game.dart
│   │   ├── components/
│   │   ├── managers/
│   │   └── screens/
│   └── utils/
├── assets/
└── pubspec.yaml
```

## Key Dependencies
- flame: ^1.10.0 (game engine)
- sensors_plus: ^3.0.0 (gyroscope)
- shared_preferences: ^2.2.0 (storage)
- share_plus: ^7.0.0 (social sharing)

## Development Phases
1. **Phase 1**: Easy mode + UI + scoring
2. **Phase 2**: Medium/Hard modes + power-ups
3. **Phase 3**: Ultra mode + audio + social features

## Important Technical Notes
- Use Flame's Component system for game objects
- Implement collision detection with Flame's built-in systems
- Store high scores locally with SharedPreferences
- Test multi-touch thoroughly for Medium+ modes
- Optimize sprite rendering for 60fps performance

## EXTREMELY IMPORTANT: Version Control Process
**YOU MUST ALWAYS FOLLOW THIS PROCESS - NEVER FORGET!**

After making any changes to the game:
1. **Update @prompts.md** - Add ALL user prompts from the conversation
2. **Commit** - Create a descriptive commit with all changes
3. **Version** - Create a new version tag (e.g., v1.0.0-alpha.X)
4. **Push** - Push both commits and tags to the repository

This process is MANDATORY and must be performed EVERY TIME changes are made. The @prompts.md file serves as a complete history of user requests and must be kept up to date.