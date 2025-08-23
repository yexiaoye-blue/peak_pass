import 'package:flutter/material.dart';

class FadeCrossTransition extends StatelessWidget {
  const FadeCrossTransition({
    super.key,
    required this.animation,
    this.firstChild,
    this.secondChild,
    this.alignment = AlignmentDirectional.topStart,
  });

  final Animation<double> animation;
  final Widget? firstChild;
  final Widget? secondChild;
  final AlignmentGeometry alignment;

  bool get isSecond => animation.isForwardOrCompleted;
  bool get isFirst => !isSecond;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment,
      children: [
        FadeTransition(
          opacity: ReverseAnimation(animation),
          child: IgnorePointer(ignoring: isSecond, child: firstChild),
        ),
        FadeTransition(
          opacity: animation,
          child: IgnorePointer(ignoring: isFirst, child: secondChild),
        ),
      ],
    );
  }
}
