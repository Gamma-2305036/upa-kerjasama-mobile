import 'package:flutter/material.dart';

/// Custom page route dengan animasi slide dari kanan ke kiri (seperti iOS)
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlidePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Custom page route dengan animasi fade
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
}

/// Custom page route dengan animasi scale (zoom in)
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  ScalePageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutCubic,
                ),
              ),
              child: child,
            );
          },
        );
}

/// Custom page route dengan animasi slide dari bawah (modal style)
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}

/// Helper function untuk navigasi dengan animasi slide (default)
class PageTransitions {
  /// Navigate dengan animasi slide dari kanan (default untuk kebanyakan halaman)
  static Future<T?> slideTo<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      SlidePageRoute(page: page),
    );
  }

  /// Navigate dengan animasi fade (untuk halaman yang lebih subtle)
  static Future<T?> fadeTo<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      FadePageRoute(page: page),
    );
  }

  /// Navigate dengan animasi scale (untuk dialog-like pages)
  static Future<T?> scaleTo<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      ScalePageRoute(page: page),
    );
  }

  /// Navigate dengan animasi slide dari bawah (untuk modal-like pages)
  static Future<T?> slideUpTo<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      SlideUpPageRoute(page: page),
    );
  }

  /// Navigate replace dengan animasi slide
  static Future<T?> slideReplace<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, T>(
      context,
      SlidePageRoute(page: page),
    );
  }

  /// Navigate replace dengan animasi fade
  static Future<T?> fadeReplace<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, T>(
      context,
      FadePageRoute(page: page),
    );
  }

  /// Navigate and remove until dengan animasi slide
  static Future<T?> slideAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      SlidePageRoute(page: page),
      predicate,
    );
  }

  /// Navigate and remove until dengan animasi fade
  static Future<T?> fadeAndRemoveUntil<T>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      FadePageRoute(page: page),
      predicate,
    );
  }
}

