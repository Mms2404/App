import 'package:flutter/material.dart';

/// Shared-axis (horizontal) page transition — slide + fade, no scale.
/// Matches the app's existing motion language (see dialogBox.dart's
/// easeOutCubic curve) so dialogs and screen pushes feel consistent.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds:1000),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Incoming page: slides in from the right, fades in.
            final incomingCurve = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final slideIn = Tween<Offset>(
              begin: const Offset(0.8, 0),
              end: Offset.zero,
            ).animate(incomingCurve);

            // Outgoing page: shifts slightly left, fades out —
            // this is what makes it feel like "shared axis" instead of
            // one screen just sliding over a static one.
            final outgoingCurve = CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.1, 0),
            ).animate(outgoingCurve);

            return FadeTransition(
              opacity: incomingCurve,
              child: SlideTransition(
                position: slideIn,
                child: SlideTransition(
                  position: slideOut,
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.90, end: 0.60)
                        .animate(outgoingCurve),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
}