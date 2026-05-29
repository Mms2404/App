import 'package:app/core/constants/background.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/features/search/actions/gemini.dart';
import 'package:app/features/search/actions/youtube.dart';
import 'package:app/features/search/presentation/widgets/search_screen_widgets.dart';
import 'package:app/features/search/presentation/widgets/ui_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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


  String _friendlyError(Object e) {
  final raw = e.toString().toLowerCase();

  // Gemini quota / rate limit
  if (raw.contains('quota') || raw.contains('rate') || raw.contains('429')) {
    return 'You\'re asking faster than I can answer. Wait a moment and try again.';
  }

  // Server overloaded / temporarily unavailable
  if (raw.contains('503') ||
    raw.contains('unavailable') ||
    raw.contains('overloaded') ||
    raw.contains('high demand')) {
  return 'The AI is overloaded right now. Wait a moment and try again.';
 }

  // No internet
  if (raw.contains('socketexception') ||
      raw.contains('failed host lookup') ||
      raw.contains('network is unreachable') ||
      raw.contains('connection refused')) {
    return 'No internet connection. Check your network and try again.';
  }

  // Timeout
  if (raw.contains('timeout') || raw.contains('timed out')) {
    return 'The search took too long. Try again.';
  }

  // Auth / API key
  if (raw.contains('api key') ||
      raw.contains('unauthorized') ||
      raw.contains('401') ||
      raw.contains('403') ||
      raw.contains('permission denied')) {
    return 'Authentication failed. The app needs attention.';
  }

  // Safety / blocked content
  if (raw.contains('safety') || raw.contains('blocked')) {
    return 'I can\'t answer that one. Try rephrasing your question.';
  }

  // YouTube specific
  if (raw.contains('youtube')) {
    return 'Couldn\'t fetch video results, but the AI answer might still work.';
  }

  // Catch-all
  return 'Something went wrong. Tap retry to try again.';
 }

  Future<void> _sendPrompt([String? prefilled]) async {
    final prompt = (prefilled ?? _controller.text).trim();
    if (prompt.isEmpty) return;

    if (prefilled != null) {
      _controller.text = prefilled;
    }
    _focusNode.unfocus();

    log.d('Search submitted: $prompt');

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
      log.i('Search complete — answer length: ${(results[0] as String).length}, videos: ${(results[1] as List).length}');
      setState(() {
        _response = results[0] as String;
        _videos = results[1] as List<dynamic>;
        _isLoading = false;
      });
    } catch (e, st) {
      if (!mounted) return;
      log.e('Search failed', error: e, stackTrace: st);
      setState(() {
        _errorMessage = _friendlyError(e);
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
      resizeToAvoidBottomInset: false,
      body: OrbBackground(
        blurIntensity: 1.8,
        brightness: 0.5,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 12.h),
              const SearchHeader(),
              AppSearchBar(
                controller: _controller,
                focusNode: _focusNode,
                onSubmit: () => _sendPrompt(),
                isLoading: _isLoading,
              ),
              SizedBox(height: 16.h),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return ErrorStateView(
        message: _errorMessage!,
        onRetry: () => _sendPrompt(_controller.text),
      );
    }

    if (!_hasSearched) {
      return SearchEmptyState(
        suggestions: _suggestions,
        onSuggestionTap: _sendPrompt,
      );
    }

    if (_isLoading && _response.isEmpty) {
      return const LoadingState(message: 'Searching the web…');
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_response.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.auto_awesome_rounded,
              label: 'Answer',
            ),
            SizedBox(height: 12.h),
            AnswerCard(markdown: _response),
            SizedBox(height: 28.h),
          ],
          if (_videos.isNotEmpty) ...[
            SectionHeader(
              icon: Icons.play_circle_outline_rounded,
              label: 'Videos',
              trailing: '${_videos.length}',
            ),
            SizedBox(height: 12.h),
            ..._videos.map((v) => VideoCard(video: v)),
          ],
          if (_isLoading) ...[
            SizedBox(height: 16.h),
            const InlineLoading(),
          ],
        ],
      ),
    );
  }
}