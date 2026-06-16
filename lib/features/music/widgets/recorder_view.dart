import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/data/music_models.dart';
import 'package:app/features/music/widgets/recording_tile.dart';
import 'package:app/features/music/widgets/waveform_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Voice-recorder tab: record controls up top, saved memos below.
class RecorderView extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final Duration elapsed;
  final List<VoiceRecording> recordings;
  final String? playingRecordingId;
  final bool isRecordingPlaying;
  final double playbackProgress;

  final VoidCallback onStart;
  final VoidCallback onPauseResume;
  final VoidCallback onStop;
  final VoidCallback onDiscard;
  final void Function(VoiceRecording) onPlayPauseRecording;
  final void Function(VoiceRecording) onMoreRecording;

  const RecorderView({
    super.key,
    required this.isRecording,
    required this.isPaused,
    required this.elapsed,
    required this.recordings,
    required this.playingRecordingId,
    required this.isRecordingPlaying,
    required this.playbackProgress,
    required this.onStart,
    required this.onPauseResume,
    required this.onStop,
    required this.onDiscard,
    required this.onPlayPauseRecording,
    required this.onMoreRecording,
  });

  String _formatTimer(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  String get _statusLabel {
    if (!isRecording) return 'Tap to record a voice memo';
    return isPaused ? 'Paused' : 'Recording…';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 140.h),
      children: [
        // Recorder card
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 26.h),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: isRecording && !isPaused
                      ? AppColors.danger
                      : AppColors.textTertiary,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                _formatTimer(elapsed),
                style: TextStyle(
                  fontSize: 44.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              SizedBox(height: 18.h),
              LiveWaveform(
                isActive: isRecording && !isPaused,
                color: AppColors.accent,
                height: 56,
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isRecording) ...[
                    _SmallCircleButton(
                      icon: Icons.delete_outline_rounded,
                      color: AppColors.textSecondary,
                      bg: AppColors.bgElevated,
                      onTap: onDiscard,
                    ),
                    SizedBox(width: 28.w),
                  ],
                  _MainRecordButton(
                    isRecording: isRecording,
                    isPaused: isPaused,
                    onTap: isRecording ? onPauseResume : onStart,
                  ),
                  if (isRecording) ...[
                    SizedBox(width: 28.w),
                    _SmallCircleButton(
                      icon: Icons.check_rounded,
                      color: AppColors.bgBase,
                      bg: AppColors.accent,
                      onTap: onStop,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: 28.h),

        // Recordings header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recordings',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${recordings.length}',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        if (recordings.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: Center(
              child: Text(
                'No recordings yet',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
              ),
            ),
          )
        else
          ...recordings.map(
            (r) => RecordingTile(
              recording: r,
              isCurrent: r.id == playingRecordingId,
              isPlaying: isRecordingPlaying,
              progress: playbackProgress,
              onPlayPause: () => onPlayPauseRecording(r),
              onMore: () => onMoreRecording(r),
            ),
          ),
      ],
    );
  }
}

class _MainRecordButton extends StatelessWidget {
  final bool isRecording;
  final bool isPaused;
  final VoidCallback onTap;

  const _MainRecordButton({
    required this.isRecording,
    required this.isPaused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = isRecording && !isPaused;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 76.w,
        height: 76.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bgElevated,
          border: Border.all(
            color: active ? AppColors.danger : AppColors.accent,
            width: 2.5.w,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.danger.withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isRecording ? (isPaused ? 30.w : 26.w) : 56.w,
            height: isRecording ? (isPaused ? 30.w : 26.w) : 56.w,
            decoration: BoxDecoration(
              color: active ? AppColors.danger : AppColors.accent,
              borderRadius: BorderRadius.circular(
                isRecording && !isPaused ? 6.r : 100.r,
              ),
            ),
            child: !isRecording
                ? Icon(Icons.mic_rounded, color: AppColors.bgBase, size: 28.sp)
                : (isPaused
                    ? Icon(Icons.play_arrow_rounded, color: AppColors.bgBase, size: 18.sp)
                    : null),
          ),
        ),
      ),
    );
  }
}

class _SmallCircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _SmallCircleButton({
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22.sp),
      ),
    );
  }
}
