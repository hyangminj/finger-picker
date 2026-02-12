// Finger Picker - A Chwazi-like finger picker app
// Copyright (C) 2026 HyangMin Jeong
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:finger_picker_flutter/l10n/generated/app_localizations.dart';

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
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

  // Particle constants
  static const int maxBackgroundParticles = 30;
  static const double particleSpawnProbability = 0.03;
  static const double particleOpacityDecay = 0.0003;
  static const int burstParticleCount = 40;
  static const double burstParticleOpacityDecay = 0.01;

  // Velocity constants
  static const double particleVelocityRange = 0.5;
  static const double particleMinVerticalVelocity = 0.3;
  static const double particleMaxVerticalVelocity = 0.7;

  final Map<int, Finger> _fingers = {};
  int _colorIndex = 0;
  AppState _state = AppState.idle;
  int? _winnerId;
  double _countdownProgress = 0.0;

  late AnimationController _pulseController;
  late AnimationController _countdownController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];
  final List<Particle> _burstParticles = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: countdownMs),
    )..addListener(_updateCountdownProgress);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(days: 1), // Infinite
    )..repeat();

    _particleController.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countdownController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _updateParticles() {
    setState(() {
      // Update background particles
      if (_particles.length < maxBackgroundParticles &&
          math.Random().nextDouble() < particleSpawnProbability) {
        final size = MediaQuery.of(context).size;
        _particles.add(Particle(
          position: Offset(
            math.Random().nextDouble() * size.width,
            size.height + 10,
          ),
          velocity: Offset(
            (math.Random().nextDouble() - 0.5) * particleVelocityRange,
            -(particleMinVerticalVelocity +
                math.Random().nextDouble() * particleMaxVerticalVelocity),
          ),
          opacity: 0.1 + math.Random().nextDouble() * 0.15,
          radius: 1 + math.Random().nextDouble() * 2,
          color: colors[math.Random().nextInt(colors.length)],
        ));
      }

      _particles.removeWhere((p) {
        p.position += p.velocity;
        p.opacity -= particleOpacityDecay;
        return p.opacity <= 0 || p.position.dy < -10;
      });

      // Update burst particles
      _burstParticles.removeWhere((p) {
        p.position += p.velocity;
        p.opacity -= burstParticleOpacityDecay;
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
    _countdownController.forward(from: 0.0);
  }

  void _updateCountdownProgress() {
    setState(() {
      _countdownProgress = _countdownController.value;
    });

    if (_countdownController.value >= 1.0 && _state == AppState.countdown) {
      _selectWinner();
    }
  }

  void _resetCountdown() {
    _countdownController.stop();
    _countdownController.reset();
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
    for (int i = 0; i < burstParticleCount; i++) {
      final angle = (2 * math.pi * i) / burstParticleCount +
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
    final l10n = AppLocalizations.of(context)!;

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
            ParticleCanvas(particles: _particles),

            // Prompt text
            if (_state == AppState.idle)
              IdlePromptWidget(l10n: l10n),

            // Burst particles
            BurstParticleCanvas(particles: _burstParticles),

            // Finger circles
            ..._fingers.entries.map((entry) {
              final finger = entry.value;
              return FingerCircleWidget(
                key: ValueKey(finger.id),
                finger: finger,
                pulseController: finger.isWinner ? _pulseController : null,
                circleRadius: circleRadius,
              );
            }),

            // Winner label
            if (_winnerId != null && _fingers.containsKey(_winnerId))
              WinnerLabelWidget(
                finger: _fingers[_winnerId]!,
                l10n: l10n,
                circleRadius: circleRadius,
                isVisible: _state == AppState.selected,
              ),

            // Countdown ring
            if (_state == AppState.countdown)
              CountdownRingWidget(progress: _countdownProgress),
          ],
        ),
      ),
    );
  }
}

// Widget Components

class FingerCircleWidget extends StatelessWidget {
  final Finger finger;
  final AnimationController? pulseController;
  final double circleRadius;

  const FingerCircleWidget({
    super.key,
    required this.finger,
    required this.pulseController,
    required this.circleRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 16),
      left: finger.position.dx - circleRadius,
      top: finger.position.dy - circleRadius,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: finger.opacity,
        child: pulseController != null
            ? AnimatedBuilder(
                animation: pulseController!,
                builder: (context, child) {
                  final pulseScale = 1.0 + (pulseController!.value * 0.15);
                  return AnimatedScale(
                    duration: const Duration(milliseconds: 600),
                    scale: finger.scale * pulseScale,
                    child: child,
                  );
                },
                child: _buildCircle(),
              )
            : AnimatedScale(
                duration: const Duration(milliseconds: 600),
                scale: finger.scale,
                child: _buildCircle(),
              ),
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
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

class ParticleCanvas extends StatelessWidget {
  final List<Particle> particles;

  const ParticleCanvas({
    super.key,
    required this.particles,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(particles),
      size: Size.infinite,
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  final List<Particle> particles;

  _BackgroundPainter(this.particles);

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
  bool shouldRepaint(_BackgroundPainter oldDelegate) => true;
}

class BurstParticleCanvas extends StatelessWidget {
  final List<Particle> particles;

  const BurstParticleCanvas({
    super.key,
    required this.particles,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BurstParticlePainter(particles),
      size: Size.infinite,
    );
  }
}

class _BurstParticlePainter extends CustomPainter {
  final List<Particle> particles;

  _BurstParticlePainter(this.particles);

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
  bool shouldRepaint(_BurstParticlePainter oldDelegate) => true;
}

class CountdownRingWidget extends StatelessWidget {
  final double progress;

  const CountdownRingWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 24,
      right: 24,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(
          painter: _CountdownRingPainter(progress),
        ),
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;

  _CountdownRingPainter(this.progress);

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
  bool shouldRepaint(_CountdownRingPainter oldDelegate) =>
      progress != oldDelegate.progress;
}

class WinnerLabelWidget extends StatelessWidget {
  final Finger finger;
  final AppLocalizations l10n;
  final double circleRadius;
  final bool isVisible;

  const WinnerLabelWidget({
    super.key,
    required this.finger,
    required this.l10n,
    required this.circleRadius,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      left: finger.position.dx - 50,
      top: finger.position.dy + circleRadius + 20,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isVisible ? 1.0 : 0.0,
        child: SizedBox(
          width: 100,
          child: Text(
            l10n.chosen,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 3,
              color: finger.color,
              shadows: [
                Shadow(
                  color: finger.color.withOpacity(0.5),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IdlePromptWidget extends StatelessWidget {
  final AppLocalizations l10n;

  const IdlePromptWidget({
    super.key,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.placeYourFingers,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              letterSpacing: 2,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.oneWillBeChosen,
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}
