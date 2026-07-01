// MUSIC CUBIT
// -----------------------------------------------------------------------------
// Replaces _MusicState's setState/Timer fakes with real audio playback
// (just_audio) and real recording (record package), backed by Supabase.
// Method names mirror the old _MusicState methods so wiring into the
// existing UI (music_screen.dart, recorder_view.dart, library_view.dart)
// is mostly a search-and-replace of setState calls → cubit calls.
//
// Packages needed: just_audio, record, path_provider, supabase_flutter
// -----------------------------------------------------------------------------

import 'dart:async';
import 'dart:io';
import 'package:app/features/music/domain/entities/music_entities.dart';
import 'package:app/features/music/domain/usecases/music_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/utils/logger.dart';

part '../cubit/music_state.dart';

class MusicCubit extends Cubit<MusicState> {
  final FetchTracksUseCase _fetchTracks;
  final AddTrackUseCase _addTrack;
  final DeleteTrackUseCase _deleteTrack;
  final FetchRecordingsUseCase _fetchRecordings;
  final AddRecordingUseCase _addRecording;
  final DeleteRecordingUseCase _deleteRecording;

  final AudioPlayer _player = AudioPlayer();
  final AudioRecorder _recorder = AudioRecorder();

  StreamSubscription? _posSub;
  StreamSubscription? _completeSub;
  Timer? _recordTimer;
  String? _activeRecordPath;

  MusicCubit({
    required FetchTracksUseCase fetchTracks,
    required AddTrackUseCase addTrack,
    required DeleteTrackUseCase deleteTrack,
    required FetchRecordingsUseCase fetchRecordings,
    required AddRecordingUseCase addRecording,
    required DeleteRecordingUseCase deleteRecording,
  })  : _fetchTracks = fetchTracks,
        _addTrack = addTrack,
        _deleteTrack = deleteTrack,
        _fetchRecordings = fetchRecordings,
        _addRecording = addRecording,
        _deleteRecording = deleteRecording,
        super(const MusicState()) {
    _posSub = _player.positionStream.listen((p) => emit(state.copyWith(position: p)));
    _completeSub = _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) _next();
    });
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadTracks({SongCategory? category}) async {
    emit(state.copyWith(loadingTracks: true, clearError: true));
    try {
      final tracks = await _fetchTracks(category: category);
      emit(state.copyWith(
          tracks: tracks, loadingTracks: false, filterCategory: category, clearFilter: category == null));
    } catch (e) {
      emit(state.copyWith(loadingTracks: false, error: 'Could not load songs.'));
    }
  }

  Future<void> loadRecordings() async {
    emit(state.copyWith(loadingRecordings: true, clearError: true));
    try {
      final recs = await _fetchRecordings();
      emit(state.copyWith(recordings: recs, loadingRecordings: false));
    } catch (e) {
      emit(state.copyWith(loadingRecordings: false, error: 'Could not load recordings.'));
    }
  }

  void filterByCategory(SongCategory? category) => loadTracks(category: category);

  // ── Player (mirrors old _MusicState method names) ───────────────────────────

  Future<void> onTrackTap(Track track) async {
    if (state.currentTrack?.id == track.id) return togglePlayPause();
    emit(state.copyWith(currentTrack: track, position: Duration.zero, isPlaying: true));
    try {
      await _player.setUrl(track.streamUrl!);
      await _player.play();
    } catch (e) {
      emit(state.copyWith(error: 'Could not play "${track.title}".', isPlaying: false));
    }
  }

  Future<void> togglePlayPause() async {
    if (state.currentTrack == null) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    emit(state.copyWith(isPlaying: _player.playing));
  }

  Future<void> _next() async {
    final t = state.tracks;
    if (state.currentTrack == null || t.isEmpty) return;
    final i = t.indexWhere((x) => x.id == state.currentTrack!.id);
    if (i == -1) return;

    if (state.shuffle && t.length > 1) {
      final r = (t..shuffle()).first;
      return onTrackTap(r);
    }
    final atEnd = i >= t.length - 1;
    if (atEnd && !state.repeat) {
      emit(state.copyWith(isPlaying: false, position: Duration.zero));
      await _player.pause();
      return;
    }
    return onTrackTap(t[(i + 1) % t.length]);
  }

  Future<void> next() => _next();

  Future<void> prev() async {
    if (state.currentTrack == null) return;
    if (state.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      return;
    }
    final t = state.tracks;
    final i = t.indexWhere((x) => x.id == state.currentTrack!.id);
    if (i == -1) return;
    return onTrackTap(t[(i - 1 + t.length) % t.length]);
  }

  Future<void> seek(double seconds) =>
      _player.seek(Duration(seconds: seconds.round()));

  void toggleShuffle() => emit(state.copyWith(shuffle: !state.shuffle));
  void toggleRepeat()  => emit(state.copyWith(repeat: !state.repeat));

  // ── Add / Delete tracks (open, no auth) ──────────────────────────────────

  Future<void> addTrack({
    required File file,
    required String title,
    required String artist,
    required String album,
    required Duration duration,
    required SongCategory category,
  }) async {
    emit(state.copyWith(isUploading: true, clearError: true));
    try {
      final track = await _addTrack(
        file: file, title: title, artist: artist, album: album,
        duration: duration, category: category,
      );
      emit(state.copyWith(tracks: [...state.tracks, track], isUploading: false));
    } catch (e) {
      log.e('Upload error: $e');
      emit(state.copyWith(isUploading: false, error: 'Upload failed.'));
    }
  }

  Future<void> deleteTrack(Track track) async {
    try {
      await _deleteTrack(track.id, track.storagePath);
      emit(state.copyWith(
        tracks: state.tracks.where((t) => t.id != track.id).toList(),
        clearCurrentTrack: state.currentTrack?.id == track.id,
        isPlaying: state.currentTrack?.id == track.id ? false : state.isPlaying,
      ));
      if (state.currentTrack?.id == track.id) await _player.stop();
    } catch (e) {
      emit(state.copyWith(error: 'Could not delete track.'));
    }
  }

  // ── Recorder (real mic via `record` package) ─────────────────────────────

  Future<void> startRecording() async {
    if (!await _recorder.hasPermission()) {
      emit(state.copyWith(error: 'Microphone permission denied.'));
      return;
    }
    final dir = await getTemporaryDirectory();
    _activeRecordPath = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: _activeRecordPath!);

    emit(state.copyWith(isRecording: true, isRecordingPaused: false, recordElapsed: Duration.zero));
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!state.isRecordingPaused) {
        emit(state.copyWith(recordElapsed: state.recordElapsed + const Duration(seconds: 1)));
      }
    });
  }

  Future<void> togglePauseRecording() async {
    if (state.isRecordingPaused) {
      await _recorder.resume();
    } else {
      await _recorder.pause();
    }
    emit(state.copyWith(isRecordingPaused: !state.isRecordingPaused));
  }

  /// Stops recording and uploads it to Supabase. Anyone can call this.
  Future<void> stopAndSaveRecording({String title = 'Voice memo'}) async {
    _recordTimer?.cancel();
    final path = await _recorder.stop();
    final elapsed = state.recordElapsed;
    emit(state.copyWith(isRecording: false, isRecordingPaused: false));

    if (path == null) return;
    emit(state.copyWith(isUploading: true));
    try {
      final rec = await _addRecording(
        file: File(path), title: title, duration: elapsed,
      );
      emit(state.copyWith(
        recordings: [rec, ...state.recordings],
        isUploading: false,
        recordElapsed: Duration.zero,
      ));
    } catch (e) {
      emit(state.copyWith(isUploading: false, error: 'Could not save recording.'));
    }
  }

  Future<void> discardRecording() async {
    _recordTimer?.cancel();
    await _recorder.stop();
    emit(state.copyWith(isRecording: false, isRecordingPaused: false, recordElapsed: Duration.zero));
  }

  Future<void> deleteRecording(VoiceRecording rec) async {
    try {
      await _deleteRecording(rec.id, rec.storagePath);
      emit(state.copyWith(
        recordings: state.recordings.where((r) => r.id != rec.id).toList(),
        clearPlayingRecording: state.playingRecordingId == rec.id,
      ));
      if (state.playingRecordingId == rec.id) await _player.stop();
    } catch (e) {
      emit(state.copyWith(error: 'Could not delete recording.'));
    }
  }

  // ── Recording playback (preview) ─────────────────────────────────────────

  Future<void> playRecording(VoiceRecording rec) async {
    if (state.playingRecordingId == rec.id) {
      return togglePlayPause(); // reuse same player toggle
    }
    emit(state.copyWith(playingRecordingId: rec.id, isRecordingPlaybackPlaying: true));
    try {
      await _player.setUrl(rec.streamUrl!);
      await _player.play();
    } catch (e) {
      emit(state.copyWith(error: 'Could not play recording.', isRecordingPlaybackPlaying: false));
    }
  }

  @override
  Future<void> close() {
    _posSub?.cancel();
    _completeSub?.cancel();
    _recordTimer?.cancel();
    _player.dispose();
    _recorder.dispose();
    return super.close();
  }
}
