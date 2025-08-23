import 'package:flutter/material.dart';

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
          MenuItemButton(onPressed: onModify, child: const Text('Modify')),
        MenuItemButton(onPressed: onUp, child: const Text('Up')),
        MenuItemButton(onPressed: onDown, child: const Text('Down')),
        MenuItemButton(onPressed: onRemove, child: const Text('Remove')),
      ],
    );
  }
}
