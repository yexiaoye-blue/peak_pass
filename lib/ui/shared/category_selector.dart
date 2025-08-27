import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/utils/loc.dart';

import '../../common/global.dart';
import '../widgets/p_choice_chip.dart';
import '../widgets/p_expansion_card.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({
    super.key,
    required this.initialGroup,
    required this.groups,
    required this.onSelected,
    this.onExpansionChanged,
    this.onTapAddGroup,
  });

  final KdbxGroup? initialGroup;
  final List<KdbxGroup> groups;
  final ValueChanged<KdbxGroup> onSelected;
  final VoidCallback? onTapAddGroup;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  bool _isExpanded = false;
  late KdbxGroup _currentGroup;

  @override
  void initState() {
    _currentGroup = widget.initialGroup ?? widget.groups[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PExpansionCard(
      onExpansionChanged: (val) {
        setState(() {
          _isExpanded = val;
          widget.onExpansionChanged?.call(val);
        });
      },
      title: Text(loc(context).groups),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // default selected
          PChoiceChipNormal(
            // 如果icon == null 则渲染 custom icon
            icon: Icons.abc,
            text: LocUtils.localizeGroupName(context, _currentGroup.name.get()),
          ),
          AnimatedRotation(
            // 负数->逆时针；正数->顺时针
            turns: _isExpanded ? -180 / 360 : 0,
            duration: Durations.medium1,
            child: Icon(Icons.keyboard_arrow_down_rounded),
          ),
        ],
      ),
      children: [
        Wrap(
          spacing: 5.0,
          children: [
            for (final item in widget.groups)
              PChoiceChip(
                avatar: AnimatedSwitcher(
                  duration: Durations.short3,
                  transitionBuilder:
                      (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                  child:
                      _currentGroup == item
                          ? Icon(Icons.check, key: UniqueKey())
                          : getOriginalIcon(
                            CustomIconUtils.getIconModel(
                              item.icon.get(),
                              item.customIcon,
                            ),
                          ),
                ),
                label: Text(
                  LocUtils.localizeGroupName(context, item.name.get()),
                ),
                selected: _currentGroup == item,
                onSelected: (val) {
                  setState(() {
                    _currentGroup = item;
                    widget.onSelected(item);
                  });
                },
              ),
            // add button
            PChoiceChip(
              avatar: Icon(Icons.add),
              label: Text(loc(context).createGroup),
              // just like onTap
              onSelected: (_) {
                widget.onTapAddGroup?.call();
              },
            ),
          ],
        ),
      ],
    );
  }
}
