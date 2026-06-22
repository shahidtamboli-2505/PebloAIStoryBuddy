/// ShakeAnimation — Reusable shake animation widget.
///
/// Wraps any child widget and performs a horizontal shake
/// when [shake] is incremented. Uses a fast oscillation curve
/// for satisfying wrong-answer feedback.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A widget that shakes its [child] horizontally when [shake] changes.
///
/// Increment the [shake] value to trigger a new shake cycle.
/// The animation runs for [duration] with [shakeCount] oscillations.
class ShakeAnimationWidget extends StatefulWidget {
  /// The widget to shake.
  final Widget child;

  /// Increment this value to trigger a shake. Each new value starts a cycle.
  final int shake;

  /// Duration of the full shake animation.
  final Duration duration;

  /// Number of back-and-forth oscillations.
  final int shakeCount;

  /// Maximum horizontal displacement in logical pixels.
  final double shakeOffset;

  const ShakeAnimationWidget({
    super.key,
    required this.child,
    required this.shake,
    this.duration = const Duration(milliseconds: 500),
    this.shakeCount = 4,
    this.shakeOffset = 10.0,
  });

  @override
  State<ShakeAnimationWidget> createState() => _ShakeAnimationWidgetState();
}

class _ShakeAnimationWidgetState extends State<ShakeAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didUpdateWidget(covariant ShakeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger shake when the shake counter changes
    if (widget.shake != oldWidget.shake && widget.shake > 0) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Calculates horizontal offset using a sine wave for smooth oscillation.
  double _shakeOffset(double progress) {
    return math.sin(progress * math.pi * widget.shakeCount) *
        widget.shakeOffset *
        (1 - progress); // Dampen towards the end
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeOffset(_controller.value), 0),
          child: child,
        );
      },
    );
  }
}
