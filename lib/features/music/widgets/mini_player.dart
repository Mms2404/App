import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/data/music_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Compact "now playing" bar shown above the bottom navigation while a
/// track is loaded. Tapping it expands the full [NowPlayingSheet].
class MiniPlayer extends StatelessWidget {
  final Track track;
  final bool isPlaying;
  final double progress; // 0-1
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;

  const MiniPlayer({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.progress,
    required this.onTap,
    required this.onPlayPause,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64.h,
        decoration: BoxDecoration(
          color: AppColors.bgElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // progress indicator along the top edge
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: 2.5.h,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11.r),
                      gradient: LinearGradient(
                        colors: track.artwork,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onPlayPause,
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.textPrimary,
                      size: 26.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: onNext,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: AppColors.textSecondary,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
