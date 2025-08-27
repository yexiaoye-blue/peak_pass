import 'package:flutter/material.dart';
import 'package:peak_pass/utils/loc.dart';

/// TextField more menu button
class ActionMenu extends StatelessWidget {
  const ActionMenu({
    super.key,
    this.onModify,
    this.onUp,
    this.onDown,
    this.onRemove,
  });

  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onRemove;
  final VoidCallback? onModify;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: Offset(-38, 0),
      builder: (context, controller, child) {
        return GestureDetector(
          onTap: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          child: Icon(Icons.more_vert_rounded),
        );
      },
      menuChildren: [
        if (onModify != null)
          MenuItemButton(onPressed: onModify, child: Text(loc(context).modify)),
        MenuItemButton(onPressed: onUp, child: Text(loc(context).up)),
        MenuItemButton(onPressed: onDown, child: Text(loc(context).down)),
        MenuItemButton(onPressed: onRemove, child: Text(loc(context).remove)),
      ],
    );
  }
}
