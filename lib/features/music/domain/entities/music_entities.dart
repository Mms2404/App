// Pure Dart domain entities — no Supabase/Flutter package imports beyond Color.
// NOTE: named Track / VoiceRecording (not TrackEntity / VoiceRecordingEntity)
// on purpose — these are drop-in replacements for the old mock models so
// the existing widget files (LibraryView, TrackTile, RecorderView,
// RecordingTile, MiniPlayer, NowPlayingSheet) need ZERO changes.
import 'package:flutter/material.dart' show Color;

enum SongCategory { tamil, english, powerful, chinese, korean, mm, recording, other }

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

  /// Per-category gradient used in artwork boxes (TrackTile, MiniPlayer, sheet).
  List<Color> get gradient => switch (this) {
        SongCategory.tamil     => [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
        SongCategory.english   => [const Color(0xFF5DE6C8), const Color(0xFF3CB8E6)],
        SongCategory.powerful  => [const Color(0xFF7B2FF7), const Color(0xFFE040FB)],
        SongCategory.chinese   => [const Color(0xFFFF4E50), const Color(0xFFF9D423)],
        SongCategory.korean    => [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
        SongCategory.mm        => [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
        SongCategory.recording => [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
        SongCategory.other     => [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
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
  final String storagePath;
  final String? streamUrl;
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
    this.isRecording = false,
  });

  /// Gradient colors derived from category — consistent across all widgets.
  List<Color> get artwork => category.gradient;
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

