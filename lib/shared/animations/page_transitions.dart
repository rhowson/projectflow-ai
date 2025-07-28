import 'package:flutter/material.dart';

class SlidePageTransition extends PageRouteBuilder {
  final Widget child;
  final Offset direction;
  final Duration duration;

  SlidePageTransition({
    required this.child,
    this.direction = const Offset(1.0, 0.0),
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: direction,
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
}

class FadePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  FadePageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 250),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation.drive(
                CurveTween(curve: Curves.easeInOut),
              ),
              child: child,
            );
          },
        );
}

class ScalePageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  ScalePageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: 0.8,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.elasticOut));

            return ScaleTransition(
              scale: animation.drive(tween),
              child: FadeTransition(
                opacity: animation.drive(
                  CurveTween(curve: Curves.easeInOut),
                ),
                child: child,
              ),
            );
          },
        );
}

class CustomPageTransition extends PageRouteBuilder {
  final Widget child;
  final Duration duration;

  CustomPageTransition({
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: FadeTransition(
                opacity: animation.drive(
                  Tween(begin: 0.0, end: 1.0).chain(
                    CurveTween(curve: Curves.easeInOut),
                  ),
                ),
                child: child,
              ),
            );
          },
        );
}

// Animated list transitions
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));

    // Start animation with delay
    Future.delayed(
      Duration(milliseconds: widget.index * widget.delay.inMilliseconds),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// Staggered animation for grids
class StaggeredGrid extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredGrid({
    super.key,
    required this.children,
    required this.crossAxisCount,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.itemDuration = const Duration(milliseconds: 500),
  });

  @override
  State<StaggeredGrid> createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<StaggeredGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          delay: widget.staggerDelay,
          duration: widget.itemDuration,
          child: widget.children[index],
        );
      },
    );
  }
}