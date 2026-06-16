import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/data/music_models.dart';
import 'package:app/features/music/widgets/track_tile.dart';
import 'package:app/features/music/widgets/waveform_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String _formatDate(DateTime d) {
  final now = DateTime.now();
  final diff = now.difference(d);
  if (diff.inDays == 0) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return 'Today · $h:$m';
  } else if (diff.inDays == 1) {
    return 'Yesterday';
  }
  return '${diff.inDays} days ago';
}

/// A single saved recording row with inline waveform + playback controls.
class RecordingTile extends StatelessWidget {
  final VoiceRecording recording;
  final bool isPlaying;
  final bool isCurrent;
  final double progress;
  final VoidCallback onPlayPause;
  final VoidCallback onMore;

  const RecordingTile({
    super.key,
    required this.recording,
    required this.onPlayPause,
    required this.onMore,
    this.isPlaying = false,
    this.isCurrent = false,
    this.progress = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isCurrent ? AppColors.accent.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onPlayPause,
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isCurrent ? AppColors.accent : AppColors.bgElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrent && isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isCurrent ? AppColors.bgBase : AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recording.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      formatDuration(recording.duration),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  _formatDate(recording.createdAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                SizedBox(height: 6.h),
                Waveform(
                  levels: recording.levels,
                  progress: isCurrent ? progress : 0,
                  height: 22,
                  barWidth: 2.5,
                  gap: 2,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMore,
            icon: Icon(Icons.more_vert_rounded, color: AppColors.textTertiary, size: 18.sp),
          ),
        ],
      ),
    );
  }
}
