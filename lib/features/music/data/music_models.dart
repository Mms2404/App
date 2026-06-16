import 'package:flutter/material.dart';

/// A song / audio file in the local library.
class Track {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;

  /// Two-color gradient used for the placeholder artwork tile.
  final List<Color> artwork;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.artwork,
  });
}

/// A saved voice recording.
class VoiceRecording {
  final String id;
  final String title;
  final DateTime createdAt;
  final Duration duration;

  /// Pre-baked waveform levels (0.0 - 1.0) used for the static preview.
  final List<double> levels;

  const VoiceRecording({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.duration,
    required this.levels,
  });
}

/// Deterministic "random" waveform generator so previews don't look like
/// a flat line but also don't require any audio analysis.
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

/// Mock library — swap for real device-scanned tracks later.
final List<Track> mockLibrary = [
  Track(
    id: 't1',
    title: 'Midnight Drive',
    artist: 'Nova Patel',
    album: 'Late Hours',
    duration: const Duration(minutes: 3, seconds: 42),
    artwork: const [Color(0xFF5DE6C8), Color(0xFF3CB8E6)],
  ),
  Track(
    id: 't2',
    title: 'Glass Horizon',
    artist: 'Kilo East',
    album: 'Glass Horizon',
    duration: const Duration(minutes: 4, seconds: 5),
    artwork: const [Color(0xFF503CDC), Color(0xFF148CFF)],
  ),
  Track(
    id: 't3',
    title: 'Paper Lanterns',
    artist: 'Mira & The Tides',
    album: 'Paper Lanterns',
    duration: const Duration(minutes: 2, seconds: 58),
    artwork: const [Color(0xFFEB8B6E), Color(0xFFFACC15)],
  ),
  Track(
    id: 't4',
    title: 'Static Bloom',
    artist: 'Nova Patel',
    album: 'Late Hours',
    duration: const Duration(minutes: 3, seconds: 17),
    artwork: const [Color(0xFF1FA088), Color(0xFF5DE6C8)],
  ),
  Track(
    id: 't5',
    title: 'Slow Channel',
    artist: 'Reverie Bay',
    album: 'Open Water',
    duration: const Duration(minutes: 5, seconds: 1),
    artwork: const [Color(0xFF60A5FA), Color(0xFF503CDC)],
  ),
  Track(
    id: 't6',
    title: 'Amber Static',
    artist: 'Kilo East',
    album: 'Glass Horizon',
    duration: const Duration(minutes: 3, seconds: 29),
    artwork: const [Color(0xFFFACC15), Color(0xFFEB8B6E)],
  ),
];

/// Mock saved recordings — swap for files read from storage later.
final List<VoiceRecording> mockRecordings = [
  VoiceRecording(
    id: 'r1',
    title: 'Voice memo',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    duration: const Duration(seconds: 47),
    levels: generateLevels(40, seed: 3),
  ),
  VoiceRecording(
    id: 'r2',
    title: 'Idea for the bridge',
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    duration: const Duration(minutes: 1, seconds: 12),
    levels: generateLevels(40, seed: 11),
  ),
  VoiceRecording(
    id: 'r3',
    title: 'Voice memo',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    duration: const Duration(seconds: 23),
    levels: generateLevels(40, seed: 27),
  ),
];
