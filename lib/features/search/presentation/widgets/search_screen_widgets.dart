import 'package:app/core/constants/colors.dart';
import 'package:app/features/search/presentation/widgets/ui_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

/// Top header: brand dot + "Search" title + "AI + Video" badge.
class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        children: [
        SizedBox(height: 18.h),
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Search',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5.w,
                ),
              ),
              const Spacer(),
              Text(
                'AI + Video',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4.w,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Search bar with inline submit button and clear-on-text icon.
class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final bool isLoading;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _focused
                ? AppColors.accent.withValues(alpha: 0.5)
                : AppColors.border,
            width: _focused ? 1.w : 0.5.w,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 12.w),
              child: Icon(
                Icons.search_rounded,
                size: 20.sp,
                color: _focused ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                cursorColor: AppColors.textPrimary,
                cursorWidth: 1.5.w,
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.textPrimary,
                  height: 1.2.h,
                ),
                decoration:InputDecoration(
                  hintText: 'Ask anything…',
                  hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => widget.onSubmit(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            if (widget.controller.text.isNotEmpty && !widget.isLoading)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  setState(() {});
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            GestureDetector(
              onTap: widget.isLoading ? null : widget.onSubmit,
              child: Container(
                margin: EdgeInsets.all(6.w),
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? AppColors.bgElevated
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: widget.isLoading
                    ? Center(
                        child: SizedBox(
                          width: 14.w,
                          height: 14.h ,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6.w,
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.accent),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.arrow_upward_rounded,
                        size: 18.sp,
                        color: AppColors.bgBase,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders Gemini's markdown answer in a styled card.
class AnswerCard extends StatelessWidget {
  final String markdown;
  const AnswerCard({super.key, required this.markdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 370.h,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border, width: 0.5.w),
      ),
      child: SingleChildScrollView(
        child: SelectionArea(
          child: MarkdownBody(
            data: markdown,
            // selectable: true,    // SelectionArea is used instead for better mobile support
            styleSheet: MarkdownStyleSheet(
              p: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                height: 1.6.h,
              ),
              h1: TextStyle(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3.h,
              ),
              h2: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3.h,
              ),
              h3: TextStyle(
                fontSize: 14.sp ,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                height: 1.3.h,
              ),
              listBullet: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
                height: 1.6.h,
              ),
              code: TextStyle(
                fontSize: 13.sp,
                color: AppColors.accent,
                backgroundColor: AppColors.bgElevated,
              ),
              codeblockDecoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(8.r),
              ),
              codeblockPadding: EdgeInsets.all(12.w),
              blockquote: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.5.h,
              ),
              blockquoteDecoration:BoxDecoration(
                border: Border(
                  left: BorderSide(color: AppColors.accent, width: 2.w),
                ),
              ),
              blockquotePadding: EdgeInsets.only(left: 12.w),
              a: TextStyle(
                color: AppColors.accent,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.accent.withOpacity(0.4),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// YouTube video result row — thumbnail + title + channel.
class VideoCard extends StatefulWidget {
  final dynamic video;
  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  bool _pressed = false;

  Future<void> _openVideo() async {
  final videoId = widget.video['id']?['videoId'];
  if (videoId == null) return;

  final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
  if (await canLaunchUrl(url)) {
    // LaunchMode.externalApplication opens the YouTube app if installed,
    // else falls back to browser. LaunchMode.platformDefault is the safe alternative.
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

  @override
  Widget build(BuildContext context) {
    final snippet = widget.video['snippet'];
    final title = snippet['title'] ?? '';
    final channel = snippet['channelTitle'] ?? '';
    final thumb = snippet['thumbnails']?['medium']?['url'] ??
        snippet['thumbnails']?['default']?['url'] ??
        '';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () => _openVideo(),
      child: AnimatedContainer(
        height: 100,
        width: double.infinity,
        duration: const Duration(milliseconds: 120),
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.bgElevated : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border, width: 0.5.w),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: 120.w,
                  color: AppColors.bgElevated,
                  child: thumb.isNotEmpty
                      ? Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textTertiary,
                            size: 18.sp,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp ,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.35.h,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 12.sp,
                        color: AppColors.textTertiary,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          channel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pre-search empty state with tappable suggestions.
class SearchEmptyState extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const SearchEmptyState({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            'TRY ASKING',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6.w,
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: suggestions
                .map((s) => SuggestionChip(
                      text: s,
                      onTap: () => onSuggestionTap(s),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}