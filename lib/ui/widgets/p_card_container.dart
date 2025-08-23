import 'package:flutter/material.dart';

class PCardContainer extends StatelessWidget {
  const PCardContainer({
    super.key,
    required this.child,
    this.color,
    this.elevation,
    this.padding,
  });
  final Color? color;
  final double? elevation;

  /// If padding is null, use default padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4)
  final EdgeInsetsGeometry? padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Theme.of(context).colorScheme.surfaceContainer,
      elevation: elevation ?? 0,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding:
            padding == null
                ? EdgeInsets.symmetric(vertical: 8, horizontal: 12)
                : padding!,
        child: child,
      ),
    );
  }
}
