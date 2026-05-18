import 'package:app/core/constants/background.dart';
import 'package:app/core/utils/logger.dart';
import 'package:app/features/search/actions/gemini.dart';
import 'package:app/features/search/actions/youtube.dart';
import 'package:app/features/search/presentation/widgets/search_screen_widgets.dart';
import 'package:app/features/search/presentation/widgets/ui_states.dart';
import 'package:flutter/material.dart';

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
      body: OrbBackground(
        blurIntensity: 1.8,
        brightness: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              const SearchHeader(),
              AppSearchBar(
                controller: _controller,
                focusNode: _focusNode,
                onSubmit: () => _sendPrompt(),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_response.isNotEmpty) ...[
            const SectionHeader(
              icon: Icons.auto_awesome_rounded,
              label: 'Answer',
            ),
            const SizedBox(height: 12),
            AnswerCard(markdown: _response),
            const SizedBox(height: 28),
          ],
          if (_videos.isNotEmpty) ...[
            SectionHeader(
              icon: Icons.play_circle_outline_rounded,
              label: 'Videos',
              trailing: '${_videos.length}',
            ),
            const SizedBox(height: 12),
            ..._videos.map((v) => VideoCard(video: v)),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const InlineLoading(),
          ],
        ],
      ),
    );
  }
}