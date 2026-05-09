import 'package:app/core/constants/background.dart';
import 'package:app/core/constants/colors.dart';
import 'package:app/features/actions/gemini.dart';
import 'package:app/features/actions/youtube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  String _response = '';
  List<dynamic> _videos = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  static const _suggestions = [
    'Explain quantum entanglement',
    'How does Flutter rendering work?',
    'Best practices for REST API design',
    'What is the future of LLMs?',
  ];

  Future<void> _sendPrompt([String? prefilled]) async {
    final prompt = (prefilled ?? _controller.text).trim();
    if (prompt.isEmpty) return;

    if (prefilled != null) {
      _controller.text = prefilled;
    }
    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _hasSearched = true;
    });

    try {
      final results = await Future.wait([
        geminiSearch(prompt),
        youtubeSearch(prompt),
      ]);

      if (!mounted) return;
      setState(() {
        _response = results[0] as String;
        _videos = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _response = '';
        _videos = [];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: OrbBackground(
        blurIntensity: 1.8,
        brightness: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              _Header(),
              const SizedBox(height: 16),
              _SearchBar(
                controller: _controller,
                focusNode: _focusNode,
                onSubmit: () => _sendPrompt(),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return _ErrorState(
        message: _errorMessage!,
        onRetry: () => _sendPrompt(_controller.text),
      );
    }

    if (!_hasSearched) {
      return _EmptyState(
        suggestions: _suggestions,
        onSuggestionTap: _sendPrompt,
      );
    }

    if (_isLoading && _response.isEmpty) {
      return const _LoadingState();
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_response.isNotEmpty) ...[
            const _SectionHeader(
              icon: Icons.auto_awesome_rounded,
              label: 'Answer',
            ),
            const SizedBox(height: 12),
            _AnswerCard(markdown: _response),
            const SizedBox(height: 28),
          ],
          if (_videos.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.play_circle_outline_rounded,
              label: 'Videos',
              trailing: '${_videos.length}',
            ),
            const SizedBox(height: 12),
            ..._videos.map((v) => _VideoCard(video: v)),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const _InlineLoading(),
          ],
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
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
          Text(
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
    );
  }
}

class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSubmit;
  final bool isLoading;

  const _SearchBar({
    required this.controller,
    required this.focusNode,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
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
                decoration: InputDecoration(
                  hintText: 'Ask anything…',
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => widget.onSubmit(),
              ),
            ),
            if (widget.controller.text.isNotEmpty && !widget.isLoading)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
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
                    : Icon(
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;

  const _SectionHeader({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: AppColors.textSecondary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trailing!,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final String markdown;
  const _AnswerCard({required this.markdown});

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
          code: TextStyle(
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
          blockquote: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          blockquoteDecoration: BoxDecoration(
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

class _VideoCard extends StatefulWidget {
  final dynamic video;
  const _VideoCard({required this.video});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
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
                          errorBuilder: (_, __, ___) => Icon(
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
                      Icon(
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
                          style: TextStyle(
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

class _EmptyState extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  const _EmptyState({
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
          Text(
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
                .map((s) => _SuggestionChip(
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

class _SuggestionChip extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _SuggestionChip({required this.text, required this.onTap});

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _pressed ? AppColors.bgElevated : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.north_east_rounded,
              size: 12,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              widget.text,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Searching the web…',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineLoading extends StatelessWidget {
  const _InlineLoading();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Loading more…',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 32,
              color: AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: AppColors.textTertiary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 14,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Try again',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}