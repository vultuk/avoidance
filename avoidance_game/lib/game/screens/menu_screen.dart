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
  late Animation<double> _titleScale;
  late Animation<double> _titleGlow;
  late List<AnimationController> _buttonControllers;
  late List<Animation<double>> _buttonAnimations;
  
  Map<Difficulty, int> highScores = {};
  int _hoveredButtonIndex = -1;

  @override
  void initState() {
    super.initState();
    
    // Star field animation
    _starController = AnimationController(
      duration: const Duration(seconds: 60),
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
          
          // Menu content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated title
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
                            // Glow effect
                            if (_titleGlow.value > 0.5)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: GameColors.blue.withOpacity(_titleGlow.value * 0.3),
                                      blurRadius: 30,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                            // Title text
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    GameColors.blue,
                                    GameColors.uiText,
                                    GameColors.blue,
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
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 60),
                
                // Animated difficulty buttons
                ...Difficulty.values.asMap().entries.map((entry) {
                  final index = entry.key;
                  final difficulty = entry.value;
                  
                  return AnimatedBuilder(
                    animation: _buttonAnimations[index],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_buttonAnimations[index].value * 300, 0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: _EnhancedMenuButton(
                            text: difficulty.displayName,
                            color: difficulty == Difficulty.easy || difficulty == Difficulty.hard
                                ? GameColors.blue
                                : GameColors.orange,
                            onPressed: () => _startGame(difficulty),
                            isHovered: _hoveredButtonIndex == index,
                            onHover: (hover) {
                              setState(() {
                                _hoveredButtonIndex = hover ? index : -1;
                              });
                            },
                            difficultyLevel: index + 1,
                          ),
                        ),
                      );
                    },
                  );
                }),
                
                const SizedBox(height: 40),
                
                // Bottom buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _buttonAnimations[4],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_buttonAnimations[4].value * 100),
                          child: _EnhancedMenuButton(
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
                            isSmall: true,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    AnimatedBuilder(
                      animation: _buttonAnimations[5],
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -_buttonAnimations[5].value * 100),
                          child: _EnhancedMenuButton(
                            text: 'HIGH SCORES',
                            color: GameColors.uiText,
                            onPressed: _showHighScores,
                            isHovered: _hoveredButtonIndex == 5,
                            onHover: (hover) {
                              setState(() {
                                _hoveredButtonIndex = hover ? 5 : -1;
                              });
                            },
                            isSmall: true,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
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
  final bool isSmall;
  final int? difficultyLevel;

  const _EnhancedMenuButton({
    required this.text,
    required this.color,
    required this.onPressed,
    required this.isHovered,
    required this.onHover,
    this.isSmall = false,
    this.difficultyLevel,
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
      end: 1.1,
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
    final width = widget.isSmall ? GameSizes.buttonWidth : GameSizes.buttonWidth * 1.5;
    final height = widget.isSmall ? GameSizes.buttonHeight : GameSizes.buttonHeight * 1.2;
    
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(0.3 * _glowAnimation.value),
                    blurRadius: 20 * _glowAnimation.value,
                    spreadRadius: 5 * _glowAnimation.value,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withOpacity(0.1),
                          widget.color.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                  
                  // Button
                  OutlinedButton(
                    onPressed: widget.onPressed,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.color,
                        width: 2 + _glowAnimation.value,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.difficultyLevel != null) ...[
                              Row(
                                children: List.generate(
                                  widget.difficultyLevel!,
                                  (index) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Icon(
                                      Icons.star,
                                      size: 12,
                                      color: widget.color.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.text,
                              style: TextStyle(
                                color: widget.color,
                                fontSize: widget.isSmall ? GameSizes.fontSize : GameSizes.fontSize + 4,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
          speed: random.nextDouble() * 0.3 + 0.05,
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
          speed: random.nextDouble() * 0.2 + 0.1,
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
      paint.color = particle.color.withOpacity(0.1 * pulse);
      
      // Draw blurred particle
      for (int i = 3; i > 0; i--) {
        paint.color = particle.color.withOpacity(0.02 * pulse * i);
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