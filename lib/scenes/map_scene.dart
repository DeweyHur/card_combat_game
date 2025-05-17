import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../managers/dialogue_manager.dart';
import '../managers/sound_manager.dart';
import '../components/nintendo_message_box.dart';

class MapScene extends StatefulWidget {
  const MapScene({Key? key}) : super(key: key);

  @override
  State<MapScene> createState() => _MapSceneState();
}

class _MapSceneState extends State<MapScene> with WidgetsBindingObserver {
  final DialogueManager _dialogueManager = DialogueManager();
  final SoundManager _soundManager = SoundManager();
  bool _showDialogue = true;
  bool _showBattleArea = false;
  bool _isInitialized = false;
  
  // Player position
  double _playerX = 150;
  double _playerY = 150;
  final double _playerSize = 32;
  final double _moveSpeed = 5;
  
  // Map boundaries
  final double _mapWidth = 800;
  final double _mapHeight = 500;
  
  // Landmarks
  final List<MapLandmark> _landmarks = [
    MapLandmark(
      name: "Borobudur Temple",
      x: 200,
      y: 150,
      icon: Icons.church,
      color: Colors.brown,
    ),
    MapLandmark(
      name: "Mount Bromo",
      x: 300,
      y: 180,
      icon: Icons.landscape,
      color: Colors.grey,
    ),
    MapLandmark(
      name: "Bali Beach",
      x: 400,
      y: 250,
      icon: Icons.beach_access,
      color: Colors.blue,
    ),
    MapLandmark(
      name: "Komodo Island",
      x: 500,
      y: 280,
      icon: Icons.pets,
      color: Colors.green,
    ),
    MapLandmark(
      name: "Raja Ampat",
      x: 600,
      y: 150,
      icon: Icons.water,
      color: Colors.cyan,
    ),
  ];
  
  // Battle crystal position
  final double _crystalX = 700;
  final double _crystalY = 400;
  final double _crystalSize = 40;
  
  // Animation
  double _crystalGlow = 0;
  bool _crystalGlowIncreasing = true;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isAnimating = false;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _initializeGame();
    } else if (state == AppLifecycleState.paused) {
      _isAnimating = false;
    }
  }

  Future<void> _initializeGame() async {
    if (_isInitialized) return;
    
    try {
      await _soundManager.initialize();
      await _initializeDialogue();
      _startCrystalAnimation();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing game: $e');
    }
  }

  void _startCrystalAnimation() {
    _isAnimating = true;
    _animateCrystal();
  }

  void _animateCrystal() {
    if (!_isAnimating) return;

    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted && _isAnimating) {
        setState(() {
          if (_crystalGlowIncreasing) {
            _crystalGlow += 0.05;
            if (_crystalGlow >= 1) {
              _crystalGlowIncreasing = false;
            }
          } else {
            _crystalGlow -= 0.05;
            if (_crystalGlow <= 0) {
              _crystalGlowIncreasing = true;
            }
          }
        });
        _animateCrystal();
      }
    });
  }

  Future<void> _initializeDialogue() async {
    await _dialogueManager.loadDialogue('tutorial');
    _dialogueManager.startDialogue('tutorial');
    if (mounted) {
      setState(() {});
    }
  }

  void _handleNextDialogue() {
    if (_dialogueManager.advanceDialogue()) {
      setState(() {});
    } else {
      setState(() {
        _showDialogue = false;
        _showBattleArea = true;
      });
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      setState(() {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowLeft:
            _playerX = (_playerX - _moveSpeed).clamp(0, _mapWidth - _playerSize);
            break;
          case LogicalKeyboardKey.arrowRight:
            _playerX = (_playerX + _moveSpeed).clamp(0, _mapWidth - _playerSize);
            break;
          case LogicalKeyboardKey.arrowUp:
            _playerY = (_playerY - _moveSpeed).clamp(0, _mapHeight - _playerSize);
            break;
          case LogicalKeyboardKey.arrowDown:
            _playerY = (_playerY + _moveSpeed).clamp(0, _mapHeight - _playerSize);
            break;
        }
        
        // Check if player reached the crystal
        if (_showBattleArea) {
          final double dx = _playerX - _crystalX;
          final double dy = _playerY - _crystalY;
          final double distance = sqrt(dx * dx + dy * dy);
          
          if (distance < (_playerSize + _crystalSize) / 2) {
            Navigator.pushReplacementNamed(context, '/battle');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyPress,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: Colors.lightBlue,
          ),
          child: Stack(
            children: [
              // Map background
              Center(
                child: Container(
                  width: _mapWidth,
                  height: _mapHeight,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    border: Border.all(color: Colors.brown, width: 4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Sumatra Island
                      Positioned(
                        left: 50,
                        top: 100,
                        child: CustomPaint(
                          size: const Size(200, 300),
                          painter: IslandPainter(
                            color: Colors.green.shade800,
                            points: [
                              const Offset(0, 100),
                              const Offset(50, 50),
                              const Offset(150, 30),
                              const Offset(200, 80),
                              const Offset(180, 200),
                              const Offset(100, 250),
                              const Offset(20, 200),
                            ],
                          ),
                        ),
                      ),
                      // Java Island
                      Positioned(
                        left: 250,
                        top: 150,
                        child: CustomPaint(
                          size: const Size(150, 100),
                          painter: IslandPainter(
                            color: Colors.green.shade800,
                            points: [
                              const Offset(0, 50),
                              const Offset(50, 20),
                              const Offset(150, 40),
                              const Offset(140, 80),
                              const Offset(80, 100),
                              const Offset(20, 80),
                            ],
                          ),
                        ),
                      ),
                      // Bali and Nusa Tenggara
                      Positioned(
                        left: 400,
                        top: 200,
                        child: CustomPaint(
                          size: const Size(100, 150),
                          painter: IslandPainter(
                            color: Colors.green.shade800,
                            points: [
                              const Offset(0, 50),
                              const Offset(30, 20),
                              const Offset(80, 30),
                              const Offset(100, 80),
                              const Offset(70, 150),
                              const Offset(20, 120),
                            ],
                          ),
                        ),
                      ),
                      // Sulawesi
                      Positioned(
                        left: 500,
                        top: 100,
                        child: CustomPaint(
                          size: const Size(200, 200),
                          painter: IslandPainter(
                            color: Colors.green.shade800,
                            points: [
                              const Offset(50, 0),
                              const Offset(100, 50),
                              const Offset(150, 30),
                              const Offset(200, 80),
                              const Offset(180, 150),
                              const Offset(100, 200),
                              const Offset(50, 150),
                              const Offset(0, 100),
                            ],
                          ),
                        ),
                      ),
                      // Papua
                      Positioned(
                        left: 650,
                        top: 50,
                        child: CustomPaint(
                          size: const Size(100, 300),
                          painter: IslandPainter(
                            color: Colors.green.shade800,
                            points: [
                              const Offset(0, 50),
                              const Offset(50, 0),
                              const Offset(100, 50),
                              const Offset(90, 200),
                              const Offset(50, 300),
                              const Offset(10, 250),
                            ],
                          ),
                        ),
                      ),
                      // Draw landmarks
                      ..._landmarks.map((landmark) => Positioned(
                        left: landmark.x - 20,
                        top: landmark.y - 20,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: landmark.color.withOpacity(0.8),
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              landmark.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      )),
                      // Battle crystal
                      if (_showBattleArea)
                        Positioned(
                          left: _crystalX - _crystalSize / 2,
                          top: _crystalY - _crystalSize / 2,
                          child: Container(
                            width: _crystalSize,
                            height: _crystalSize,
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.7 + _crystalGlow * 0.3),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8 + _crystalGlow * 0.2),
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.diamond,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      // Player
                      Positioned(
                        left: _playerX - _playerSize / 2,
                        top: _playerY - _playerSize / 2,
                        child: Container(
                          width: _playerSize,
                          height: _playerSize,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Dialogue box
              if (_showDialogue)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: NintendoMessageBox(
                    character: _dialogueManager.getCurrentEntry()?.character ?? '',
                    message: _dialogueManager.getCurrentEntry()?.message ?? '',
                    onNext: _handleNextDialogue,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapLandmark {
  final String name;
  final double x;
  final double y;
  final IconData icon;
  final Color color;

  MapLandmark({
    required this.name,
    required this.x,
    required this.y,
    required this.icon,
    required this.color,
  });
}

class IslandPainter extends CustomPainter {
  final Color color;
  final List<Offset> points;

  IslandPainter({
    required this.color,
    required this.points,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    path.close();
    
    // Add a subtle shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
    
    // Add a white border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 