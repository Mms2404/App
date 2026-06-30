import 'dart:io';
import 'package:app/features/music/data/music_repository.dart';
import 'package:app/features/music/domain/entities/music_entities.dart';

class FetchTracksUseCase {
  final MusicRepository _repo;
  FetchTracksUseCase(this._repo);
  Future<List<Track>> call({SongCategory? category}) =>
      _repo.fetchTracks(category: category);
}

class AddTrackUseCase {
  final MusicRepository _repo;
  AddTrackUseCase(this._repo);
  Future<Track> call({
    required File file,
    required String title,
    required String artist,
    required String album,
    required Duration duration,
    required SongCategory category,
  }) =>
      _repo.addTrack(
        file: file, title: title, artist: artist, album: album,
        duration: duration, category: category,
      );
}

class DeleteTrackUseCase {
  final MusicRepository _repo;
  DeleteTrackUseCase(this._repo);
  Future<void> call(String id, String storagePath) =>
      _repo.deleteTrack(id, storagePath);
}

class FetchRecordingsUseCase {
  final MusicRepository _repo;
  FetchRecordingsUseCase(this._repo);
  Future<List<VoiceRecording>> call() => _repo.fetchRecordings();
}

class AddRecordingUseCase {
  final MusicRepository _repo;
  AddRecordingUseCase(this._repo);
  Future<VoiceRecording> call({
    required File file,
    required String title,
    required Duration duration,
  }) =>
      _repo.addRecording(file: file, title: title, duration: duration);
}

class DeleteRecordingUseCase {
  final MusicRepository _repo;
  DeleteRecordingUseCase(this._repo);
  Future<void> call(String id, String storagePath) =>
      _repo.deleteRecording(id, storagePath);
}
