import 'package:app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class SideBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;
  final VoidCallback? onExit;

  const SideBar({
    super.key,
    this.selectedIndex = 0,
    this.onItemSelected,
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

  static const _items = <_NavItem>[
    _NavItem(Icons.search_rounded, 'Search'),
    _NavItem(Icons.shopping_bag_outlined, 'Shop'),
    _NavItem(Icons.account_balance_wallet_outlined, 'Wallet'),
    _NavItem(Icons.chat_bubble_outline_rounded, 'Chat'),
    _NavItem(Icons.menu_book_outlined, 'Ledger'),
  ];

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
          // Subtle ambient gradient for depth — barely visible but adds life
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color:_sidebarBg
              ),
            ),
          ),
          SafeArea(
            child: SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  _ProfileBlock(
                    surface: _sidebarSurface,
                    border: _sidebarBorder,
                    textPrimary: _sidebarTextPrimary,
                    textTertiary: _sidebarTextTertiary,
                  ),
                  const SizedBox(height: 28),
                  _SectionLabel(
                    'Workspace',
                    color: _sidebarTextTertiary,
                  ),
                  const SizedBox(height: 4),
                  ...List.generate(_items.length, (i) {
                    return _NavTile(
                      item: _items[i],
                      selected: widget.selectedIndex == i,
                      onTap: () => widget.onItemSelected?.call(i),
                      surface: _sidebarSurface,
                      textPrimary: _sidebarTextPrimary,
                      textSecondary: _sidebarTextSecondary,
                    );
                  }),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      height: 0.5,
                      color: _sidebarBorder,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _ExitTile(
                    confirming: _confirmingExit,
                    onTap: _handleExitTap,
                    textSecondary: _sidebarTextSecondary,
                  ),
                  const SizedBox(height: 16),
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
  const _NavItem(this.icon, this.label);
}

class _ProfileBlock extends StatelessWidget {
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textTertiary;

  const _ProfileBlock({
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: surface,
              border: Border.all(color: border, width: 0.5),
            ),
            child: Icon(
              Icons.person_outline_rounded,
              color: textPrimary.withOpacity(0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Madhumita',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Just going with the flow',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    color: textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _SectionLabel(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Manrope',
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;

  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final accent = Color(0xFF3CB8E6);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withOpacity(0.14)
                  : _hovering
                      ? widget.surface
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(
                      color: accent.withOpacity(0.35),
                      width: 0.5,
                    )
                  : null,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.18),
                        blurRadius: 16,
                        spreadRadius: -2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  height: selected ? 20 : 0,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: accent.withOpacity(0.7),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                ),
                SizedBox(width: selected ? 10 : 0),
                Icon(
                  widget.item.icon,
                  size: 18,
                  color: selected ? accent : widget.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected
                          ? widget.textPrimary
                          : widget.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: confirming
                ? AppColors.danger.withOpacity(0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: confirming
                  ? AppColors.danger.withOpacity(0.4)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                size: 18,
                color: confirming ? AppColors.danger : textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  confirming ? 'Tap again to exit' : 'Exit',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
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