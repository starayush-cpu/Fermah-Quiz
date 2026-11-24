import 'package:flutter/material.dart';

import 'theme.dart';

/// A number that counts up (or down) to its new value, Bencho rolling
/// counter style. Animates transform-free: the value itself tweens, so
/// nothing on screen moves except the digits. When the user prefers
/// reduced motion it jumps straight to the final value.
class RollingNumber extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: reduceMotion(context)
          ? Duration.zero
          : const Duration(milliseconds: 700),
      builder: (BuildContext context, int v, Widget? child) {
        return Text(
          '$v$suffix',
          style: style.copyWith(
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}
