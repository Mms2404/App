import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SideBar extends StatefulWidget {
  final VoidCallback? onExit;

  const SideBar({
    super.key,
    this.onExit,
  });

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  static const Color _sidebarBg = Color.fromARGB(255, 22, 23, 23);
  static const Color _sidebarSurface = Color(0xFF262626);
  static const Color _sidebarBorder = Color(0x1FFFFFFF);
  static const Color _sidebarTextPrimary = Color(0xFFEDF1F5);
  static const Color _sidebarTextSecondary = Color(0xB3FFFFFF);
  static const Color _sidebarTextTertiary = Color(0x70FFFFFF);

  bool _confirmingExit = false;
  int? _expandedIndex;

  static const _items = <_NavItem>[
  _NavItem(
    Icons.search_rounded,
    'Search',
    'Ask anything and get an AI answer with relevant videos. Powered by Gemini and the YouTube Data API.',
  ),
  _NavItem(
    Icons.shopping_bag_outlined,
    'Shop',
    'A simple no-login storefront. Browse plants, save items locally, enter your delivery details, and pay through Razorpay. Maps for address selection. Backend on Django.',
  ),
  _NavItem(
    Icons.account_balance_wallet_outlined,
    'Wallet',
    'Track your daily expenses. Sign up or log in to add, edit, and review what you spend over time. Backend on Django.',
  ),
  _NavItem(
    Icons.chat_bubble_outline_rounded,
    'Chat',
    'Real-time messaging with phone-OTP login. Send text, photos, and voice notes. Push notifications included. Backend on Firebase.',
  ),
  _NavItem(
    Icons.music_note_rounded,
    'Music',
    'Play audio files from your device or record voice memos with live waveforms. Two modes in one app.',
  ),
];

  void _handleTilePress(int i) {
    setState(() {
      _expandedIndex = _expandedIndex == i ? null : i;
    });
  }

  void _handleExitTap() {
    if (_confirmingExit) {
      widget.onExit?.call();
    } else {
      setState(() => _confirmingExit = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _confirmingExit = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(color: _sidebarBg),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: 260.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60.h),
                  _SectionLabel(
                    'Workspace',
                    color: _sidebarTextTertiary,
                  ),
                 SizedBox(height: 4.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: List.generate(_items.length, (i) {
                          return _ExpandableTile(
                            item: _items[i],
                            expanded: _expandedIndex == i,
                            onTap: () => _handleTilePress(i),
                            surface: _sidebarSurface,
                            textPrimary: _sidebarTextPrimary,
                            textSecondary: _sidebarTextSecondary,
                            textTertiary: _sidebarTextTertiary,
                          );
                        }),
                      ),
                    ),
                  ),
                  Padding(
                    padding:EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      height: 0.5.h,
                      color: _sidebarBorder,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  _ExitTile(
                    confirming: _confirmingExit,
                    onTap: _handleExitTap,
                    textSecondary: _sidebarTextSecondary,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String description;
  const _NavItem(this.icon, this.label, this.description);
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4.w,
        ),
      ),
    );
  }
}

class _ExpandableTile extends StatefulWidget {
  final _NavItem item;
  final bool expanded;
  final VoidCallback onTap;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const _ExpandableTile({
    required this.item,
    required this.expanded,
    required this.onTap,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  @override
  State<_ExpandableTile> createState() => _ExpandableTileState();
}

class _ExpandableTileState extends State<_ExpandableTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final expanded = widget.expanded;
    const accent = Color(0xFF3CB8E6);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovering = true),
            onExit: (_) => setState(() => _hovering = false),
            child: GestureDetector(
              onTap: widget.onTap,
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: expanded
                      ? accent.withValues(alpha: 0.10)
                      : _hovering
                          ? widget.surface
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                  border: expanded
                      ? Border.all(
                          color: accent.withValues(alpha: 0.25),
                          width: 0.5.w,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.item.icon,
                      size: 18.sp,
                      color: expanded ? accent : widget.textSecondary,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        widget.item.label,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: expanded
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: expanded
                              ? widget.textPrimary
                              : widget.textSecondary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: expanded ? 0.25 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 16.sp,
                        color: expanded ? accent : widget.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 12.h),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
                    decoration: BoxDecoration(
                      color: widget.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border(
                        left: BorderSide(
                          color: accent.withValues(alpha: 0.4),
                          width: 2.w,
                        ),
                      ),
                    ),
                    child: Text(
                      widget.item.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5.h,
                        color: widget.textSecondary,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ExitTile extends StatelessWidget {
  final bool confirming;
  final VoidCallback onTap;
  final Color textSecondary;

  const _ExitTile({
    required this.confirming,
    required this.onTap,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: confirming
                ? AppColors.danger.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: confirming
                  ? AppColors.danger.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 0.5.w,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18.sp,
                color: confirming ? AppColors.danger : textSecondary,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  confirming ? 'Tap again to exit' : 'Exit',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight:
                        confirming ? FontWeight.w600 : FontWeight.w400,
                    color: confirming
                        ? AppColors.danger
                        : textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}