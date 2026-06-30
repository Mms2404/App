import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shown for ~2s when entering the Music feature. Animates "diveIn" in
/// letter-by-letter, then calls [onDone] to proceed into the app.
class MusicSplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const MusicSplashScreen({super.key, required this.onDone});

  @override
  State<MusicSplashScreen> createState() => _MusicSplashScreenState();
}

class _MusicSplashScreenState extends State<MusicSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _text = 'diveIn';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_text.length, (i) {
                final start = i / _text.length;
                final end = start + (1 / _text.length);
                final t = Curves.easeOut.transform(
                  ((_ctrl.value - start) / (end - start)).clamp(0.0, 1.0),
                );
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * 12.h),
                    child: Text(
                      _text[i],
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5.w,
                        color: i == 4 // capital "I" in diveIn — accent it
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
