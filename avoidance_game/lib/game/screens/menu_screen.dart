import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../utils/constants.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _titleController;
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _subtitleController;
  late Animation<double> _titleScale;
  late Animation<double> _titleGlow;
  late Animation<double> _subtitleOpacity;
  late List<AnimationController> _buttonControllers;
  late List<Animation<double>> _buttonAnimations;
  
  Map<Difficulty, int> highScores = {};
  int _hoveredButtonIndex = -1;

  @override
  void initState() {
    super.initState();
    
    // Star field animation - slower to match game
    _starController = AnimationController(
      duration: const Duration(seconds: 120),
      vsync: this,
    )..repeat();
    
    // Title animation
    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _titleScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.elasticOut,
    ));
    
    _titleGlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeInOut,
    ));
    
    // Subtitle animation
    _subtitleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _subtitleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _subtitleController,
      curve: Curves.easeIn,
    ));
    
    // Float animation for decorative elements
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    // Button animations (3 buttons now: Start Game, Leaderboard, High Scores)
    _buttonControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: Duration(milliseconds: 400 + (index * 100)),
        vsync: this,
      ),
    );
    
    _buttonAnimations = _buttonControllers.map((controller) {
      return Tween<double>(
        begin: -1.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();
    
    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 1000), () {
      _subtitleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      for (var controller in _buttonControllers) {
        controller.forward();
      }
    });
    
    _loadHighScores();
  }

  Future<void> _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var difficulty in Difficulty.values) {
        highScores[difficulty] = prefs.getInt('highScore_${difficulty.name}') ?? 0;
      }
    });
  }

  @override
  void dispose() {
    _starController.dispose();
    _titleController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    _subtitleController.dispose();
    for (var controller in _buttonControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showDifficultySelection() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => _DifficultySelectionDialog(
        onDifficultySelected: (difficulty) {
          Navigator.of(context).pop();
          _startGame(difficulty);
        },
      ),
    );
  }

  void _startGame(Difficulty difficulty) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            GameScreen(difficulty: difficulty),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showHighScores() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => _HighScoresDialog(highScores: highScores),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: Stack(
        children: [
          // Enhanced gradient background
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  GameColors.background,
                  GameColors.background.withBlue(20),
                  GameColors.background.withBlue(10),
                ],
              ),
            ),
          ),
          
          // Animated star field background
          AnimatedBuilder(
            animation: _starController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: EnhancedStarFieldPainter(
                  animationValue: _starController.value,
                ),
              );
            },
          ),
          
          // Floating particles
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: FloatingParticlesPainter(
                  animationValue: _floatController.value,
                  pulseValue: _pulseController.value,
                ),
              );
            },
          ),
          
          // Vignette effect
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
          
          // Menu content
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 1),
                  
                  // Animated title with enhanced effects
                  AnimatedBuilder(
                    animation: _titleController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _titleScale.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Multiple glow layers
                              if (_titleGlow.value > 0.3)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 30),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: GameColors.blue.withOpacity(_titleGlow.value * 0.2),
                                        blurRadius: 60,
                                        spreadRadius: 20,
                                      ),
                                      BoxShadow(
                                        color: GameColors.orange.withOpacity(_titleGlow.value * 0.1),
                                        blurRadius: 40,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              
                              // Title with enhanced styling
                              Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          GameColors.blue,
                                          GameColors.uiText,
                                          GameColors.orange,
                                        ],
                                        stops: [
                                          0.0,
                                          0.5 + math.sin(_pulseController.value * math.pi) * 0.2,
                                          1.0,
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: const Text(
                                      'AVOIDANCE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 8,
                                        shadows: [
                                          Shadow(
                                            offset: Offset(0, 4),
                                            blurRadius: 20,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Subtitle
                                  AnimatedBuilder(
                                    animation: _subtitleController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _subtitleOpacity.value,
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: GameColors.blue.withOpacity(0.3),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'SURVIVE THE COSMIC CHAOS',
                                            style: TextStyle(
                                              color: GameColors.uiText.withOpacity(0.8),
                                              fontSize: 14,
                                              letterSpacing: 2,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // Main buttons
                  Column(
                    children: [
                      // Start Game button
                      AnimatedBuilder(
                        animation: _buttonAnimations[0],
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -_buttonAnimations[0].value * 100),
                            child: Opacity(
                              opacity: (_buttonAnimations[0].value + 1).clamp(0.0, 1.0),
                              child: _MainMenuButton(
                                text: 'START GAME',
                                icon: Icons.play_arrow,
                                color: GameColors.blue,
                                onPressed: _showDifficultySelection,
                                isHovered: _hoveredButtonIndex == 0,
                                onHover: (hover) {
                                  setState(() {
                                    _hoveredButtonIndex = hover ? 0 : -1;
                                  });
                                },
                                isLarge: true,
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Bottom buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _buttonAnimations[1],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, -_buttonAnimations[1].value * 100),
                                child: Opacity(
                                  opacity: (_buttonAnimations[1].value + 1).clamp(0.0, 1.0),
                                  child: _IconMenuButton(
                                    icon: Icons.leaderboard,
                                    text: 'LEADERBOARD',
                                    color: GameColors.uiText,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              const LeaderboardScreen(),
                                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              )),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    isHovered: _hoveredButtonIndex == 1,
                                    onHover: (hover) {
                                      setState(() {
                                        _hoveredButtonIndex = hover ? 1 : -1;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          AnimatedBuilder(
                            animation: _buttonAnimations[2],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, -_buttonAnimations[2].value * 100),
                                child: Opacity(
                                  opacity: (_buttonAnimations[2].value + 1).clamp(0.0, 1.0),
                                  child: _IconMenuButton(
                                    icon: Icons.emoji_events,
                                    text: 'HIGH SCORES',
                                    color: GameColors.uiText,
                                    onPressed: _showHighScores,
                                    isHovered: _hoveredButtonIndex == 2,
                                    onHover: (hover) {
                                      setState(() {
                                        _hoveredButtonIndex = hover ? 2 : -1;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Difficulty selection dialog
class _DifficultySelectionDialog extends StatefulWidget {
  final Function(Difficulty) onDifficultySelected;

  const _DifficultySelectionDialog({
    required this.onDifficultySelected,
  });

  @override
  State<_DifficultySelectionDialog> createState() => _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState extends State<_DifficultySelectionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _animations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.1,
          0.6 + index * 0.1,
          curve: Curves.easeOutBack,
        ),
      ));
    });
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + _controller.value * 0.2,
          child: Dialog(
            backgroundColor: GameColors.background.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(
                color: GameColors.blue.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SELECT DIFFICULTY',
                    style: TextStyle(
                      color: GameColors.uiText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Difficulty grid
                  Column(
                    children: [
                      // First row (Easy, Medium)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _animations[0],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animations[0].value,
                                child: Opacity(
                                  opacity: _animations[0].value,
                                  child: _DifficultyButton(
                                    difficulty: Difficulty.easy,
                                    isHovered: _hoveredIndex == 0,
                                    onHover: (hover) {
                                      setState(() {
                                        _hoveredIndex = hover ? 0 : -1;
                                      });
                                    },
                                    onPressed: () => widget.onDifficultySelected(Difficulty.easy),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          AnimatedBuilder(
                            animation: _animations[1],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animations[1].value,
                                child: Opacity(
                                  opacity: _animations[1].value,
                                  child: _DifficultyButton(
                                    difficulty: Difficulty.medium,
                                    isHovered: _hoveredIndex == 1,
                                    onHover: (hover) {
                                      setState(() {
                                        _hoveredIndex = hover ? 1 : -1;
                                      });
                                    },
                                    onPressed: () => widget.onDifficultySelected(Difficulty.medium),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Second row (Hard, Ultra)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _animations[2],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animations[2].value,
                                child: Opacity(
                                  opacity: _animations[2].value,
                                  child: _DifficultyButton(
                                    difficulty: Difficulty.hard,
                                    isHovered: _hoveredIndex == 2,
                                    onHover: (hover) {
                                      setState(() {
                                        _hoveredIndex = hover ? 2 : -1;
                                      });
                                    },
                                    onPressed: () => widget.onDifficultySelected(Difficulty.hard),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          AnimatedBuilder(
                            animation: _animations[3],
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _animations[3].value,
                                child: Opacity(
                                  opacity: _animations[3].value,
                                  child: _DifficultyButton(
                                    difficulty: Difficulty.ultra,
                                    isHovered: _hoveredIndex == 3,
                                    onHover: (hover) {
                                      setState(() {
                                        _hoveredIndex = hover ? 3 : -1;
                                      });
                                    },
                                    onPressed: () => widget.onDifficultySelected(Difficulty.ultra),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Difficulty button for the popup
class _DifficultyButton extends StatefulWidget {
  final Difficulty difficulty;
  final bool isHovered;
  final Function(bool) onHover;
  final VoidCallback onPressed;

  const _DifficultyButton({
    required this.difficulty,
    required this.isHovered,
    required this.onHover,
    required this.onPressed,
  });

  @override
  State<_DifficultyButton> createState() => _DifficultyButtonState();
}

class _DifficultyButtonState extends State<_DifficultyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  Color get color => widget.difficulty == Difficulty.easy || widget.difficulty == Difficulty.hard
      ? GameColors.blue
      : GameColors.orange;

  String get description {
    switch (widget.difficulty) {
      case Difficulty.easy:
        return 'Single ship • Blue waves';
      case Difficulty.medium:
        return 'Two ships • Multi waves';
      case Difficulty.hard:
        return 'Shields • Power-ups';
      case Difficulty.ultra:
        return 'Astronaut • Oxygen';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(_DifficultyButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered && !oldWidget.isHovered) {
      _controller.forward();
    } else if (!widget.isHovered && oldWidget.isHovered) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 160,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 2 * _glowAnimation.value,
                  ),
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withOpacity(0.15),
                          color.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: color.withOpacity(0.8 + 0.2 * _glowAnimation.value),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Ultra badge
                        if (widget.difficulty == Difficulty.ultra)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: GameColors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: GameColors.orange.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  color: GameColors.orange,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        
                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Difficulty stars
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  4,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    child: Icon(
                                      index < widget.difficulty.index + 1 ? Icons.star : Icons.star_border,
                                      size: 10,
                                      color: color.withOpacity(0.6),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              
                              // Title
                              Text(
                                widget.difficulty.displayName,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              
                              // Description
                              const SizedBox(height: 4),
                              Text(
                                description,
                                style: TextStyle(
                                  color: color.withOpacity(0.6),
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Main menu button
class _MainMenuButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isHovered;
  final Function(bool) onHover;
  final bool isLarge;

  const _MainMenuButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.isHovered,
    required this.onHover,
    this.isLarge = false,
  });

  @override
  State<_MainMenuButton> createState() => _MainMenuButtonState();
}

class _MainMenuButtonState extends State<_MainMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(_MainMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered && !oldWidget.isHovered) {
      _controller.forward();
    } else if (!widget.isHovered && oldWidget.isHovered) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.isLarge ? 250.0 : 200.0;
    final height = widget.isLarge ? 70.0 : 60.0;
    
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 30 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                  const BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.2),
                          widget.color.withOpacity(0.1),
                        ],
                      ),
                      border: Border.all(
                        color: widget.color.withOpacity(0.8 + 0.2 * _glowAnimation.value),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          color: widget.color,
                          size: widget.isLarge ? 32 : 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: widget.isLarge ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Icon menu button (unchanged)
class _IconMenuButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool isHovered;
  final Function(bool) onHover;

  const _IconMenuButton({
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.isHovered,
    required this.onHover,
  });

  @override
  State<_IconMenuButton> createState() => _IconMenuButtonState();
}

class _IconMenuButtonState extends State<_IconMenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(_IconMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isHovered && !oldWidget.isHovered) {
      _controller.forward();
    } else if (!widget.isHovered && oldWidget.isHovered) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => widget.onHover(true),
      onExit: (_) => widget.onHover(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.color.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.color.withOpacity(0.8),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.color.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Painters remain unchanged
class EnhancedStarFieldPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars = [];
  final List<ShootingStar> shootingStars = [];

  EnhancedStarFieldPainter({required this.animationValue}) {
    // Generate stars if empty
    if (stars.isEmpty) {
      final random = math.Random(DateTime.now().millisecondsSinceEpoch);
      for (int i = 0; i < 150; i++) {
        stars.add(Star(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 2 + 0.5,
          speed: random.nextDouble() * 0.1 + 0.02,
          twinkle: random.nextDouble(),
        ));
      }
      
      // Add shooting stars
      for (int i = 0; i < 3; i++) {
        shootingStars.add(ShootingStar(
          startX: random.nextDouble(),
          startY: random.nextDouble() * 0.5,
          speed: random.nextDouble() * 0.5 + 0.5,
          length: random.nextDouble() * 0.1 + 0.05,
          delay: random.nextDouble(),
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Draw regular stars
    for (final star in stars) {
      final x = star.x * size.width;
      final y = ((star.y + animationValue * star.speed) % 1) * size.height;
      
      final twinkle = math.sin((animationValue + star.twinkle) * math.pi * 4) * 0.3 + 0.7;
      paint.color = GameColors.uiText.withOpacity(0.2 + star.size * 0.15 * twinkle);
      canvas.drawCircle(Offset(x, y), star.size * twinkle, paint);
    }
    
    // Draw shooting stars
    for (final shootingStar in shootingStars) {
      final progress = ((animationValue + shootingStar.delay) % 1) * shootingStar.speed;
      if (progress < 1) {
        final startX = shootingStar.startX * size.width;
        final startY = shootingStar.startY * size.height;
        final endX = startX + size.width * shootingStar.length;
        final endY = startY + size.height * shootingStar.length * 0.5;
        
        final currentX = startX + (endX - startX) * progress;
        final currentY = startY + (endY - startY) * progress;
        
        final gradient = LinearGradient(
          colors: [
            GameColors.blue.withOpacity(0.8 * (1 - progress)),
            GameColors.blue.withOpacity(0),
          ],
        );
        
        final path = Path()
          ..moveTo(currentX, currentY)
          ..lineTo(
            currentX - shootingStar.length * size.width * 0.5,
            currentY - shootingStar.length * size.height * 0.25,
          );
        
        paint
          ..shader = gradient.createShader(
            Rect.fromPoints(
              Offset(currentX, currentY),
              Offset(
                currentX - shootingStar.length * size.width * 0.5,
                currentY - shootingStar.length * size.height * 0.25,
              ),
            ),
          )
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(EnhancedStarFieldPainter oldDelegate) => true;
}

class FloatingParticlesPainter extends CustomPainter {
  final double animationValue;
  final double pulseValue;
  final List<FloatingParticle> particles = [];

  FloatingParticlesPainter({
    required this.animationValue,
    required this.pulseValue,
  }) {
    if (particles.isEmpty) {
      final random = math.Random(DateTime.now().millisecondsSinceEpoch);
      for (int i = 0; i < 20; i++) {
        particles.add(FloatingParticle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 30 + 20,
          speed: random.nextDouble() * 0.05 + 0.02,
          color: random.nextBool() ? GameColors.blue : GameColors.orange,
          offsetPhase: random.nextDouble() * math.pi * 2,
        ));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    for (final particle in particles) {
      final floatOffset = math.sin(animationValue * math.pi * 2 + particle.offsetPhase) * 20;
      final x = particle.x * size.width + floatOffset;
      final y = ((particle.y + animationValue * particle.speed) % 1.2 - 0.1) * size.height;
      
      final pulse = math.sin(pulseValue * math.pi) * 0.3 + 0.7;
      paint.color = particle.color.withOpacity(0.05 * pulse);
      
      // Draw blurred particle
      for (int i = 3; i > 0; i--) {
        paint.color = particle.color.withOpacity(0.015 * pulse * i);
        canvas.drawCircle(
          Offset(x, y),
          particle.size * pulse * (1 + i * 0.3),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(FloatingParticlesPainter oldDelegate) => true;
}

// Enhanced High Scores Dialog
class _HighScoresDialog extends StatefulWidget {
  final Map<Difficulty, int> highScores;

  const _HighScoresDialog({
    required this.highScores,
  });

  @override
  State<_HighScoresDialog> createState() => _HighScoresDialogState();
}

class _HighScoresDialogState extends State<_HighScoresDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scoreController;
  late List<Animation<double>> _scoreAnimations;
  late Animation<double> _titleAnimation;
  late Animation<double> _containerAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _titleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _containerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _scoreAnimations = List.generate(4, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.3 + index * 0.1,
          0.7 + index * 0.1,
          curve: Curves.easeOutBack,
        ),
      ));
    });
    
    _controller.forward();
    _scoreController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  // Get the highest score across all difficulties
  int get bestScore {
    return widget.highScores.values.fold(0, (max, score) => score > max ? score : max);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _containerAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Container(
              width: 350,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    GameColors.background.withOpacity(0.95),
                    GameColors.background.withBlue(30).withOpacity(0.95),
                  ],
                ),
                border: Border.all(
                  color: GameColors.blue.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: GameColors.blue.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                  const BoxShadow(
                    color: Colors.black54,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _HighScoresBackgroundPainter(
                        animationValue: _scoreController.value,
                      ),
                    ),
                  ),
                  
                  // Content with reduced padding
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title with smaller trophy icon
                        AnimatedBuilder(
                          animation: _titleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _titleAnimation.value,
                              child: Opacity(
                                opacity: _titleAnimation.value,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.emoji_events,
                                      color: GameColors.orange,
                                      size: 32,
                                      shadows: [
                                        Shadow(
                                          color: GameColors.orange.withOpacity(0.5),
                                          blurRadius: 15,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: [
                                            GameColors.blue,
                                            GameColors.uiText,
                                            GameColors.orange,
                                          ],
                                        ).createShader(bounds);
                                      },
                                      child: const Text(
                                        'HIGH SCORES',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Score entries
                        ...Difficulty.values.asMap().entries.map((entry) {
                          final index = entry.key;
                          final difficulty = entry.value;
                          final score = widget.highScores[difficulty] ?? 0;
                          final color = difficulty == Difficulty.easy || difficulty == Difficulty.hard
                              ? GameColors.blue
                              : GameColors.orange;
                          
                          return AnimatedBuilder(
                            animation: _scoreAnimations[index],
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                  (1 - _scoreAnimations[index].value) * 50, 
                                  0,
                                ),
                                child: Opacity(
                                  opacity: _scoreAnimations[index].value,
                                  child: _HighScoreEntry(
                                    difficulty: difficulty,
                                    score: score,
                                    color: color,
                                    rank: index + 1,
                                    isHighest: score == bestScore && score > 0,
                                    animationValue: _scoreController.value,
                                    compact: true,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        
                        const SizedBox(height: 16),
                        
                        // Close button
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _containerAnimation.value,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pop(),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24, 
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: [
                                          GameColors.blue.withOpacity(0.2),
                                          GameColors.blue.withOpacity(0.1),
                                        ],
                                      ),
                                      border: Border.all(
                                        color: GameColors.blue.withOpacity(0.8),
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.close,
                                          color: GameColors.blue,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'CLOSE',
                                          style: TextStyle(
                                            color: GameColors.blue,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// High Score Entry Widget
class _HighScoreEntry extends StatelessWidget {
  final Difficulty difficulty;
  final int score;
  final Color color;
  final int rank;
  final bool isHighest;
  final double animationValue;
  final bool compact;

  const _HighScoreEntry({
    required this.difficulty,
    required this.score,
    required this.color,
    required this.rank,
    required this.isHighest,
    required this.animationValue,
    this.compact = false,
  });

  String get description {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Single ship • Blue waves';
      case Difficulty.medium:
        return 'Two ships • Multi waves';
      case Difficulty.hard:
        return 'Shields • Power-ups';
      case Difficulty.ultra:
        return 'Astronaut • Oxygen';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(compact ? 10 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(isHighest ? 0.15 : 0.08),
                color.withOpacity(isHighest ? 0.08 : 0.02),
              ],
            ),
            border: Border.all(
              color: color.withOpacity(isHighest ? 0.8 : 0.3),
              width: isHighest ? 2 : 1,
            ),
            boxShadow: isHighest ? [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ] : null,
          ),
          child: Row(
            children: [
              // Rank badge - smaller when compact
              Container(
                width: compact ? 30 : 40,
                height: compact ? 30 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: color.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      4,
                      (index) => Icon(
                        index < rank ? Icons.star : Icons.star_border,
                        size: compact ? 6 : 8,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
              
              SizedBox(width: compact ? 10 : 16),
              
              // Difficulty info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          difficulty.displayName,
                          style: TextStyle(
                            color: color,
                            fontSize: compact ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (isHighest && score > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: GameColors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: GameColors.orange.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'BEST',
                              style: TextStyle(
                                color: GameColors.orange,
                                fontSize: compact ? 6 : 8,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          color: color.withOpacity(0.6),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AnimatedBuilder(
                    animation: AlwaysStoppedAnimation(animationValue),
                    builder: (context, child) {
                      final displayScore = (score * animationValue).round();
                      return Text(
                        displayScore.toString().padLeft(6, '0'),
                        style: TextStyle(
                          color: color,
                          fontSize: compact ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: compact ? 1 : 2,
                          shadows: [
                            Shadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Text(
                    'POINTS',
                    style: TextStyle(
                      color: color.withOpacity(0.5),
                      fontSize: compact ? 6 : 8,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Background painter for high scores dialog
class _HighScoresBackgroundPainter extends CustomPainter {
  final double animationValue;

  _HighScoresBackgroundPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    // Draw grid pattern
    paint.color = GameColors.blue.withOpacity(0.03);
    
    const gridSize = 30.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw animated accent lines
    paint.color = GameColors.blue.withOpacity(0.1 * animationValue);
    paint.strokeWidth = 2;
    
    final lineY = size.height * animationValue;
    canvas.drawLine(
      Offset(0, lineY),
      Offset(size.width, lineY),
      paint,
    );
    
    paint.color = GameColors.orange.withOpacity(0.1 * animationValue);
    final lineX = size.width * animationValue;
    canvas.drawLine(
      Offset(lineX, 0),
      Offset(lineX, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_HighScoresBackgroundPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue;
}

// Data classes remain unchanged
class Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double twinkle;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.twinkle,
  });
}

class ShootingStar {
  final double startX;
  final double startY;
  final double speed;
  final double length;
  final double delay;

  ShootingStar({
    required this.startX,
    required this.startY,
    required this.speed,
    required this.length,
    required this.delay,
  });
}

class FloatingParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final Color color;
  final double offsetPhase;

  FloatingParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
    required this.offsetPhase,
  });
}