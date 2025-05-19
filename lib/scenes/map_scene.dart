import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
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
  final double _moveSpeed = 3.0;

  // Map boundaries - adjusted for mobile
  late double _mapWidth;
  late double _mapHeight;

  // Movement control
  bool _isMovingUp = false;
  bool _isMovingDown = false;
  bool _isMovingLeft = false;
  bool _isMovingRight = false;
  Timer? _movementTimer;
  bool _showMovementControls = false;

  // Landmarks
  final List<MapLandmark> _landmarks = [
    MapLandmark(
      name: "Borobudur Temple",
      x: 200,
      y: 150,
      type: LandmarkType.temple,
      color: Colors.brown,
    ),
    MapLandmark(
      name: "Mount Bromo",
      x: 300,
      y: 180,
      type: LandmarkType.mountain,
      color: Colors.grey,
    ),
    MapLandmark(
      name: "Bali Beach",
      x: 400,
      y: 250,
      type: LandmarkType.beach,
      color: Colors.blue,
    ),
    MapLandmark(
      name: "Komodo Island",
      x: 500,
      y: 280,
      type: LandmarkType.island,
      color: Colors.green,
    ),
    MapLandmark(
      name: "Raja Ampat",
      x: 600,
      y: 150,
      type: LandmarkType.beach,
      color: Colors.cyan,
    ),
  ];

  // Battle crystal position - now relative to player
  late double _crystalX;
  late double _crystalY;
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
    _startMovementTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isAnimating = false;
    _movementTimer?.cancel();
    super.dispose();
  }

  void _startMovementTimer() {
    _movementTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_isMovingUp || _isMovingDown || _isMovingLeft || _isMovingRight) {
        _updatePlayerPosition();
      }
    });
  }

  void _updatePlayerPosition() {
    setState(() {
      if (_isMovingLeft) {
        _playerX = (_playerX - _moveSpeed).clamp(0, _mapWidth - _playerSize);
      }
      if (_isMovingRight) {
        _playerX = (_playerX + _moveSpeed).clamp(0, _mapWidth - _playerSize);
      }
      if (_isMovingUp) {
        _playerY = (_playerY - _moveSpeed).clamp(0, _mapHeight - _playerSize);
      }
      if (_isMovingDown) {
        _playerY = (_playerY + _moveSpeed).clamp(0, _mapHeight - _playerSize);
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
      // Remove all print statements
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
        // Position crystal near player when dialogue ends
        _crystalX = _playerX + 100;
        _crystalY = _playerY;
      });
    }
  }

  Widget _buildLandmark(MapLandmark landmark) {
    return CustomPaint(
      size: const Size(32, 32),
      painter: LandmarkPainter(
        type: landmark.type,
        color: landmark.color,
      ),
    );
  }

  Widget _buildMovementButton() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showMovementControls = !_showMovementControls;
          });
        },
        backgroundColor: Colors.black.withAlpha((0.7 * 255).toInt()),
        child: Icon(
          _showMovementControls ? Icons.close : Icons.directions,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBattleIndicator() {
    if (!_showBattleArea) return const SizedBox.shrink();

    final double dx = _playerX - _crystalX;
    final double dy = _playerY - _crystalY;
    final double distance = sqrt(dx * dx + dy * dy);
    final bool isNear = distance < 200; // Show indicator when within 200 pixels

    if (!isNear) return const SizedBox.shrink();

    return Positioned(
      left: _crystalX - 20,
      top: _crystalY - 40,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withAlpha((0.8 * 255).toInt()),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Battle!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'PressStart2P',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementControls() {
    if (!_showMovementControls) return const SizedBox.shrink();

    return Positioned(
      right: 20,
      bottom: 100,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((0.5 * 255).toInt()),
          borderRadius: BorderRadius.circular(60),
        ),
        child: Stack(
          children: [
            // Up button
            Positioned(
              top: 0,
              left: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isMovingUp = true),
                onTapUp: (_) => setState(() => _isMovingUp = false),
                onTapCancel: () => setState(() => _isMovingUp = false),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isMovingUp
                        ? Colors.white.withAlpha((0.8 * 255).toInt())
                        : Colors.white.withAlpha((0.3 * 255).toInt()),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ),
            // Down button
            Positioned(
              bottom: 0,
              left: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isMovingDown = true),
                onTapUp: (_) => setState(() => _isMovingDown = false),
                onTapCancel: () => setState(() => _isMovingDown = false),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isMovingDown
                        ? Colors.white.withAlpha((0.8 * 255).toInt())
                        : Colors.white.withAlpha((0.3 * 255).toInt()),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.arrow_downward, color: Colors.white),
                ),
              ),
            ),
            // Left button
            Positioned(
              left: 0,
              top: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isMovingLeft = true),
                onTapUp: (_) => setState(() => _isMovingLeft = false),
                onTapCancel: () => setState(() => _isMovingLeft = false),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isMovingLeft
                        ? Colors.white.withAlpha((0.8 * 255).toInt())
                        : Colors.white.withAlpha((0.3 * 255).toInt()),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
            // Right button
            Positioned(
              right: 0,
              top: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) => setState(() => _isMovingRight = true),
                onTapUp: (_) => setState(() => _isMovingRight = false),
                onTapCancel: () => setState(() => _isMovingRight = false),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isMovingRight
                        ? Colors.white.withAlpha((0.8 * 255).toInt())
                        : Colors.white.withAlpha((0.3 * 255).toInt()),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for mobile layout
    final screenSize = MediaQuery.of(context).size;
    _mapWidth = screenSize.width;
    _mapHeight = screenSize.height;

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.lightBlue,
        ),
        child: Stack(
          children: [
            // Map background
            Container(
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
                    left: _mapWidth * 0.1,
                    top: _mapHeight * 0.2,
                    child: CustomPaint(
                      size: Size(_mapWidth * 0.3, _mapHeight * 0.6),
                      painter: IslandPainter(
                        color: Colors.green.shade800,
                        points: [
                          Offset(0, _mapHeight * 0.2),
                          Offset(_mapWidth * 0.1, _mapHeight * 0.1),
                          Offset(_mapWidth * 0.25, _mapHeight * 0.05),
                          Offset(_mapWidth * 0.3, _mapHeight * 0.15),
                          Offset(_mapWidth * 0.25, _mapHeight * 0.4),
                          Offset(_mapWidth * 0.15, _mapHeight * 0.5),
                          Offset(_mapWidth * 0.05, _mapHeight * 0.4),
                        ],
                      ),
                    ),
                  ),
                  // Java Island
                  Positioned(
                    left: _mapWidth * 0.4,
                    top: _mapHeight * 0.3,
                    child: CustomPaint(
                      size: Size(_mapWidth * 0.25, _mapHeight * 0.2),
                      painter: IslandPainter(
                        color: Colors.green.shade800,
                        points: [
                          Offset(0, _mapHeight * 0.1),
                          Offset(_mapWidth * 0.1, _mapHeight * 0.05),
                          Offset(_mapWidth * 0.25, _mapHeight * 0.1),
                          Offset(_mapWidth * 0.2, _mapHeight * 0.2),
                          Offset(_mapWidth * 0.15, _mapHeight * 0.25),
                          Offset(_mapWidth * 0.05, _mapHeight * 0.2),
                        ],
                      ),
                    ),
                  ),
                  // Bali and Nusa Tenggara
                  Positioned(
                    left: _mapWidth * 0.6,
                    top: _mapHeight * 0.4,
                    child: CustomPaint(
                      size: Size(_mapWidth * 0.2, _mapHeight * 0.3),
                      painter: IslandPainter(
                        color: Colors.green.shade800,
                        points: [
                          Offset(0, _mapHeight * 0.1),
                          Offset(_mapWidth * 0.05, _mapHeight * 0.05),
                          Offset(_mapWidth * 0.15, _mapHeight * 0.05),
                          Offset(_mapWidth * 0.2, _mapHeight * 0.15),
                          Offset(_mapWidth * 0.15, _mapHeight * 0.3),
                          Offset(_mapWidth * 0.05, _mapHeight * 0.25),
                        ],
                      ),
                    ),
                  ),
                  // Draw landmarks
                  ..._landmarks.map((landmark) => Positioned(
                        left: landmark.x * (_mapWidth / 800),
                        top: landmark.y * (_mapHeight / 500),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLandmark(landmark),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    Colors.black.withAlpha((0.7 * 255).toInt()),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                landmark.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'PressStart2P',
                                ),
                              ),
                            ),
                          ],
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
                          color: Colors.purple.withAlpha(
                              ((0.7 + _crystalGlow * 0.3) * 255).toInt()),
                          border: Border.all(
                            color: Colors.white.withAlpha(
                                ((0.8 + _crystalGlow * 0.2) * 255).toInt()),
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
                  // Battle indicator
                  _buildBattleIndicator(),
                ],
              ),
            ),
            // Movement controls
            if (!_showDialogue) ...[
              _buildMovementButton(),
              _buildMovementControls(),
            ],
            // Dialogue box
            if (_showDialogue)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: NintendoMessageBox(
                  character:
                      _dialogueManager.getCurrentEntry()?.character ?? '',
                  message: _dialogueManager.getCurrentEntry()?.message ?? '',
                  onNext: _handleNextDialogue,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum LandmarkType {
  temple,
  mountain,
  beach,
  island,
}

class MapLandmark {
  final String name;
  final double x;
  final double y;
  final LandmarkType type;
  final Color color;

  MapLandmark({
    required this.name,
    required this.x,
    required this.y,
    required this.type,
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
      ..color = Colors.black.withAlpha((0.3 * 255).toInt())
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

class LandmarkPainter extends CustomPainter {
  final LandmarkType type;
  final Color color;

  LandmarkPainter({
    required this.type,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    switch (type) {
      case LandmarkType.temple:
        _drawTemple(canvas, size, paint, borderPaint);
        break;
      case LandmarkType.mountain:
        _drawMountain(canvas, size, paint, borderPaint);
        break;
      case LandmarkType.beach:
        _drawBeach(canvas, size, paint, borderPaint);
        break;
      case LandmarkType.island:
        _drawIsland(canvas, size, paint, borderPaint);
        break;
    }
  }

  void _drawTemple(Canvas canvas, Size size, Paint paint, Paint borderPaint) {
    // Base
    canvas.drawRect(
      const Rect.fromLTWH(8, 24, 16, 8),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, 24, 16, 8),
      borderPaint,
    );

    // Middle
    canvas.drawRect(
      const Rect.fromLTWH(12, 16, 8, 8),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(12, 16, 8, 8),
      borderPaint,
    );

    // Top
    canvas.drawRect(
      const Rect.fromLTWH(14, 8, 4, 8),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(14, 8, 4, 8),
      borderPaint,
    );
  }

  void _drawMountain(Canvas canvas, Size size, Paint paint, Paint borderPaint) {
    final path = Path();
    path.moveTo(16, 8); // Top
    path.lineTo(8, 24); // Bottom left
    path.lineTo(24, 24); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  void _drawBeach(Canvas canvas, Size size, Paint paint, Paint borderPaint) {
    // Water
    canvas.drawRect(
      const Rect.fromLTWH(8, 8, 16, 16),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, 8, 16, 16),
      borderPaint,
    );

    // Sand
    final sandPaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(8, 20, 16, 12),
      sandPaint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, 20, 16, 12),
      borderPaint,
    );
  }

  void _drawIsland(Canvas canvas, Size size, Paint paint, Paint borderPaint) {
    // Island base
    canvas.drawRect(
      const Rect.fromLTWH(8, 16, 16, 16),
      paint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(8, 16, 16, 16),
      borderPaint,
    );

    // Palm tree
    final treePaint = Paint()
      ..color = Colors.green.shade800
      ..style = PaintingStyle.fill;

    // Trunk
    canvas.drawRect(
      const Rect.fromLTWH(14, 8, 4, 8),
      treePaint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(14, 8, 4, 8),
      borderPaint,
    );

    // Leaves
    canvas.drawRect(
      const Rect.fromLTWH(10, 4, 12, 4),
      treePaint,
    );
    canvas.drawRect(
      const Rect.fromLTWH(10, 4, 12, 4),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
