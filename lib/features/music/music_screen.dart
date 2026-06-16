import 'dart:async';
import 'dart:math' as math;

import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/data/music_models.dart';
import 'package:app/features/music/widgets/library_view.dart';
import 'package:app/features/music/widgets/mini_player.dart';
import 'package:app/features/music/widgets/now_playing_sheet.dart';
import 'package:app/features/music/widgets/recorder_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Music feature entry point — local library player on one tab,
/// voice recorder on the other. Replaces the placeholder `Music` widget.
class Music extends StatefulWidget {
  const Music({super.key});

  @override
  State<Music> createState() => _MusicState();
}

class _MusicState extends State<Music> {
  // ----- Tabs -----
  int _tab = 0; // 0 = Library, 1 = Recorder

  // ----- Player state -----
  final List<Track> _queue = List.of(mockLibrary);
  int? _currentIndex;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  bool _shuffle = false;
  bool _repeat = false;
  Timer? _playbackTimer;

  // ----- Recorder state -----
  bool _isRecording = false;
  bool _isRecordingPaused = false;
  Duration _recordElapsed = Duration.zero;
  Timer? _recordTimer;
  final List<VoiceRecording> _recordings = List.of(mockRecordings);

  String? _playingRecordingId;
  bool _isRecordingPlaybackPlaying = false;
  double _recordingPlaybackProgress = 0;
  Timer? _recordingPlaybackTimer;

  Track? get _currentTrack =>
      _currentIndex == null ? null : _queue[_currentIndex!];

  // -------------------- Player logic --------------------

  void _onTrackTap(Track track) {
    final index = _queue.indexWhere((t) => t.id == track.id);
    if (index == -1) return;

    if (_currentIndex == index) {
      _togglePlayPause();
      return;
    }

    setState(() {
      _currentIndex = index;
      _position = Duration.zero;
      _isPlaying = true;
    });
    _startPlaybackTimer();
  }

  void _togglePlayPause() {
    if (_currentIndex == null) return;
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _startPlaybackTimer();
    } else {
      _playbackTimer?.cancel();
    }
  }

  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final track = _currentTrack;
      if (track == null || !_isPlaying) return;
      setState(() {
        final next = _position + const Duration(seconds: 1);
        if (next >= track.duration) {
          _next();
        } else {
          _position = next;
        }
      });
    });
  }

  void _next() {
    if (_currentIndex == null) return;
    setState(() {
      if (_shuffle && _queue.length > 1) {
        final rand = math.Random();
        int newIndex;
        do {
          newIndex = rand.nextInt(_queue.length);
        } while (newIndex == _currentIndex);
        _currentIndex = newIndex;
      } else {
        final atEnd = _currentIndex! >= _queue.length - 1;
        if (atEnd && !_repeat) {
          _isPlaying = false;
          _playbackTimer?.cancel();
          _currentIndex = 0;
          _position = Duration.zero;
          return;
        }
        _currentIndex = (_currentIndex! + 1) % _queue.length;
      }
      _position = Duration.zero;
    });
  }

  void _prev() {
    if (_currentIndex == null) return;
    setState(() {
      if (_position > const Duration(seconds: 3)) {
        _position = Duration.zero;
      } else {
        _currentIndex = (_currentIndex! - 1 + _queue.length) % _queue.length;
        _position = Duration.zero;
      }
    });
  }

  void _seek(double seconds) {
    setState(() => _position = Duration(seconds: seconds.round()));
  }

  void _openNowPlaying() {
    if (_currentIndex == null) return;
    showNowPlayingSheet(
      context,
      queue: _queue,
      currentIndex: _currentIndex!,
      isPlaying: _isPlaying,
      position: _position,
      shuffle: _shuffle,
      repeat: _repeat,
      onPlayPause: () {
        _togglePlayPause();
        Navigator.of(context).pop();
        _openNowPlaying();
      },
      onNext: () {
        _next();
        Navigator.of(context).pop();
        _openNowPlaying();
      },
      onPrev: () {
        _prev();
        Navigator.of(context).pop();
        _openNowPlaying();
      },
      onSeek: (v) {
        _seek(v);
        Navigator.of(context).pop();
        _openNowPlaying();
      },
      onToggleShuffle: () {
        setState(() => _shuffle = !_shuffle);
        Navigator.of(context).pop();
        _openNowPlaying();
      },
      onToggleRepeat: () {
        setState(() => _repeat = !_repeat);
        Navigator.of(context).pop();
        _openNowPlaying();
      },
      onSelectTrack: (i) {
        Navigator.of(context).pop();
        _onTrackTap(_queue[i]);
        _openNowPlaying();
      },
    );
  }

  // -------------------- Recorder logic --------------------

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _isRecordingPaused = false;
      _recordElapsed = Duration.zero;
    });
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRecordingPaused) return;
      setState(() => _recordElapsed += const Duration(seconds: 1));
    });
  }

  void _pauseResumeRecording() {
    setState(() => _isRecordingPaused = !_isRecordingPaused);
  }

  void _stopRecording() {
    _recordTimer?.cancel();
    if (_recordElapsed.inSeconds > 0) {
      final recording = VoiceRecording(
        id: 'r${DateTime.now().millisecondsSinceEpoch}',
        title: 'Voice memo',
        createdAt: DateTime.now(),
        duration: _recordElapsed,
        levels: generateLevels(40, seed: _recordElapsed.inSeconds),
      );
      setState(() {
        _recordings.insert(0, recording);
        _isRecording = false;
        _isRecordingPaused = false;
        _recordElapsed = Duration.zero;
      });
    } else {
      setState(() {
        _isRecording = false;
        _isRecordingPaused = false;
      });
    }
  }

  void _discardRecording() {
    _recordTimer?.cancel();
    setState(() {
      _isRecording = false;
      _isRecordingPaused = false;
      _recordElapsed = Duration.zero;
    });
  }

  void _playPauseRecording(VoiceRecording recording) {
    if (_playingRecordingId == recording.id) {
      setState(() => _isRecordingPlaybackPlaying = !_isRecordingPlaybackPlaying);
      if (_isRecordingPlaybackPlaying) {
        _startRecordingPlaybackTimer(recording);
      } else {
        _recordingPlaybackTimer?.cancel();
      }
      return;
    }

    _recordingPlaybackTimer?.cancel();
    setState(() {
      _playingRecordingId = recording.id;
      _isRecordingPlaybackPlaying = true;
      _recordingPlaybackProgress = 0;
    });
    _startRecordingPlaybackTimer(recording);
  }

  void _startRecordingPlaybackTimer(VoiceRecording recording) {
    _recordingPlaybackTimer?.cancel();
    final totalMs = recording.duration.inMilliseconds.clamp(1, double.infinity);
    _recordingPlaybackTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isRecordingPlaybackPlaying) return;
      setState(() {
        _recordingPlaybackProgress += 200 / totalMs;
        if (_recordingPlaybackProgress >= 1) {
          _recordingPlaybackProgress = 0;
          _isRecordingPlaybackPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  void _onMoreRecording(VoiceRecording recording) {
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
              leading: Icon(Icons.drive_file_rename_outline_rounded,
                  color: AppColors.textSecondary, size: 20.sp),
              title: Text('Rename',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(Icons.share_rounded, color: AppColors.textSecondary, size: 20.sp),
              title: Text('Share',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary)),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20.sp),
              title: Text('Delete',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.danger)),
              onTap: () {
                setState(() {
                  _recordings.removeWhere((r) => r.id == recording.id);
                  if (_playingRecordingId == recording.id) {
                    _playingRecordingId = null;
                    _isRecordingPlaybackPlaying = false;
                    _recordingPlaybackTimer?.cancel();
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _recordTimer?.cancel();
    _recordingPlaybackTimer?.cancel();
    super.dispose();
  }

  // -------------------- Build --------------------

  @override
  Widget build(BuildContext context) {
    final track = _currentTrack;
    final totalSeconds = track?.duration.inSeconds ?? 1;
    final progress = track == null ? 0.0 : _position.inSeconds / totalSeconds;

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
                        Text(
                          'Music',
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.4,
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
                          child: Icon(
                            Icons.equalizer_rounded,
                            color: AppColors.textSecondary,
                            size: 18.sp,
                          ),
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
                  SizedBox(height: 8.h),
                  Expanded(
                    child: IndexedStack(
                      index: _tab,
                      sizing: StackFit.expand,
                      children: [
                        LibraryView(
                          tracks: _queue,
                          currentTrackId: track?.id,
                          isPlaying: _isPlaying,
                          onTrackTap: _onTrackTap,
                        ),
                        RecorderView(
                          isRecording: _isRecording,
                          isPaused: _isRecordingPaused,
                          elapsed: _recordElapsed,
                          recordings: _recordings,
                          playingRecordingId: _playingRecordingId,
                          isRecordingPlaying: _isRecordingPlaybackPlaying,
                          playbackProgress: _recordingPlaybackProgress,
                          onStart: _startRecording,
                          onPauseResume: _pauseResumeRecording,
                          onStop: _stopRecording,
                          onDiscard: _discardRecording,
                          onPlayPauseRecording: _playPauseRecording,
                          onMoreRecording: _onMoreRecording,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Floating mini player, sits above the main bottom nav bar.
              if (track != null && _tab == 0)
                Positioned(
                  left: 20.w,
                  right: 20.w,
                  bottom: 96.h,
                  child: MiniPlayer(
                    track: track,
                    isPlaying: _isPlaying,
                    progress: progress.clamp(0, 1),
                    onTap: _openNowPlaying,
                    onPlayPause: _togglePlayPause,
                    onNext: _next,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill-shaped segmented control used to switch between Library and
/// Recorder.
class _SegmentedTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment(index == 0 ? -1 : 1, 0),
            child: FractionallySizedBox(
              widthFactor: 1 / labels.length,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
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
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: selected ? AppColors.bgBase : AppColors.textSecondary,
                      ),
                    ),
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
