import 'package:app/core/constants/colors.dart';
import 'package:app/features/music/data/music_models.dart';
import 'package:app/features/music/widgets/track_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Library tab: search field, recently-played carousel, and the full
/// track list.
class LibraryView extends StatefulWidget {
  final List<Track> tracks;
  final String? currentTrackId;
  final bool isPlaying;
  final void Function(Track) onTrackTap;

  const LibraryView({
    super.key,
    required this.tracks,
    required this.currentTrackId,
    required this.isPlaying,
    required this.onTrackTap,
  });

  @override
  State<LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<LibraryView> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.tracks
        : widget.tracks.where((t) {
            final q = _query.toLowerCase();
            return t.title.toLowerCase().contains(q) ||
                t.artist.toLowerCase().contains(q) ||
                t.album.toLowerCase().contains(q);
          }).toList();

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 140.h),
      children: [
        // Search field
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: (v) => setState(() => _query = v),
                  style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Search songs, artists, albums',
                    hintStyle: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
                  ),
                ),
              ),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () => setState(() {
                    _controller.clear();
                    _query = '';
                  }),
                  child: Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18.sp),
                ),
            ],
          ),
        ),

        if (_query.isEmpty) ...[
          SizedBox(height: 24.h),
          Text(
            'Recently Played',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 132.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.tracks.length > 4 ? 4 : widget.tracks.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, i) {
                final track = widget.tracks[i];
                final isCurrent = track.id == widget.currentTrackId;
                return GestureDetector(
                  onTap: () => widget.onTrackTap(track),
                  child: Container(
                    width: 112.w,
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.r),
                      gradient: LinearGradient(
                        colors: track.artwork,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: isCurrent
                          ? Border.all(color: Colors.white, width: 1.5.w)
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.music_note_rounded,
                            color: Colors.white.withValues(alpha: 0.85), size: 22.sp),
                        Text(
                          track.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 24.h),
        ] else
          SizedBox(height: 20.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _query.isEmpty ? 'All Tracks' : 'Results',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              '${filtered.length}',
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),

        if (filtered.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: Center(
              child: Text(
                'No tracks found',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
              ),
            ),
          )
        else
          ...filtered.map((track) => TrackTile(
                track: track,
                isCurrent: track.id == widget.currentTrackId,
                isPlaying: widget.isPlaying,
                onTap: () => widget.onTrackTap(track),
              )),
      ],
    );
  }
}
