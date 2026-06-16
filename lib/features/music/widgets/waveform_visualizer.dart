import 'dart:async';
import 'dart:math' as math;

import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Static bar-style waveform. [progress] (0-1) paints the portion of the
/// bars that have already "played" / been recorded in the accent color.
class Waveform extends StatelessWidget {
  final List<double> levels;
  final double progress;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final double gap;

  const Waveform({
    super.key,
    required this.levels,
    this.progress = 0,
    this.height = 32,
    this.activeColor = AppColors.accent,
    this.inactiveColor = AppColors.textTertiary,
    this.barWidth = 3,
    this.gap = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, height.h),
            painter: _WaveformPainter(
              levels: levels,
              progress: progress,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              barWidth: barWidth.w,
              gap: gap.w,
            ),
          );
        },
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> levels;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final double gap;

  _WaveformPainter({
    required this.levels,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
    required this.barWidth,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.isEmpty) return;

    final totalBarWidth = barWidth + gap;
    final maxBars = (size.width / totalBarWidth).floor();
    final count = math.min(levels.length, maxBars > 0 ? maxBars : levels.length);

    final activeCount = (count * progress).round();

    for (var i = 0; i < count; i++) {
      final level = levels[i].clamp(0.05, 1.0);
      final barHeight = size.height * level;
      final dx = i * totalBarWidth;
      final rect = Rect.fromLTWH(
        dx,
        (size.height - barHeight) / 2,
        barWidth,
        barHeight,
      );
      final paint = Paint()
        ..color = i < activeCount ? activeColor : inactiveColor.withValues(alpha: 0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(barWidth / 2)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.levels != levels ||
      old.progress != progress ||
      old.activeColor != activeColor ||
      old.inactiveColor != inactiveColor;
}

/// Live animated waveform — bars jitter continuously while [isActive] is
/// true (used while recording) and settle to a low idle state otherwise.
class LiveWaveform extends StatefulWidget {
  final bool isActive;
  final int barCount;
  final double height;
  final Color color;

  const LiveWaveform({
    super.key,
    required this.isActive,
    this.barCount = 32,
    this.height = 64,
    this.color = AppColors.accent,
  });

  @override
  State<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<LiveWaveform> {
  late List<double> _levels;
  Timer? _timer;
  final _rand = math.Random();

  @override
  void initState() {
    super.initState();
    _levels = List.generate(widget.barCount, (_) => 0.08);
    _maybeStart();
  }

  @override
  void didUpdateWidget(LiveWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      _maybeStart();
    }
  }

  void _maybeStart() {
    _timer?.cancel();
    if (widget.isActive) {
      _timer = Timer.periodic(const Duration(milliseconds: 90), (_) {
        setState(() {
          for (var i = 0; i < _levels.length; i++) {
            final target = 0.12 + _rand.nextDouble() * 0.88;
            // ease toward target so it doesn't look too jumpy
            _levels[i] = _levels[i] + (target - _levels[i]) * 0.6;
          }
        });
      });
    } else {
      setState(() {
        for (var i = 0; i < _levels.length; i++) {
          _levels[i] = 0.08;
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height.h,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final level in _levels)
            AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              curve: Curves.easeOut,
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              width: 4.w,
              height: widget.height.h * level.clamp(0.06, 1.0),
              decoration: BoxDecoration(
                color: widget.isActive
                    ? widget.color
                    : widget.color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
        ],
      ),
    );
  }
}
