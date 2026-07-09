import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/presentation/cubit/music_cubit.dart';
import 'package:app/features/music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

String formatDuration(Duration d) {
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Reads live state from [MusicCubit] so play/pause icons update correctly
/// without needing the sheet to be closed and reopened.
Future<void> showNowPlayingSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<MusicCubit>(),
      child: const _NowPlayingSheet(),
    ),
  );
}

class _NowPlayingSheet extends StatelessWidget {
  const _NowPlayingSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => BlocBuilder<MusicCubit, MusicState>(
        builder: (context, s) {
          final cubit = context.read<MusicCubit>();
          final track = s.currentTrack;
          if (track == null) {
            Navigator.of(context).pop();
            return const SizedBox.shrink();
          }
          final queue = s.tracks;
          final i = queue.indexWhere((t) => t.id == track.id);
          final totalSeconds = track.duration.inSeconds.toDouble().clamp(1.0, double.infinity);
          final posSeconds = s.position.inSeconds.toDouble().clamp(0.0, totalSeconds);

          return Container(
            decoration: BoxDecoration(
              color: AppColors.bgElevated,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36.w, height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border, borderRadius: BorderRadius.circular(2.r)),
                  ),
                ),
                SizedBox(height: 28.h),

                // Artwork
                Center(
                  child: Container(
                    width: 220.w, height: 220.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22.r),
                      gradient: LinearGradient(
                        colors: track.artwork,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.music_note_rounded,
                        color: Colors.white.withValues(alpha: 0.5), size: 64.sp),
                  ),
                ),
                SizedBox(height: 28.h),

                // Title + artist
                Text(track.title,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary, letterSpacing: -0.3)),
                SizedBox(height: 4.h),
                Text(track.artist,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
                SizedBox(height: 24.h),

                // Slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3.h,
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withValues(alpha: 0.15),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
                  ),
                  child: Slider(
                    value: posSeconds,
                    min: 0,
                    max: totalSeconds,
                    onChanged: (v) => cubit.seek(v),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(formatDuration(s.position),
                        style: TextStyle(fontSize: 11.5.sp, color: AppColors.textTertiary)),
                    Text(formatDuration(track.duration),
                        style: TextStyle(fontSize: 11.5.sp, color: AppColors.textTertiary)),
                  ]),
                ),
                SizedBox(height: 12.h),

                // Controls — reads s.isPlaying directly so always in sync
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  _ToggleIcon(icon: Icons.shuffle_rounded, active: s.shuffle,
                      onTap: cubit.toggleShuffle),
                  IconButton(
                    onPressed: cubit.prev,
                    icon: Icon(Icons.skip_previous_rounded,
                        color: AppColors.textPrimary, size: 34.sp)),
                  GestureDetector(
                    onTap: cubit.togglePlayPause,
                    child: Container(
                      width: 68.w, height: 68.w,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle),
                      child: Icon(
                        s.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppColors.bgBase, size: 34.sp,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: cubit.next,
                    icon: Icon(Icons.skip_next_rounded,
                        color: AppColors.textPrimary, size: 34.sp)),
                  _ToggleIcon(icon: Icons.repeat_rounded, active: s.repeat,
                      onTap: cubit.toggleRepeat),
                ]),
                SizedBox(height: 32.h),

                // Up next
                Text('Up Next',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,
                        letterSpacing: 1.2, color: AppColors.textTertiary)),
                SizedBox(height: 8.h),
                ...List.generate(queue.length, (idx) {
                  if (idx == i) return const SizedBox.shrink();
                  return TrackTile(
                    track: queue[idx],
                    isCurrent: false,
                    onTap: () => cubit.onTrackTap(queue[idx]),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ToggleIcon({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: active ? AppColors.accent : AppColors.textTertiary, size: 21.sp),
    );
  }
}