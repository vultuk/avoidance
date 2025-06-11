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
    
    // Button animations
    _buttonControllers = List.generate(
      6, // 4 difficulty buttons + 2 bottom buttons
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
      builder: (context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, value, child) => Transform.scale(
          scale: value,
          child: AlertDialog(
            backgroundColor: GameColors.background.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: GameColors.blue.withOpacity(0.5),
                width: 2,
              ),
            ),
            title: const Text(
              'HIGH SCORES',
              style: TextStyle(
                color: GameColors.uiText,
                fontSize: GameSizes.titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: Difficulty.values.map((difficulty) {
                final score = highScores[difficulty] ?? 0;
                final color = difficulty == Difficulty.easy || difficulty == Difficulty.hard
                    ? GameColors.blue
                    : GameColors.orange;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            difficulty.displayName,
                            style: const TextStyle(
                              color: GameColors.uiText,
                              fontSize: GameSizes.fontSize,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        score.toString().padLeft(6, '0'),
                        style: TextStyle(
                          color: color,
                          fontSize: GameSizes.fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: GameColors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'CLOSE',
                    style: TextStyle(
                      color: GameColors.blue,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
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
                    
                    const SizedBox(height: 40),
                    
                    // Difficulty selection label
                    AnimatedBuilder(
                      animation: _buttonAnimations[0],
                      builder: (context, child) {
                        return Opacity(
                          opacity: (_buttonAnimations[0].value + 1).clamp(0.0, 1.0),
                          child: Text(
                            'SELECT DIFFICULTY',
                            style: TextStyle(
                              color: GameColors.uiText.withOpacity(0.6),
                              fontSize: 12,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Animated difficulty buttons in 2x2 grid with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // First row (Easy, Medium)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _buttonAnimations[0],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_buttonAnimations[0].value * 300, 0),
                                    child: Opacity(
                                      opacity: (_buttonAnimations[0].value + 1).clamp(0.0, 1.0),
                                      child: _EnhancedMenuButton(
                                        text: Difficulty.easy.displayName,
                                        color: GameColors.blue,
                                        onPressed: () => _startGame(Difficulty.easy),
                                        isHovered: _hoveredButtonIndex == 0,
                                        onHover: (hover) {
                                          setState(() {
                                            _hoveredButtonIndex = hover ? 0 : -1;
                                          });
                                        },
                                        difficultyLevel: 1,
                                        description: 'Single ship • Blue waves',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              AnimatedBuilder(
                                animation: _buttonAnimations[1],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(-_buttonAnimations[1].value * 300, 0),
                                    child: Opacity(
                                      opacity: (_buttonAnimations[1].value + 1).clamp(0.0, 1.0),
                                      child: _EnhancedMenuButton(
                                        text: Difficulty.medium.displayName,
                                        color: GameColors.orange,
                                        onPressed: () => _startGame(Difficulty.medium),
                                        isHovered: _hoveredButtonIndex == 1,
                                        onHover: (hover) {
                                          setState(() {
                                            _hoveredButtonIndex = hover ? 1 : -1;
                                          });
                                        },
                                        difficultyLevel: 2,
                                        description: 'Two ships • Multi waves',
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
                                animation: _buttonAnimations[2],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_buttonAnimations[2].value * 300, 0),
                                    child: Opacity(
                                      opacity: (_buttonAnimations[2].value + 1).clamp(0.0, 1.0),
                                      child: _EnhancedMenuButton(
                                        text: Difficulty.hard.displayName,
                                        color: GameColors.blue,
                                        onPressed: () => _startGame(Difficulty.hard),
                                        isHovered: _hoveredButtonIndex == 2,
                                        onHover: (hover) {
                                          setState(() {
                                            _hoveredButtonIndex = hover ? 2 : -1;
                                          });
                                        },
                                        difficultyLevel: 3,
                                        description: 'Shields • Power-ups',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              AnimatedBuilder(
                                animation: _buttonAnimations[3],
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(-_buttonAnimations[3].value * 300, 0),
                                    child: Opacity(
                                      opacity: (_buttonAnimations[3].value + 1).clamp(0.0, 1.0),
                                      child: _EnhancedMenuButton(
                                        text: Difficulty.ultra.displayName,
                                        color: GameColors.orange,
                                        onPressed: () => _startGame(Difficulty.ultra),
                                        isHovered: _hoveredButtonIndex == 3,
                                        onHover: (hover) {
                                          setState(() {
                                            _hoveredButtonIndex = hover ? 3 : -1;
                                          });
                                        },
                                        difficultyLevel: 4,
                                        description: 'Astronaut • Oxygen',
                                        isUltra: true,
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
                    
                    const SizedBox(height: 50),
                    
                    // Divider
                    AnimatedBuilder(
                      animation: _buttonAnimations[4],
                      builder: (context, child) {
                        return Opacity(
                          opacity: (_buttonAnimations[4].value + 1).clamp(0.0, 1.0),
                          child: Container(
                            width: 200,
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  GameColors.uiText.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Bottom buttons with icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _buttonAnimations[4],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -_buttonAnimations[4].value * 100),
                              child: Opacity(
                                opacity: (_buttonAnimations[4].value + 1).clamp(0.0, 1.0),
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
                                  isHovered: _hoveredButtonIndex == 4,
                                  onHover: (hover) {
                                    setState(() {
                                      _hoveredButtonIndex = hover ? 4 : -1;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        AnimatedBuilder(
                          animation: _buttonAnimations[5],
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -_buttonAnimations[5].value * 100),
                              child: Opacity(
                                opacity: (_buttonAnimations[5].value + 1).clamp(0.0, 1.0),
                                child: _IconMenuButton(
                                  icon: Icons.emoji_events,
                                  text: 'HIGH SCORES',
                                  color: GameColors.uiText,
                                  onPressed: _showHighScores,
                                  isHovered: _hoveredButtonIndex == 5,
                                  onHover: (hover) {
                                    setState(() {
                                      _hoveredButtonIndex = hover ? 5 : -1;
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhancedMenuButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool isHovered;
  final Function(bool) onHover;
  final int? difficultyLevel;
  final String? description;
  final bool isUltra;

  const _EnhancedMenuButton({
    required this.text,
    required this.color,
    required this.onPressed,
    required this.isHovered,
    required this.onHover,
    this.difficultyLevel,
    this.description,
    this.isUltra = false,
  });

  @override
  State<_EnhancedMenuButton> createState() => _EnhancedMenuButtonState();
}

class _EnhancedMenuButtonState extends State<_EnhancedMenuButton>
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
  void didUpdateWidget(_EnhancedMenuButton oldWidget) {
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
                    color: widget.color.withOpacity(0.2 * _glowAnimation.value),
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
                          widget.color.withOpacity(0.15),
                          widget.color.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: widget.color.withOpacity(0.8 + 0.2 * _glowAnimation.value),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Ultra badge
                        if (widget.isUltra)
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
                              if (widget.difficultyLevel != null)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    4,
                                    (index) => Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 2),
                                      child: Icon(
                                        index < widget.difficultyLevel! ? Icons.star : Icons.star_border,
                                        size: 10,
                                        color: widget.color.withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              
                              // Title
                              Text(
                                widget.text,
                                style: TextStyle(
                                  color: widget.color,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              
                              // Description
                              if (widget.description != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.description!,
                                  style: TextStyle(
                                    color: widget.color.withOpacity(0.6),
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
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