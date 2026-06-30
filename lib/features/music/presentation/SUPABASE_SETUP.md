# Supabase Setup — Music Feature (v2: categories + open access + recorder)

This replaces any earlier Supabase music setup doc — schema changed.

## 1. Tables

```sql
create table songs (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  artist        text not null,
  album         text not null,
  duration_secs int  not null default 0,
  category      text not null default 'other',
  storage_path  text not null,
  is_recording  boolean not null default false,
  created_at    timestamptz default now()
);

create table recordings (
  id            uuid primary key default gen_random_uuid(),
  title         text not null,
  duration_secs int  not null,
  storage_path  text not null,
  created_at    timestamptz default now()
);
```

`category` values used by the app: `pop, rock, lofi, classical, hiphop,
electronic, recording, other` (matches `SongCategory` enum in
`music_entities.dart`).

## 2. Storage bucket

Dashboard → Storage → New bucket → name `songs` → **Public: ON**.
Both regular songs and voice recordings upload here.

## 3. Row Level Security — fully open (no auth in this app)

```sql
alter table songs enable row level security;
create policy "anyone can do anything" on songs
  for all using (true) with check (true);

alter table recordings enable row level security;
create policy "anyone can do anything" on recordings
  for all using (true) with check (true);
```

Storage policies (Dashboard → Storage → songs → Policies):
- SELECT: public (already true since bucket is public)
- INSERT: allow anon
- DELETE: allow anon

Or via SQL:
```sql
create policy "anon insert" on storage.objects
  for insert to anon with check (bucket_id = 'songs');
create policy "anon delete" on storage.objects
  for delete to anon using (bucket_id = 'songs');
```

## 4. Packages

```yaml
dependencies:
  supabase_flutter: ^2.5.6
  just_audio: ^0.9.36
  record: ^5.1.2
  path_provider: ^2.1.4
  file_picker: ^8.1.2
```

## 5. Permissions

**Android** `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**iOS** `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Used to record voice memos</string>
```

## 6. Init in main.dart

```dart
await Supabase.initialize(url: 'YOUR_URL', anonKey: 'YOUR_ANON_KEY');
```

## 7. What's wired now

- Library tab: real Supabase fetch, category filter chips, tap-to-play
  (just_audio), long-press a track → delete (no auth check — open).
- "+" button top-right → pick a local audio file, fill title/artist/
  album, choose category → uploads to Storage + inserts row.
- Recorder tab: real mic capture (`record` package) → Stop saves to
  Supabase Storage + `recordings` table, also mirrored into `songs`
  with `category = recording` so it can play from the library too.
- Recording row "..." menu → Delete (open, no auth).
- No login screen, no ownership checks — anyone using the app can
  add or delete any song or recording, as requested.


