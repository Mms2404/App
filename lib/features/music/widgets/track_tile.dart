import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/data/music_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

/// A single row in the track library list.
class TrackTile extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final bool isCurrent;
  final VoidCallback onTap;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.isPlaying = false,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            children: [
              _Artwork(track: track, isCurrent: isCurrent, isPlaying: isPlaying),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? AppColors.accent : AppColors.textPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                formatDuration(track.duration),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textTertiary,
                ),
              ),
              SizedBox(width: 4.w),
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  isCurrent && isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: isCurrent ? AppColors.accent : AppColors.textSecondary,
                  size: 22.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  final Track track;
  final bool isCurrent;
  final bool isPlaying;

  const _Artwork({required this.track, required this.isCurrent, required this.isPlaying});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        gradient: LinearGradient(
          colors: track.artwork,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: isCurrent
            ? Border.all(color: AppColors.accent, width: 1.5.w)
            : null,
      ),
      child: Center(
        child: isCurrent && isPlaying
            ? _PlayingIndicator()
            : Icon(
                Icons.music_note_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 20.sp,
              ),
      ),
    );
  }
}

/// Tiny animated equalizer bars shown on the currently playing track.
class _PlayingIndicator extends StatefulWidget {
  @override
  State<_PlayingIndicator> createState() => _PlayingIndicatorState();
}

class _PlayingIndicatorState extends State<_PlayingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = (_controller.value + i * 0.33) % 1.0;
            final wobble = 1 - (t * 2 - 1).abs(); // 0..1, peaks mid-cycle
            final h = 7 + wobble * 7; // 7-14
            return Container(
              width: 3.w,
              height: h.h,
              margin: EdgeInsets.symmetric(horizontal: 1.5.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2.r),
              ),
            );
          }),
        );
      },
    );
  }
}
