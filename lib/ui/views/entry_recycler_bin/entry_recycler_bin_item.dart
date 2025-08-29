import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/global.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_controller.dart';
import 'package:peak_pass/ui/widgets/fade_cross_transition.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

class EntryRecyclerBinItem extends StatelessWidget {
  const EntryRecyclerBinItem({
    super.key,
    this.animation,
    required this.entry,
    this.onTap,
    this.onLongPress,
  });

  final Animation<double>? animation;
  final KdbxEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  bool get hasAnimation => animation != null;

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    final controller =
        hasAnimation ? context.read<EntryRecyclerBinController>() : null;
    final leading =
        hasAnimation
            ? FadeCrossTransition(
              animation: animation!,
              firstChild: getIcon(
                CustomIconUtils.getIconModelByEntry(entry),
                context,
              ),
              secondChild: Checkbox(
                value: controller?.isSelected(entry),
                onChanged: (val) {
                  controller?.toggleEntrySelection([entry]);
                },
              ),
            )
            : getIcon(CustomIconUtils.getIconModelByEntry(entry), context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDark ? 8 : 0),
      child: ListTile(
        dense: true,
        leading: leading,
        title: Text(
          entry.debugLabel() ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          entry.times.lastModificationTime.get()?.toLocal().toString() ??
              'Unknown',
        ),
        tileColor:
            isDark ? Theme.of(context).colorScheme.surfaceContainer : null,
        shape:
            isDark
                ? RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                )
                : null,
        onTap:
            controller?.isNormal ?? true
                ? onTap
                : () => controller?.toggleEntrySelection([entry]),
        onLongPress: onLongPress,
      ),
    );
  }
}
