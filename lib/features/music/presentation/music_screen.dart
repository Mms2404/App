import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/domain/entities/music_entities.dart';
import 'package:app/features/music/presentation/cubit/music_cubit.dart';
import 'package:app/features/music/widgets/add_track_sheet.dart';
import 'package:app/features/music/widgets/category_chips.dart';
import 'package:app/features/music/widgets/library_view.dart';
import 'package:app/features/music/widgets/mini_player.dart';
import 'package:app/features/music/widgets/now_playing_sheet.dart';
import 'package:app/features/music/widgets/recorder_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Music feature main screen. Expects [MusicCubit] to already be provided
/// above it (by MusicGateway) — does NOT create its own BlocProvider.
/// [onExit] routes back to the splash screen, per app_home's "exit button
/// leads to starting page" requirement.
class MusicScreenWithExit extends StatefulWidget {
  final VoidCallback onExit;
  const MusicScreenWithExit({super.key, required this.onExit});

  @override
  State<MusicScreenWithExit> createState() => _MusicScreenWithExitState();
}

class _MusicScreenWithExitState extends State<MusicScreenWithExit> {
  int _tab = 0; // 0 = Library, 1 = Recorder


  void _openNowPlaying(MusicCubit cubit, MusicState s) {
    if (s.currentTrack == null) return;
    final queue = s.tracks;
    final i = queue.indexWhere((t) => t.id == s.currentTrack!.id);
    showNowPlayingSheet(
      context,
      queue: queue,
      currentIndex: i < 0 ? 0 : i,
      isPlaying: s.isPlaying,
      position: s.position,
      shuffle: s.shuffle,
      repeat: s.repeat,
      onPlayPause: () { cubit.togglePlayPause(); Navigator.of(context).pop(); _openNowPlaying(cubit, cubit.state); },
      onNext: () { cubit.next(); Navigator.of(context).pop(); _openNowPlaying(cubit, cubit.state); },
      onPrev: () { cubit.prev(); Navigator.of(context).pop(); _openNowPlaying(cubit, cubit.state); },
      onSeek: (v) { cubit.seek(v); Navigator.of(context).pop(); _openNowPlaying(cubit, cubit.state); },
      onToggleShuffle: () { cubit.toggleShuffle(); Navigator.of(context).pop(); _openNowPlaying(cubit, cubit.state); },
      onToggleRepeat: () { cubit.toggleRepeat(); Navigator.of(context).pop(); _openNowPlaying(cubit, cubit.state); },
      onSelectTrack: (i) { Navigator.of(context).pop(); cubit.onTrackTap(queue[i]); _openNowPlaying(cubit, cubit.state); },
    );
  }

  void _onMoreRecording(MusicCubit cubit, VoiceRecording recording) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20.sp),
              title: Text('Delete', style: TextStyle(fontSize: 14.sp, color: AppColors.danger)),
              onTap: () {
                cubit.deleteRecording(recording);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onLongPressTrack(MusicCubit cubit, Track track) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: EdgeInsets.all(16.w),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20.sp),
              title: Text('Delete', style: TextStyle(fontSize: 14.sp, color: AppColors.danger)),
              onTap: () {
                cubit.deleteTrack(track);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicCubit>();

    return BlocBuilder<MusicCubit, MusicState>(
      builder: (context, s) {
        final track = s.currentTrack;
        final totalSeconds = track?.duration.inSeconds ?? 1;
        final progress = track == null ? 0.0 : s.position.inSeconds / totalSeconds;

        return Scaffold(
          backgroundColor: AppColors.bgBase,
          resizeToAvoidBottomInset: false,
          body: OrbBackground(
            blurIntensity: 1.7,
            brightness: 0.5,
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Music',
                                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary, letterSpacing: -0.4)),
                            Row(
                              children: [
                                // Exit — returns to the splash/starting page.
                                GestureDetector(
                                  onTap: widget.onExit,
                                  child: Container(
                                    width: 40.w, height: 40.w,
                                    margin: EdgeInsets.only(right: 10.w),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSurface, shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.border)),
                                    child: Icon(Icons.logout_rounded,
                                        color: AppColors.textSecondary, size: 18.sp),
                                  ),
                                ),
                                // Add track — open access, no auth.
                                GestureDetector(
                                  onTap: () => showAddTrackSheet(context, cubit),
                                  child: Container(
                                    width: 40.w, height: 40.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.bgSurface, shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.border)),
                                    child: Icon(Icons.add_rounded, color: AppColors.accent, size: 20.sp),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: _SegmentedTabs(
                          index: _tab,
                          labels: const ['Library', 'Recorder'],
                          onChanged: (i) => setState(() => _tab = i),
                        ),
                      ),
                      if (_tab == 0) ...[
                        SizedBox(height: 10.h),
                        CategoryChips(
                          selected: s.filterCategory,
                          onSelected: (c) => cubit.filterByCategory(c),
                        ),
                      ],
                      SizedBox(height: 8.h),
                      Expanded(
                        child: IndexedStack(
                          index: _tab,
                          sizing: StackFit.expand,
                          children: [
                            s.loadingTracks
                                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                                : LibraryView(
                                    tracks: s.tracks,
                                    currentTrackId: track?.id,
                                    isPlaying: s.isPlaying,
                                    onTrackTap: cubit.onTrackTap,
                                    onTrackLongPress: (t) => _onLongPressTrack(cubit, t),
                                  ),
                            RecorderView(
                              isRecording: s.isRecording,
                              isPaused: s.isRecordingPaused,
                              elapsed: s.recordElapsed,
                              recordings: s.recordings,
                              playingRecordingId: s.playingRecordingId,
                              isRecordingPlaying: s.isRecordingPlaybackPlaying,
                              playbackProgress: s.recordingPlaybackProgress,
                              onStart: cubit.startRecording,
                              onPauseResume: cubit.togglePauseRecording,
                              onStop: () => cubit.stopAndSaveRecording(),
                              onDiscard: cubit.discardRecording,
                              onPlayPauseRecording: cubit.playRecording,
                              onMoreRecording: (r) => _onMoreRecording(cubit, r),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (track != null && _tab == 0)
                    Positioned(
                      left: 20.w, right: 20.w, bottom: 96.h,
                      child: MiniPlayer(
                        track: track,
                        isPlaying: s.isPlaying,
                        progress: progress.clamp(0, 1),
                        onTap: () => _openNowPlaying(cubit, s),
                        onPlayPause: cubit.togglePlayPause,
                        onNext: cubit.next,
                      ),
                    ),
                  if (s.error != null)
                    Positioned(
                      left: 20.w, right: 20.w, bottom: 16.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.danger.withValues(alpha:0.4)),
                        ),
                        child: Text(s.error!,
                            style: TextStyle(fontSize: 12.5.sp, color: AppColors.danger)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;
  const _SegmentedTabs({required this.index, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface, borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border)),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic,
            alignment: Alignment(index == 0 ? -1 : 1, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / labels.length,
              child: Container(decoration: BoxDecoration(
                  color: AppColors.accent, borderRadius: BorderRadius.circular(10.r))),
            ),
          ),
          Row(
            children: List.generate(labels.length, (i) {
              final selected = i == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(labels[i],
                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w600,
                            color: selected ? AppColors.bgBase : AppColors.textSecondary)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
