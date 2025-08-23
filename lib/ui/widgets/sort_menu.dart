import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';

import '../../common/enums/enums.dart';

/// 排序菜单
class SortMenu extends StatefulWidget {
  const SortMenu({
    super.key,
    required this.onPress,
    this.anchorBuilder,
    required this.data,
    required this.sortType,
  });

  final List<KdbxEntry> data;
  final ValueChanged<SortType> onPress;
  final Widget Function(
    BuildContext context,
    MenuController controller,
    Widget? child,
  )?
  anchorBuilder;
  final SortType sortType;

  @override
  State<SortMenu> createState() => _SortMenuState();
}

class _SortMenuState extends State<SortMenu> {
  SortType currentSortType = SortType.asc;
  void onItemPress(SortType type) {
    switch (type) {
      case SortType.asc:
        setState(() {
          widget.data.sort((a, b) => a.label?.compareTo(b.label ?? '') ?? 0);
        });
        break;
      case SortType.desc:
        setState(() {
          widget.data.sort((a, b) => b.label?.compareTo(a.label ?? '') ?? 0);
        });
        break;
      case SortType.newest:
        setState(() {
          widget.data.sort(
            (a, b) =>
                a.times.lastModificationTime.get()?.compareTo(
                  b.times.lastModificationTime.get() ?? DateTime.now(),
                ) ??
                0,
          );
        });
        break;
      case SortType.oldest:
        setState(() {
          widget.data.sort(
            (a, b) =>
                b.times.lastModificationTime.get()?.compareTo(
                  a.times.lastModificationTime.get() ?? DateTime.now(),
                ) ??
                0,
          );
        });
        break;
    }
    widget.onPress(type);
    setState(() {
      currentSortType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      builder: (context, controller, child) {
        if (widget.anchorBuilder != null) {
          return widget.anchorBuilder!(context, controller, child);
        }

        return IconButton(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          icon: Icon(Icons.filter_alt_rounded),
        );
      },
      menuChildren:
          SortType.values
              .map(
                (type) => MenuItemButton(
                  onPressed: () {
                    onItemPress(type);
                  },
                  leadingIcon: Icon(type.icon),
                  trailingIcon:
                      currentSortType == type ? Icon(Icons.done) : null,
                  child: Text(type.name),
                ),
              )
              .toList(),
    );
  }
}
