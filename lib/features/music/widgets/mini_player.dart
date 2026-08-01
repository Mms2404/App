import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/presentation/cubit/music_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Reads live state from [MusicCubit] so play/pause icon always stays in sync.
/// No longer accepts isPlaying/progress as params — pulls them from Cubit.
class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, s) {
        final track = s.currentTrack;
        if (track == null) return const SizedBox.shrink();
        final cubit = context.read<MusicCubit>();
        final totalMs = track.duration.inMilliseconds.toDouble();
        final progress = totalMs == 0 ? 0.0
            : (s.position.inMilliseconds / totalMs).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 64.h,
            decoration: BoxDecoration(
              color: AppColors.bgElevated.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 18, offset: const Offset(0, 8))],
            ),
            child: Stack(children: [
              // Progress bar along top edge
              Positioned(
                top: 0, left: 12.w, right: 12.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2.5.h,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Row(children: [
                  Container(
                    width: 42.w, height: 42.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11.r),
                      gradient: LinearGradient(
                          colors: track.artwork,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                    ),
                    child: Icon(Icons.music_note_rounded,
                        color: Colors.white.withValues(alpha: 0.85), size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary)),
                      SizedBox(height: 2.h),
                      Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary)),
                    ],
                  )),
                  // Icons read s.isPlaying — always correct
                  IconButton(
                    onPressed: cubit.togglePlayPause,
                    icon: Icon(
                      s.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.textPrimary, size: 26.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: cubit.next,
                    icon: Icon(Icons.skip_next_rounded,
                        color: AppColors.textSecondary, size: 22.sp),
                  ),
                  SizedBox(width: 4.w),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }
}
