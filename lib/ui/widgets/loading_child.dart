import 'package:flutter/material.dart';

class LoadingChild extends StatelessWidget {
  const LoadingChild({super.key, required this.isLoading, required this.child});
  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: child,
      secondChild: Center(
        child: SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
      crossFadeState:
          isLoading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: Durations.short2,
    );
  }
}
