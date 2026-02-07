import 'package:flutter/material.dart';

class SlideFadeRoute extends PageRouteBuilder {
  final Widget page;

  SlideFadeRoute({required this.page, RouteSettings? settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          settings: settings, // ← AHORA SÍ ACEPTA ARGUMENTOS
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation = Tween<Offset>(
              begin: Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation);

            final fadeAnimation =
                CurvedAnimation(parent: animation, curve: Curves.easeInOut);

            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}
