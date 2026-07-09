import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusicSplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const MusicSplashScreen({super.key, required this.onDone});

  @override
  State<MusicSplashScreen> createState() => _MusicSplashScreenState();
}

class _MusicSplashScreenState extends State<MusicSplashScreen>
    with TickerProviderStateMixin {
  // ── Letter animation ──────────────────────────────────────────────────────
  late final AnimationController _letterCtrl;

  // ── Swipe/reveal ─────────────────────────────────────────────────────────
  late final AnimationController _revealCtrl;
  late final Animation<double> _rippleRadius;
  late final Animation<double> _rippleOpacity;

  bool _showHint      = false;
  bool _revealling    = false;
  Offset _swipeOrigin = Offset.zero;

  static const _text = 'diveIn';

  @override
  void initState() {
    super.initState();

    // Letters
    _letterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward().whenComplete(() {
        if (mounted) setState(() => _showHint = true);
      });

    // Ripple reveal
    _revealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 520));
    _rippleRadius = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _revealCtrl, curve: Curves.easeInCubic));
    _rippleOpacity = Tween<double>(begin: 0.08, end: 0).animate(
        CurvedAnimation(parent: _revealCtrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _letterCtrl.dispose();
    _revealCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSwipe(Offset localPosition) async {
    if (_revealling || !_showHint) return;
    setState(() {
      _revealling   = true;
      _swipeOrigin  = localPosition;
      _showHint     = false;
    });

    await _revealCtrl.forward();
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onHorizontalDragEnd: (d) =>
          _onSwipe(d.localPosition ?? Offset(size.width / 2, size.height / 2)),
      onVerticalDragEnd: (d) =>
          _onSwipe(d.localPosition ?? Offset(size.width / 2, size.height / 2)),
      child: Scaffold(
        backgroundColor: AppColors.bgBase,
        body: AnimatedBuilder(
          animation: Listenable.merge([_letterCtrl, _revealCtrl]),
          builder: (context, _) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // ── Background stays dark ─────────────────────────────────
                Container(color: AppColors.bgBase),

                // ── Ripple accent circle expanding from swipe point ────────
                if (_revealling)
                  CustomPaint(
                    painter: _RipplePainter(
                      origin: _swipeOrigin,
                      fraction: _rippleRadius.value,
                      maxRadius: size.longestSide * 1.5,
                      color: AppColors.accent,
                      opacity: _rippleOpacity.value,
                    ),
                  ),

                // ── White hard-reveal circle (the "enter" flash) ──────────
                if (_revealling)
                  CustomPaint(
                    painter: _RipplePainter(
                      origin: _swipeOrigin,
                      fraction: Curves.easeInQuart
                          .transform(_rippleRadius.value)
                          .clamp(0, 1),
                      maxRadius: size.longestSide * 1.6,
                      color: Colors.black,
                      opacity: 1.0,
                    ),
                  ),

                // ── "diveIn" letters ─────────────────────────────────────
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(_text.length, (i) {
                          final start = i / _text.length;
                          final end   = start + 1 / _text.length;
                          final t = Curves.easeOut.transform(
                            ((_letterCtrl.value - start) / (end - start))
                                .clamp(0.0, 1.0),
                          );
                          // On reveal, letters fade out
                          final exitT = _revealling
                              ? (1 - _rippleRadius.value).clamp(0.0, 1.0)
                              : 1.0;

                          return Opacity(
                            opacity: (t * exitT).clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, (1 - t) * 12.h),
                              child: Text(
                                _text[i],
                                style: TextStyle(
                                  fontSize: 38.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5.w,
                                  color: i == 4
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 48.h),

                      // Swipe hint
                      AnimatedOpacity(
                        opacity: _showHint ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: _SwipeHint(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Custom painter — expanding circle from swipe origin ───────────────────────

class _RipplePainter extends CustomPainter {
  final Offset origin;
  final double fraction;
  final double maxRadius;
  final Color color;
  final double opacity;

  const _RipplePainter({
    required this.origin,
    required this.fraction,
    required this.maxRadius,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (fraction <= 0) return;
    final paint = Paint()
      ..color = color.withOpacity(opacity.clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(origin, maxRadius * fraction, paint);
  }

  @override
  bool shouldRepaint(_RipplePainter old) =>
      old.fraction != fraction || old.opacity != opacity;
}

// ── Animated swipe hint with pulsing arrow ────────────────────────────────────

class _SwipeHint extends StatefulWidget {
  @override
  State<_SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<_SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.12)
        .animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scale,
          builder: (_, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: Icon(
            Icons.swipe_rounded,
            color: AppColors.accent.withOpacity(0.7),
            size: 28.sp,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'swipe anywhere to enter',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12.sp,
            color: AppColors.textTertiary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}