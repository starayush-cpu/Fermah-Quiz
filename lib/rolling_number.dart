import 'package:flutter/material.dart';

import 'theme.dart';

/// A number that counts up (or down) to its new value, Bencho rolling
/// counter style. The digits tween, so nothing on screen moves except
/// the digits. Whenever the value changes, the count restarts from the
/// number currently on screen, so every change is visible instead of
/// jumping straight to the final value. When the user prefers reduced
/// motion it jumps straight to the final value.
class RollingNumber extends StatefulWidget {
  const RollingNumber({
    super.key,
    required this.value,
    required this.style,
    this.suffix = '',
  });

  final int value;
  final TextStyle style;
  final String suffix;

  @override
  State<RollingNumber> createState() => _RollingNumberState();
}

class _RollingNumberState extends State<RollingNumber>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 1200);
  late final AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);
    _animation = IntTween(begin: 0, end: widget.value).animate(_controller);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RollingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      // Restart the count from the number on screen right now, not from
      // zero and not from the finished value.
      final int shown = _animation.value;
      _animation =
          IntTween(begin: shown, end: widget.value).animate(_controller);
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle style = widget.style.copyWith(
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    if (reduceMotion(context)) {
      return Text('${widget.value}${widget.suffix}', style: style);
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Text('${_animation.value}${widget.suffix}', style: style);
      },
    );
  }
}
