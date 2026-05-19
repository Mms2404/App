import 'dart:math' as math;
import 'package:app/core/utils/logger.dart';
import 'package:flutter/material.dart';

class OrbBackground extends StatefulWidget {
  final Widget child;

  /// 1.0 = default. Bump to 1.5–2.0 for form screens to push the orb
  /// further into the background.
  final double blurIntensity;

  /// 1.0 = default. Drop to 0.6–0.8 for form screens to dim the orb.
  final double brightness;

  /// Base radius of the orb in logical pixels.
  final double baseRadius;

  const OrbBackground({
    Key? key,
    required this.child,
    this.blurIntensity = 1.0,
    this.brightness = 1.0,
    this.baseRadius = 155,
  }) : super(key: key);

  @override
  State<OrbBackground> createState() => _OrbBackgroundState();
}

class _OrbBackgroundState extends State<OrbBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Offset _orbPos = const Offset(-999, -999);
  Offset _targetPos = const Offset(-999, -999);
  Offset _velocity = Offset.zero;
  bool _initialized = false;

  double _pulse = 0;
  double _drift = 0;
  bool _moving = false;
  DateTime _lastInteraction = DateTime.now();

  static const double _friction = 0.92;
  static const double _lerp = 0.018;

  // @override
  // void initState() {
  //   super.initState();
  //   _controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(days: 999),
  //   )..addListener(_tick)..repeat();
  // }

  @override
  void initState() {
  super.initState();
  _controller = AnimationController(
    vsync: this,
    duration: const Duration(days: 999),
  )..addListener(_tick)..repeat();
  
  // Initialize position after first frame when size is known
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    if (!_initialized && !size.isEmpty) {
      _initialized = true;
      final start = Offset(size.width * 0.12, size.height * 0.82);
      setState(() {
        _orbPos = start;
        _targetPos = start;
      });
    }
  });
}

  void _tick() {
    if (!_initialized) return;

    if (DateTime.now().difference(_lastInteraction).inMilliseconds > 800) {
      _moving = false;
    }

    _pulse += _moving ? 0.014 : 0.025;
    _drift += 0.008;

    final driftX = math.sin(_drift * 0.7) * 14 + math.sin(_drift * 1.9) * 5;
    final driftY = math.cos(_drift * 0.5) * 10 + math.cos(_drift * 2.3) * 4;

    final dx = (_targetPos.dx + driftX) - _orbPos.dx;
    final dy = (_targetPos.dy + driftY) - _orbPos.dy;

    _velocity = Offset(
      _velocity.dx * _friction + dx * _lerp,
      _velocity.dy * _friction + dy * _lerp,
    );

    setState(() {
      _orbPos += _velocity;
    });
  }

  void _setTarget(Offset pos) {
    _targetPos = pos;
    _moving = true;
    _lastInteraction = DateTime.now();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return LayoutBuilder(
  //     builder: (context, constraints) {
  //       // _initDefaultPos(constraints.biggest);

  //       return Listener(
  //         behavior: HitTestBehavior.translucent,
  //         onPointerDown: (e) => _setTarget(e.localPosition),
  //         onPointerMove: (e) => _setTarget(e.localPosition),
  //         child: Stack(
  //           children: [
  //             Positioned.fill(
  //               child: Container(color: const Color(0xFF0E0E0E)),
  //             ),
  //             Positioned.fill(
  //               child: IgnorePointer(
  //                 child: CustomPaint(
  //                   painter: _OrbPainter(
  //                     position: _orbPos,
  //                     pulse: _pulse,
  //                     baseRadius: widget.baseRadius,
  //                     blurIntensity: widget.blurIntensity,
  //                     brightness: widget.brightness,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             widget.child,
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

@override
Widget build(BuildContext context) {
  return SizedBox.expand(
    child: LayoutBuilder(
      builder: (context, constraints) {
        // log.d('🟡 LayoutBuilder constraints: $constraints');
        // Defer init to first frame with known size
        if (!_initialized && !constraints.biggest.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _initialized) return;
            _initialized = true;
            final size = constraints.biggest;
            final start = Offset(size.width * 0.12, size.height * 0.82);
            setState(() {
              _orbPos = start;
              _targetPos = start;
            });
          });
        }

        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (e) => _setTarget(e.localPosition),
          onPointerMove: (e) => _setTarget(e.localPosition),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: const Color(0xFF0E0E0E)),
              IgnorePointer(
                child: CustomPaint(
                  painter: _OrbPainter(
                    position: _orbPos,
                    pulse: _pulse,
                    baseRadius: widget.baseRadius,
                    blurIntensity: widget.blurIntensity,
                    brightness: widget.brightness,
                  ),
                ),
              ),
              widget.child,
            ],
          ),
        );
      },
    ),
  );
}
}

class _OrbPainter extends CustomPainter {
  final Offset position;
  final double pulse;
  final double baseRadius;
  final double blurIntensity;
  final double brightness;

  _OrbPainter({
    required this.position,
    required this.pulse,
    required this.baseRadius,
    required this.blurIntensity,
    required this.brightness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // log.d('🔵 Painter called, position: $position');
  if (position.dx < -100) {
    log.d('  ↑ skipped: position invalid');
    return;
  }

    final breathe = math.sin(pulse) * 0.10;
    final r = baseRadius * (1 + breathe);

    // Layer 1 — wide outer atmospheric glow
    final outerR = r * 1.6;
    final outerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FFB4).withValues(alpha: 0.18 * brightness),
          const Color(0xFF00C8FF).withValues(alpha: 0.09 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: outerR))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 48 * blurIntensity);
    canvas.drawCircle(position, outerR, outerPaint);

    // Layer 2 — main body
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00FFC8).withValues(alpha: 0.72 * brightness),
          const Color(0xFF00DCFF).withValues(alpha: 0.52 * brightness),
          const Color(0xFF148CFF).withValues(alpha: 0.28 * brightness),
          const Color(0xFF503CDC).withValues(alpha: 0.10 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.65, 0.88, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: r))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 22 * blurIntensity);
    canvas.drawCircle(position, r, bodyPaint);

    // Layer 3 — inner bloom (no hard center)
    final innerR = r * 0.55;
    final innerPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF78FFE6).withValues(alpha: 0.60 * brightness),
          const Color(0xFF3CE6FF).withValues(alpha: 0.32 * brightness),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: position, radius: innerR))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 * blurIntensity);
    canvas.drawCircle(position, innerR, innerPaint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.position != position ||
      old.pulse != pulse ||
      old.blurIntensity != blurIntensity ||
      old.brightness != brightness;
}