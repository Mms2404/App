import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class LightSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hint;

  const LightSearchBar({
    required this.controller,
    this.hint = 'Search…',
  });

  @override
  State<LightSearchBar> createState() => LightSearchBarState();
}

class LightSearchBarState extends State<LightSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? AppColors.success.withOpacity(0.5)
              : AppColors.lightBorder,
          width: _focused ? 1 : 0.5,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.12),
                  blurRadius: 16,
                  spreadRadius: -4,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: _focused
                  ? AppColors.success
                  : AppColors.lightTextTertiary,
            ),
          ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              cursorColor: AppColors.lightTextPrimary,
              cursorWidth: 1.5,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: AppColors.lightTextPrimary,
                height: 1.2,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: AppColors.lightTextTertiary,
                ),
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: () {
                widget.controller.clear();
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.lightElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}