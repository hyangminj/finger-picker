import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const FingerPickerApp());
}

class FingerPickerApp extends StatelessWidget {
  const FingerPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finger Picker',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      ),
      home: const FingerPickerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FingerPickerScreen extends StatefulWidget {
  const FingerPickerScreen({super.key});

  @override
  State<FingerPickerScreen> createState() => _FingerPickerScreenState();
}

enum AppState { idle, touching, countdown, selected }

class Finger {
  final int id;
  Offset position;
  final Color color;
  bool isWinner;
  double scale;
  double opacity;

  Finger({
    required this.id,
    required this.position,
    required this.color,
    this.isWinner = false,
    this.scale = 1.0,
    this.opacity = 1.0,
  });
}

class Particle {
  Offset position;
  final Offset velocity;
  double opacity;
  final double radius;
  final Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.opacity,
    required this.radius,
    required this.color,
  });
}

class _FingerPickerScreenState extends State<FingerPickerScreen>
    with TickerProviderStateMixin {

  // Localization strings
  String get _placeYourFingers {
    final locale = ui.PlatformDispatcher.instance.locale.languageCode;
    return locale == 'ko' ? '손가락을 올려주세요' : 'Place your fingers';
  }

  String get _oneWillBeChosen {
    final locale = ui.PlatformDispatcher.instance.locale.languageCode;
    return locale == 'ko' ? '한 명이 선택됩니다' : 'One will be chosen';
  }

  String get _chosen {
    final locale = ui.PlatformDispatcher.instance.locale.languageCode;
    return locale == 'ko' ? '선택됨' : 'CHOSEN';
  }

  static const List<Color> colors = [
    Color(0xFFFF6B6B),
    Color(0xFF4ECDC4),
    Color(0xFFFFE66D),
    Color(0xFFA78BFA),
    Color(0xFFF472B6),
    Color(0xFF34D399),
    Color(0xFFFB923C),
    Color(0xFF60A5FA),
    Color(0xFFE879F9),
    Color(0xFF2DD4BF),
    Color(0xFFFBBF24),
    Color(0xFF818CF8),
    Color(0xFFF87171),
    Color(0xFF6EE7B7),
    Color(0xFFFCD34D),
    Color(0xFFC084FC),
  ];

  static const double circleRadius = 44.0;
  static const int countdownMs = 2000;

  final Map<int, Finger> _fingers = {};
  int _colorIndex = 0;
  AppState _state = AppState.idle;
  int? _winnerId;
  DateTime? _countdownStart;
  double _countdownProgress = 0.0;

  late AnimationController _pulseController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final List<Particle> _burstParticles = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addListener(() {
        setState(() {});
      });

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // Infinite
    )..repeat();

    _particleController.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    setState(() {
      // Update background particles
      if (_particles.length < 30 && math.Random().nextDouble() < 0.03) {
        final size = MediaQuery.of(context).size;
        _particles.add(Particle(
          position: Offset(
            math.Random().nextDouble() * size.width,
            size.height + 10,
          ),
          velocity: Offset(
            (math.Random().nextDouble() - 0.5) * 0.5,
            -(0.3 + math.Random().nextDouble() * 0.7),
          ),
          opacity: 0.1 + math.Random().nextDouble() * 0.15,
          radius: 1 + math.Random().nextDouble() * 2,
          color: colors[math.Random().nextInt(colors.length)],
        ));
      }

      _particles.removeWhere((p) {
        p.position += p.velocity;
        p.opacity -= 0.0003;
        return p.opacity <= 0 || p.position.dy < -10;
      });

      // Update burst particles
      _burstParticles.removeWhere((p) {
        p.position += p.velocity;
        p.opacity -= 0.01;
        return p.opacity <= 0;
      });
    });
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_state == AppState.selected) {
      _resetAll();
      return;
    }

    final id = event.pointer;
    if (!_fingers.containsKey(id)) {
      final color = colors[_colorIndex % colors.length];
      _colorIndex++;

      setState(() {
        _fingers[id] = Finger(
          id: id,
          position: event.position,
          color: color,
        );
      });

      _updateState();
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_state == AppState.selected) return;

    final id = event.pointer;
    if (_fingers.containsKey(id)) {
      setState(() {
        _fingers[id]!.position = event.position;
      });
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_state == AppState.selected) return;

    final id = event.pointer;
    setState(() {
      _fingers.remove(id);
    });

    _updateState();
  }

  void _updateState() {
    setState(() {
      if (_fingers.isEmpty) {
        _state = AppState.idle;
        _resetCountdown();
      } else if (_fingers.length >= 2 && _state != AppState.selected) {
        if (_state != AppState.countdown) {
          _state = AppState.countdown;
          _startCountdown();
        } else {
          // Reset countdown if new finger joins
          _resetCountdown();
          _startCountdown();
        }
      } else if (_fingers.length == 1 && _state != AppState.selected) {
        _state = AppState.touching;
        _resetCountdown();
      }
    });
  }

  void _startCountdown() {
    _countdownStart = DateTime.now();
    _updateCountdown();
  }

  void _updateCountdown() {
    if (_countdownStart == null || _state != AppState.countdown) return;

    final elapsed = DateTime.now().difference(_countdownStart!).inMilliseconds;
    final progress = (elapsed / countdownMs).clamp(0.0, 1.0);

    setState(() {
      _countdownProgress = progress;
    });

    if (progress >= 1.0) {
      _selectWinner();
    } else {
      Future.delayed(const Duration(milliseconds: 16), _updateCountdown);
    }
  }

  void _resetCountdown() {
    _countdownStart = null;
    setState(() {
      _countdownProgress = 0.0;
    });
  }

  void _selectWinner() {
    if (_fingers.isEmpty) return;

    final ids = _fingers.keys.toList();
    final winnerId = ids[math.Random().nextInt(ids.length)];

    setState(() {
      _state = AppState.selected;
      _winnerId = winnerId;

      // Mark winner
      _fingers[winnerId]!.isWinner = true;
      _fingers[winnerId]!.scale = 1.3;

      // Fade out losers
      for (final id in ids) {
        if (id != winnerId) {
          _fingers[id]!.opacity = 0.0;
          _fingers[id]!.scale = 0.3;
        }
      }
    });

    // Start winner pulse animation
    _pulseController.repeat(reverse: true);

    // Create burst particles
    final winner = _fingers[winnerId]!;
    _createBurstParticles(winner.position, winner.color);
  }

  void _createBurstParticles(Offset position, Color color) {
    const particleCount = 40;
    for (int i = 0; i < particleCount; i++) {
      final angle = (2 * math.pi * i) / particleCount +
          (math.Random().nextDouble() - 0.5) * 0.3;
      final speed = 2.0 + math.Random().nextDouble() * 2.0;

      _burstParticles.add(Particle(
        position: position,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        opacity: 1.0,
        radius: 3 + math.Random().nextDouble() * 6,
        color: color,
      ));
    }
  }

  void _resetAll() {
    setState(() {
      _fingers.clear();
      _burstParticles.clear();
      _state = AppState.idle;
      _winnerId = null;
      _colorIndex = 0;
      _resetCountdown();
    });
    _pulseController.stop();
    _pulseController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Listener(
        onPointerDown: _handlePointerDown,
        onPointerMove: _handlePointerMove,
        onPointerUp: _handlePointerUp,
        onPointerCancel: (event) => _handlePointerUp(PointerUpEvent(
          pointer: event.pointer,
          position: event.position,
        )),
        child: Stack(
          children: [
            // Background particles
            CustomPaint(
              painter: BackgroundPainter(_particles),
              size: Size.infinite,
            ),

            // Prompt text
            if (_state == AppState.idle)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _placeYourFingers,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _oneWillBeChosen,
                      style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 1,
                        color: Colors.white.withOpacity(0.35),
                      ),
                    ),
                  ],
                ),
              ),

            // Burst particles
            CustomPaint(
              painter: BurstParticlePainter(_burstParticles),
              size: Size.infinite,
            ),

            // Finger circles
            ..._fingers.entries.map((entry) {
              final finger = entry.value;
              final pulseScale = finger.isWinner
                  ? 1.0 + (_pulseController.value * 0.15)
                  : 1.0;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 16),
                left: finger.position.dx - circleRadius,
                top: finger.position.dy - circleRadius,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: finger.opacity,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 600),
                    scale: finger.scale * pulseScale,
                    child: Container(
                      width: circleRadius * 2,
                      height: circleRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: const Alignment(-0.3, -0.3),
                          colors: [
                            _lightenColor(finger.color, 0.3),
                            finger.color,
                            _darkenColor(finger.color, 0.2),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: finger.color.withOpacity(0.4),
                            blurRadius: finger.isWinner ? 40 : 30,
                            spreadRadius: finger.isWinner ? 10 : 0,
                          ),
                          BoxShadow(
                            color: finger.color.withOpacity(0.15),
                            blurRadius: 60,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.4, -0.4),
                            radius: 0.5,
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Winner label
            if (_winnerId != null && _fingers.containsKey(_winnerId))
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: _fingers[_winnerId]!.position.dx - 50,
                top: _fingers[_winnerId]!.position.dy + circleRadius + 20,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _state == AppState.selected ? 1.0 : 0.0,
                  child: SizedBox(
                    width: 100,
                    child: Text(
                      _chosen,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                        color: _fingers[_winnerId]!.color,
                        shadows: [
                          Shadow(
                            color: _fingers[_winnerId]!.color.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Countdown ring
            if (_state == AppState.countdown)
              Positioned(
                top: 24,
                right: 24,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: CustomPaint(
                    painter: CountdownRingPainter(_countdownProgress),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _lightenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darkenColor(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

class BackgroundPainter extends CustomPainter {
  final List<Particle> particles;

  BackgroundPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}

class BurstParticlePainter extends CustomPainter {
  final List<Particle> particles;

  BurstParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          particle.radius * 2,
        );

      canvas.drawCircle(particle.position, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(BurstParticlePainter oldDelegate) => true;
}

class CountdownRingPainter extends CustomPainter {
  final double progress;

  CountdownRingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track circle
    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CountdownRingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
