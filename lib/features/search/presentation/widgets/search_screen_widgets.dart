import 'package:app/core/constants/colors.dart';
import 'package:app/features/search/presentation/widgets/ui_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Top header: brand dot + "Search" title + "AI + Video" badge.
class SearchHeader extends StatelessWidget {
  const SearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20,vertical:20),
      child: Column(
        children: [
        SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Search',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              const Text(
                'AI + Video',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focused
                ? AppColors.accent.withOpacity(0.5)
                : AppColors.border,
            width: _focused ? 1 : 0.5,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: _focused ? AppColors.accent : AppColors.textTertiary,
              ),
            ),
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                cursorColor: AppColors.textPrimary,
                cursorWidth: 1.5,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask anything…',
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            GestureDetector(
              onTap: widget.isLoading ? null : widget.onSubmit,
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? AppColors.bgElevated
                      : AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: widget.isLoading
                    ? Center(
                        child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.6,
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.accent),
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        size: 18,
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
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: MarkdownBody(
        data: markdown,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          h1: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          h2: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          h3: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
          listBullet: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: AppColors.accent,
            backgroundColor: AppColors.bgElevated,
          ),
          codeblockDecoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          codeblockPadding: const EdgeInsets.all(12),
          blockquote: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          blockquoteDecoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
          blockquotePadding: const EdgeInsets.only(left: 12),
          a: TextStyle(
            color: AppColors.accent,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.accent.withOpacity(0.4),
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
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.bgElevated : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: 120,
                  color: AppColors.bgElevated,
                  child: thumb.isNotEmpty
                      ? Image.network(
                          thumb,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textTertiary,
                            size: 18,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          channel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'TRY ASKING',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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