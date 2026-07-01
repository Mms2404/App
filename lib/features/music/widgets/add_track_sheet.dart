import 'dart:io';
import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/domain/entities/music_entities.dart';
import 'package:app/features/music/presentation/cubit/music_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

import 'track_tile.dart' show formatDuration;

void showAddTrackSheet(BuildContext context, MusicCubit cubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddTrackSheet(cubit: cubit),
  );
}

class _AddTrackSheet extends StatefulWidget {
  final MusicCubit cubit;
  const _AddTrackSheet({required this.cubit});

  @override
  State<_AddTrackSheet> createState() => _AddTrackSheetState();
}

class _AddTrackSheetState extends State<_AddTrackSheet> {
  final _titleCtrl = TextEditingController();
  final _artistCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  File? _file;
  SongCategory _category = SongCategory.other;
  Duration _duration = Duration.zero;
  bool _readingDuration = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _artistCtrl.dispose();
    _albumCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() {
      _file = File(path);
      _duration = Duration.zero;
      _readingDuration = true;
      if (_titleCtrl.text.isEmpty) {
        _titleCtrl.text = result.files.single.name.split('.').first;
      }
    });

    // Read duration straight from the audio file's metadata using a
    // throwaway just_audio player, so it's captured up front instead of
    // being left at zero until the track is first played.
    final probePlayer = AudioPlayer();
    try {
      final metadataDuration = await probePlayer.setFilePath(path);
      if (!mounted) return;
      setState(() {
        _duration = metadataDuration ?? Duration.zero;
        _readingDuration = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _readingDuration = false);
    } finally {
      await probePlayer.dispose();
    }
  }

  void _submit() {
    if (_file == null || _titleCtrl.text.trim().isEmpty) return;
    widget.cubit.addTrack(
      file: _file!,
      title: _titleCtrl.text.trim(),
      artist: _artistCtrl.text.trim().isEmpty ? 'Unknown' : _artistCtrl.text.trim(),
      album: _albumCtrl.text.trim().isEmpty ? 'Singles' : _albumCtrl.text.trim(),
      duration: _duration, // read from audio metadata in _pickFile
      category: _category,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add a song',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface, borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.border)),
                child: Row(
                  children: [
                    Icon(Icons.audio_file_rounded, color: AppColors.accent, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _file?.path.split('/').last ?? 'Choose an audio file',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13.5.sp, color: AppColors.textPrimary),
                      ),
                    ),
                    if (_readingDuration)
                      SizedBox(
                        width: 14.sp, height: 14.sp,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                      )
                    else if (_file != null && _duration > Duration.zero)
                      Text(
                        formatDuration(_duration),
                        style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _Field(controller: _titleCtrl, hint: 'Title'),
            SizedBox(height: 10.h),
            _Field(controller: _artistCtrl, hint: 'Artist (optional)'),
            SizedBox(height: 10.h),
            _Field(controller: _albumCtrl, hint: 'Album (optional)'),
            SizedBox(height: 14.h),
            SizedBox(
              height: 36.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: SongCategory.values
                    .where((c) => c != SongCategory.recording)
                    .map((c) => Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: ChoiceChip(
                            label: Text(c.label),
                            selected: _category == c,
                            onSelected: (_) => setState(() => _category = c),
                            selectedColor: AppColors.accent,
                            backgroundColor: AppColors.bgSurface,
                            labelStyle: TextStyle(
                              fontSize: 12.sp,
                              color: _category == c ? AppColors.bgBase : AppColors.textSecondary,
                            ),
                            side: BorderSide(color: AppColors.border),
                          ),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _file == null ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.bgBase,
                minimumSize: Size(double.infinity, 50.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const _Field({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.bgSurface,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColors.accent)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    );
  }
}
