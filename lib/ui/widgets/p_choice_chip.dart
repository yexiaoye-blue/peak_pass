import 'package:flutter/material.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

/// 自定义ChoiceChip样式
/// 以目前个人了解到的属性，其与FilterChip只差在语义和一些其他属性(例如:onDelete,deleteIcon)
/// 所以暂时只使用这一个作为通用 Chip
class PChoiceChip extends StatelessWidget {
  const PChoiceChip({
    super.key,
    this.avatar,
    required this.label,
    this.selected = false,
    this.side,
    this.onSelected,
  });

  final Widget? avatar;
  final Widget label;
  final bool selected;

  /// If don't want the default border when not selected, set value BorderSide.none
  final BorderSide? side;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    return ChoiceChip(
      key: key,
      avatar: AnimatedSwitcher(
        duration: Durations.short3,
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: selected ? Icon(Icons.check, key: UniqueKey()) : avatar,
      ),
      label: label,
      selected: selected,
      showCheckmark: false,
      side: side,
      onSelected: onSelected,
      backgroundColor:
          isDark ? Theme.of(context).colorScheme.surfaceContainer : null,
    );
  }
}

// 该组件为项目中的特殊需要。
// 只为在样式上与ChoiceChip保持一致，做选中时标题展示使用。
class PChoiceChipNormal extends StatelessWidget {
  const PChoiceChipNormal({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isDark
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadiusGeometry.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          Text(
            text,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
