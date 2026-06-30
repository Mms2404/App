// MUSIC REPOSITORY — fully open, no auth (per app plan).
// -----------------------------------------------------------------------------
// Supabase setup needed:
//
// table: songs
//   id            uuid primary key default gen_random_uuid()
//   title         text not null
//   artist        text not null
//   album         text not null
//   duration_secs int  not null
//   category      text not null            -- SongCategory.name, e.g. 'lofi'
//   storage_path  text not null            -- e.g. "neon_drift.mp3"
//   is_recording  boolean not null default false
//   created_at    timestamptz default now()
//
// table: recordings
//   id            uuid primary key default gen_random_uuid()
//   title         text not null
//   duration_secs int  not null
//   storage_path  text not null
//   created_at    timestamptz default now()
//
// storage bucket: "songs"  (public, used for both regular tracks and
//                            uploaded voice recordings — same bucket,
//                            recordings table just tracks recorder-specific
//                            metadata like auto waveform regen on fetch)
//
// RLS: fully open — anyone can select/insert/delete (no auth in this app).
//   alter table songs enable row level security;
//   create policy "anyone" on songs for all using (true) with check (true);
//   (same for recordings)
// -----------------------------------------------------------------------------

import 'dart:io';
import 'package:app/features/music/domain/entities/music_entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MusicRepository {
  final SupabaseClient _client;
  MusicRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String _urlFor(String path) =>
      _client.storage.from('songs').getPublicUrl(path);

  // ── Tracks ────────────────────────────────────────────────────────────────

  Future<List<Track>> fetchTracks({SongCategory? category}) async {
    var query = _client.from('songs').select();
    if (category != null) query = query.eq('category', category.name);
    final rows = await query.order('created_at', ascending: true);

    return (rows as List).map((r) {
      return Track(
        id: r['id'] as String,
        title: r['title'] as String,
        artist: r['artist'] as String,
        album: r['album'] as String,
        duration: Duration(seconds: r['duration_secs'] as int),
        category: SongCategoryX.fromString(r['category'] as String),
        storagePath: r['storage_path'] as String,
        streamUrl: _urlFor(r['storage_path'] as String),
        isRecording: (r['is_recording'] as bool?) ?? false,
      );
    }).toList();
  }

  /// Upload a new song file + insert its row. Anyone can call this (no auth).
  Future<Track> addTrack({
    required File file,
    required String title,
    required String artist,
    required String album,
    required Duration duration,
    required SongCategory category,
  }) async {
    final ext = file.path.split('.').last;
    final path = '${DateTime.now().millisecondsSinceEpoch}_$title.$ext'
        .replaceAll(' ', '_');

    await _client.storage.from('songs').upload(path, file);

    final row = await _client
        .from('songs')
        .insert({
          'title': title,
          'artist': artist,
          'album': album,
          'duration_secs': duration.inSeconds,
          'category': category.name,
          'storage_path': path,
          'is_recording': false,
        })
        .select()
        .single();

    return Track(
      id: row['id'] as String,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      category: category,
      storagePath: path,
      streamUrl: _urlFor(path),
    );
  }

  /// Open delete — no ownership check, anyone can delete any track.
  Future<void> deleteTrack(String id, String storagePath) async {
    await _client.storage.from('songs').remove([storagePath]);
    await _client.from('songs').delete().eq('id', id);
  }

  // ── Voice recordings ─────────────────────────────────────────────────────

  Future<List<VoiceRecording>> fetchRecordings() async {
    final rows = await _client
        .from('recordings')
        .select()
        .order('created_at', ascending: false);

    return (rows as List).map((r) {
      return VoiceRecording(
        id: r['id'] as String,
        title: r['title'] as String,
        createdAt: DateTime.parse(r['created_at'] as String),
        duration: Duration(seconds: r['duration_secs'] as int),
        storagePath: r['storage_path'] as String,
        streamUrl: _urlFor(r['storage_path'] as String),
      );
    }).toList();
  }

  /// Upload a freshly recorded clip. Anyone can call this (no auth).
  /// Also inserts into `songs` with category=recording + is_recording=true
  /// so recordings can optionally surface in the main library too.
  Future<VoiceRecording> addRecording({
    required File file,
    required String title,
    required Duration duration,
  }) async {
    final path = 'rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _client.storage.from('songs').upload(path, file);

    final row = await _client
        .from('recordings')
        .insert({
          'title': title,
          'duration_secs': duration.inSeconds,
          'storage_path': path,
        })
        .select()
        .single();

    // Mirror into songs so it can be played from the library under
    // the "Recordings" category if desired.
    await _client.from('songs').insert({
      'title': title,
      'artist': 'You',
      'album': 'Recordings',
      'duration_secs': duration.inSeconds,
      'category': SongCategory.recording.name,
      'storage_path': path,
      'is_recording': true,
    });

    return VoiceRecording(
      id: row['id'] as String,
      title: title,
      createdAt: DateTime.now(),
      duration: duration,
      storagePath: path,
      streamUrl: _urlFor(path),
    );
  }

  /// Open delete — anyone can delete any recording.
  Future<void> deleteRecording(String id, String storagePath) async {
    await _client.storage.from('songs').remove([storagePath]);
    await _client.from('recordings').delete().eq('id', id);
    // Best-effort: also remove the mirrored songs row, ignore if absent.
    await _client.from('songs').delete().eq('storage_path', storagePath);
  }
}
