part of 'music_cubit.dart';

class MusicState {
  final List<Track> tracks;
  final List<VoiceRecording> recordings;
  final SongCategory? filterCategory;
  final bool loadingTracks;
  final bool loadingRecordings;
  final String? error;

  // Player
  final Track? currentTrack;
  final bool isPlaying;
  final Duration position;
  final bool shuffle;
  final bool repeat;

  // Recorder
  final bool isRecording;
  final bool isRecordingPaused;
  final Duration recordElapsed;

  // Recording playback (preview before/after saving)
  final String? playingRecordingId;
  final bool isRecordingPlaybackPlaying;
  final double recordingPlaybackProgress;

  // Busy flags for add/delete actions (drives button spinners)
  final bool isUploading;

  const MusicState({
    this.tracks = const [],
    this.recordings = const [],
    this.filterCategory,
    this.loadingTracks = false,
    this.loadingRecordings = false,
    this.error,
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.shuffle = false,
    this.repeat = false,
    this.isRecording = false,
    this.isRecordingPaused = false,
    this.recordElapsed = Duration.zero,
    this.playingRecordingId,
    this.isRecordingPlaybackPlaying = false,
    this.recordingPlaybackProgress = 0,
    this.isUploading = false,
  });

  MusicState copyWith({
    List<Track>? tracks,
    List<VoiceRecording>? recordings,
    SongCategory? filterCategory,
    bool clearFilter = false,
    bool? loadingTracks,
    bool? loadingRecordings,
    String? error,
    bool clearError = false,
    Track? currentTrack,
    bool clearCurrentTrack = false,
    bool? isPlaying,
    Duration? position,
    bool? shuffle,
    bool? repeat,
    bool? isRecording,
    bool? isRecordingPaused,
    Duration? recordElapsed,
    String? playingRecordingId,
    bool clearPlayingRecording = false,
    bool? isRecordingPlaybackPlaying,
    double? recordingPlaybackProgress,
    bool? isUploading,
  }) =>
      MusicState(
        tracks: tracks ?? this.tracks,
        recordings: recordings ?? this.recordings,
        filterCategory: clearFilter ? null : (filterCategory ?? this.filterCategory),
        loadingTracks: loadingTracks ?? this.loadingTracks,
        loadingRecordings: loadingRecordings ?? this.loadingRecordings,
        error: clearError ? null : (error ?? this.error),
        currentTrack: clearCurrentTrack ? null : (currentTrack ?? this.currentTrack),
        isPlaying: isPlaying ?? this.isPlaying,
        position: position ?? this.position,
        shuffle: shuffle ?? this.shuffle,
        repeat: repeat ?? this.repeat,
        isRecording: isRecording ?? this.isRecording,
        isRecordingPaused: isRecordingPaused ?? this.isRecordingPaused,
        recordElapsed: recordElapsed ?? this.recordElapsed,
        playingRecordingId:
            clearPlayingRecording ? null : (playingRecordingId ?? this.playingRecordingId),
        isRecordingPlaybackPlaying:
            isRecordingPlaybackPlaying ?? this.isRecordingPlaybackPlaying,
        recordingPlaybackProgress:
            recordingPlaybackProgress ?? this.recordingPlaybackProgress,
        isUploading: isUploading ?? this.isUploading,
      );
}
