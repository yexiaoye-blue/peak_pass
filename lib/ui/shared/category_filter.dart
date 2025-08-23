import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

import '../../common/global.dart';
import '../widgets/p_choice_chip.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({
    super.key,
    required this.isGridLayout,
    this.animation,
    required this.groups,
    required this.selectedGroups,
    required this.onValuesChanged,
  });

  final bool isGridLayout;
  final Animation<double>? animation;
  final List<KdbxGroup> groups;
  final List<KdbxGroup> selectedGroups;
  final ValueChanged<List<KdbxGroup>> onValuesChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    if (!isGridLayout) {
      // horizontal list
      return SliverFadeTransition(
        opacity:
            animation != null
                ? Tween<double>(begin: 1, end: 0).animate(animation!)
                : AlwaysStoppedAnimation<double>(isGridLayout ? 0 : 1),
        sliver: SliverToBoxAdapter(
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final currentGroup = groups[index];
                return PChoiceChip(
                  // side: BorderSide.none,
                  avatar: getOriginalIcon(
                    CustomIconUtils.getIconModel(
                      currentGroup.icon.get(),
                      currentGroup.customIcon,
                    ),
                  ),
                  label: Text(currentGroup.name.get() ?? 'Unknown'),
                  selected: selectedGroups.contains(currentGroup),
                  onSelected: (selected) {
                    selected
                        ? selectedGroups.add(currentGroup)
                        : selectedGroups.remove(currentGroup);
                    onValuesChanged(selectedGroups);
                  },
                );
              },
              separatorBuilder: (context, index) => SizedBox(width: 4),
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
            ),
          ),
        ),
      );
    } else {
      // grid view
      return SliverFadeTransition(
        opacity:
            animation != null
                ? Tween<double>(begin: 0, end: 1).animate(animation!)
                : AlwaysStoppedAnimation<double>(isGridLayout ? 1 : 0),
        sliver: SliverGrid.builder(
          itemCount: groups.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 2 / 1,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onValuesChanged([groups[index]]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
                child: Row(
                  spacing: 12,
                  children: [
                    // Icon
                    Container(
                      child: getAvatarWithProperty(
                        context: context,
                        iconModel: CustomIconUtils.getIconModel(
                          groups[index].icon.get(),
                          groups[index].customIcon,
                        ),
                        dimension: 48,
                        iconColor:
                            isDark
                                ? Theme.of(context).colorScheme.primary
                                : null,
                        backgroundColor:
                            isDark
                                ? Theme.of(
                                  context,
                                ).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          groups[index].name.get() ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Item count
                        Text(groups[index].entries.length.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
  }
}
