import 'package:flutter/material.dart';

/// 通用ListTile样式 01 -> Password Generator页
class PListTileStyle1 extends StatelessWidget {
  const PListTileStyle1({
    super.key,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.dense = true,
    this.showDivider = true,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final Widget trailing;

  /// If dense if true, trailing height is constrains to 42
  final bool dense;
  final bool showDivider;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: dense,
      title: Text(title),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      subtitle: Text(subtitle),
      trailing:
          dense
              ? SizedBox(height: 42, child: FittedBox(child: trailing))
              : trailing,
      shape:
          showDivider
              ? Border(
                bottom: BorderSide(
                  color:
                      DividerTheme.of(context).color ??
                      Theme.of(context).colorScheme.outlineVariant,
                ),
              )
              : null,
    );
  }
}
