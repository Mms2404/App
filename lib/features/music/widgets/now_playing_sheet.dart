import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/domain/entities/music_entities.dart';
import 'package:app/features/music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Opens the full "now playing" player as a draggable bottom sheet.
Future<void> showNowPlayingSheet(
  BuildContext context, {
  required List<Track> queue,
  required int currentIndex,
  required bool isPlaying,
  required Duration position,
  required bool shuffle,
  required bool repeat,
  required VoidCallback onPlayPause,
  required VoidCallback onNext,
  required VoidCallback onPrev,
  required ValueChanged<double> onSeek,
  required VoidCallback onToggleShuffle,
  required VoidCallback onToggleRepeat,
  required ValueChanged<int> onSelectTrack,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _NowPlayingContent(
            scrollController: scrollController,
            queue: queue,
            currentIndex: currentIndex,
            isPlaying: isPlaying,
            position: position,
            shuffle: shuffle,
            repeat: repeat,
            onPlayPause: onPlayPause,
            onNext: onNext,
            onPrev: onPrev,
            onSeek: onSeek,
            onToggleShuffle: onToggleShuffle,
            onToggleRepeat: onToggleRepeat,
            onSelectTrack: onSelectTrack,
          );
        },
      );
    },
  );
}

class _NowPlayingContent extends StatelessWidget {
  final ScrollController scrollController;
  final List<Track> queue;
  final int currentIndex;
  final bool isPlaying;
  final Duration position;
  final bool shuffle;
  final bool repeat;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final ValueChanged<double> onSeek;
  final VoidCallback onToggleShuffle;
  final VoidCallback onToggleRepeat;
  final ValueChanged<int> onSelectTrack;

  const _NowPlayingContent({
    required this.scrollController,
    required this.queue,
    required this.currentIndex,
    required this.isPlaying,
    required this.position,
    required this.shuffle,
    required this.repeat,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrev,
    required this.onSeek,
    required this.onToggleShuffle,
    required this.onToggleRepeat,
    required this.onSelectTrack,
  });

  @override
  Widget build(BuildContext context) {
    final track = queue[currentIndex];
    final totalSeconds = track.duration.inSeconds.toDouble().clamp(1, double.infinity);
    final posSeconds = position.inSeconds.toDouble().clamp(0, totalSeconds);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Now Playing',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: AppColors.textTertiary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary, size: 26.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Artwork
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24.r),
                gradient: LinearGradient(
                  colors: track.artwork,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: track.artwork.last.withValues(alpha: 0.35),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.music_note_rounded,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 72.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 28.h),

          // Title + artist + like
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${track.artist} · ${track.album}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(Icons.favorite_border_rounded,
                    color: AppColors.textSecondary, size: 19.sp),
              ),
            ],
          ),
          SizedBox(height: 18.h),

          // Progress slider
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
              value: posSeconds.toDouble(),
              min: 0,
              max: totalSeconds.toDouble(),
              onChanged: onSeek,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(position),
                    style: TextStyle(fontSize: 11.5.sp, color: AppColors.textTertiary)),
                Text(formatDuration(track.duration),
                    style: TextStyle(fontSize: 11.5.sp, color: AppColors.textTertiary)),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Transport controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ToggleIcon(
                icon: Icons.shuffle_rounded,
                active: shuffle,
                onTap: onToggleShuffle,
              ),
              IconButton(
                onPressed: onPrev,
                icon: Icon(Icons.skip_previous_rounded,
                    color: AppColors.textPrimary, size: 34.sp),
              ),
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 68.w,
                  height: 68.w,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.bgBase,
                    size: 34.sp,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: Icon(Icons.skip_next_rounded,
                    color: AppColors.textPrimary, size: 34.sp),
              ),
              _ToggleIcon(
                icon: Icons.repeat_rounded,
                active: repeat,
                onTap: onToggleRepeat,
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // Up next
          Text(
            'Up Next',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 8.h),
          ...List.generate(queue.length, (i) {
            if (i == currentIndex) return const SizedBox.shrink();
            return TrackTile(
              track: queue[i],
              isCurrent: false,
              onTap: () => onSelectTrack(i),
            );
          }),
        ],
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
      icon: Icon(
        icon,
        color: active ? AppColors.accent : AppColors.textTertiary,
        size: 21.sp,
      ),
    );
  }
}
