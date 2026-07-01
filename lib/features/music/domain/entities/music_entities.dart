// Pure Dart domain entities — no Supabase/Flutter package imports beyond Color.
// NOTE: named Track / VoiceRecording (not TrackEntity / VoiceRecordingEntity)
// on purpose — these are drop-in replacements for the old mock models so
// the existing widget files (LibraryView, TrackTile, RecorderView,
// RecordingTile, MiniPlayer, NowPlayingSheet) need ZERO changes.
import 'package:flutter/material.dart' show Color;

enum SongCategory { tamil ,english ,powerful ,chinese ,korean ,mm ,recording ,other }

extension SongCategoryX on SongCategory {
  String get label => switch (this) {
        SongCategory.tamil => 'Tamil',
        SongCategory.english => 'English',
        SongCategory.powerful => 'Powerful',
        SongCategory.chinese => 'Chinese',
        SongCategory.korean => 'Korean',
        SongCategory.mm => 'Mmmm..',
        SongCategory.recording => 'Recordings',
        SongCategory.other => 'Other',
      };

  static SongCategory fromString(String s) => SongCategory.values
      .firstWhere((c) => c.name == s, orElse: () => SongCategory.other);
}

class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final SongCategory category;
  final String storagePath; // path in Supabase "songs" bucket
  final String? streamUrl;  // resolved public url
  final List<Color> artwork;
  final bool isRecording;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.category,
    required this.storagePath,
    this.streamUrl,
    this.artwork = const [Color(0xFF5DE6C8), Color(0xFF3CB8E6)],
    this.isRecording = false,
  });
}

class VoiceRecording {
  final String id;
  final String title;
  final DateTime createdAt;
  final Duration duration;
  final String storagePath;
  final String? streamUrl;
  final List<double> levels;

  const VoiceRecording({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    required this.storagePath,
    this.streamUrl,
    this.levels = const [],
  });
}

/// Deterministic waveform generator — same as the old mock file, kept so
/// freshly-fetched recordings still get a non-flat preview before we have
/// real amplitude analysis.
List<double> generateLevels(int count, {int seed = 0}) {
  final levels = <double>[];
  for (var i = 0; i < count; i++) {
    final a = (seed + i) * 12.9898;
    final b = (seed + i) * 78.233;
    final raw = (((a + b) * 43758.5453) % 1).abs();
    levels.add(0.18 + raw * 0.82);
  }
  return levels;
}

