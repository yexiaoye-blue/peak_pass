import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/global.dart';
import 'package:peak_pass/ui/views/home/home_page_controller.dart';
import 'package:peak_pass/ui/widgets/fade_cross_transition.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

class EntryListTile extends StatelessWidget {
  const EntryListTile({
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
    final homeController =
        hasAnimation ? context.read<HomePageController>() : null;
    final leading =
        hasAnimation
            ? FadeCrossTransition(
              animation: animation!,
              firstChild: getIcon(
                CustomIconUtils.getIconModelByEntry(entry),
                context,
              ),
              secondChild: Checkbox(
                value: homeController?.isEntrySelected(entry),
                onChanged: (val) {
                  homeController?.toggleEntrySelection([entry]);
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
        trailing: const Icon(Icons.copy),
        tileColor:
            isDark ? Theme.of(context).colorScheme.surfaceContainer : null,
        shape:
            isDark
                ? RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                )
                : null,
        onTap:
            homeController?.isEditing ?? false
                ? () => homeController?.toggleEntrySelection([entry])
                : onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}
