// APP NOTIFICATIONS
// -----------------------------------------------------------------------------
// Custom overlay notifications — no third-party packages needed.
// Two themes:
//   AppNotificationTheme.dark  → for light-themed features (plant shop,
//                                expense tracker, search, auth screens)
//   AppNotificationTheme.light → for dark-themed features (music)
//
// Usage:
//   AppNotification.show(context, message: 'Track deleted',
//       theme: AppNotificationTheme.light);
//
//   AppNotification.show(context, message: 'Order placed!',
//       icon: Icons.check_circle_rounded,
//       type: AppNotificationType.success);
// -----------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AppNotificationType { info, success, error, warning }

enum AppNotificationTheme { dark, light }

class AppNotification {
  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    AppNotificationType type = AppNotificationType.info,
    AppNotificationTheme theme = AppNotificationTheme.dark,
    Duration duration = const Duration(seconds: 3),
  }) {
    _current?.remove();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _NotificationWidget(
        message: message,
        title: title,
        icon: icon ?? _iconFor(type),
        color: _colorFor(type),
        theme: theme,
        onDismiss: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
        duration: duration,
      ),
    );
    _current = entry;
    overlay.insert(entry);
  }

  static IconData _iconFor(AppNotificationType t) => switch (t) {
        AppNotificationType.success => Icons.check_circle_rounded,
        AppNotificationType.error   => Icons.error_rounded,
        AppNotificationType.warning => Icons.warning_rounded,
        AppNotificationType.info    => Icons.info_rounded,
      };

  static Color _colorFor(AppNotificationType t) => switch (t) {
        AppNotificationType.success => const Color(0xFF4ADE80),
        AppNotificationType.error   => const Color(0xFFFF6B6B),
        AppNotificationType.warning => const Color(0xFFFACC15),
        AppNotificationType.info    => const Color(0xFF5DE6C8),
      };
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final String? title;
  final IconData icon;
  final Color color;
  final AppNotificationTheme theme;
  final VoidCallback onDismiss;
  final Duration duration;

  const _NotificationWidget({
    required this.message,
    this.title,
    required this.icon,
    required this.color,
    required this.theme,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween<Offset>(begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.theme == AppNotificationTheme.dark;

    final bg     = isDark ? const Color(0xFF1C1C1C) : const Color(0xFFFFFFFF);
    final border = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE5E7EB);
    final titleC = isDark ? Colors.white : const Color(0xFF111827);
    final msgC   = isDark ? const Color(0xFFAAAAAA) : const Color(0xFF6B7280);

    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16.w,
      right: 16.w,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.45 : 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(children: [
                  Container(
                    width: 36.w, height: 36.h,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 18.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.title != null) ...[
                        Text(widget.title!,
                            style: TextStyle(fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700, color: titleC)),
                        SizedBox(height: 2.h),
                      ],
                      Text(widget.message,
                          style: TextStyle(
                              fontSize: widget.title != null ? 12.sp : 13.5.sp,
                              color: widget.title != null ? msgC : titleC,
                              fontWeight: widget.title != null
                                  ? FontWeight.w400 : FontWeight.w600)),
                    ],
                  )),
                  SizedBox(width: 8.w),
                  // Only the X dismisses — no whole-card tap
                  GestureDetector(
                    onTap: _dismiss,
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(Icons.close_rounded, size: 18.sp, color: msgC),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
  }
}
