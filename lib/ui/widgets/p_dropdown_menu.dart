import 'package:flutter/material.dart';

class PDropdownMenu<T> extends StatefulWidget {
  const PDropdownMenu({
    super.key,
    this.label,
    this.controller,
    required this.data,
    this.initialIndex = 0,
    this.onSelected,
    required this.entryBuilder,
  });

  final Widget? label;
  final List<T> data;
  final int initialIndex;
  final TextEditingController? controller;
  final ValueChanged<T?>? onSelected;

  /// 使用该类[PDropdownMenuEntry]带有默认style
  final DropdownMenuEntry<T> Function(BuildContext context, T item, int index) entryBuilder;

  @override
  State<PDropdownMenu<T>> createState() => _PDropdownMenuState<T>();
}

class _PDropdownMenuState<T> extends State<PDropdownMenu<T>> {
  T get initialSelection => widget.data[widget.initialIndex];

  late T currentValue;
  @override
  void initState() {
    super.initState();

    currentValue = initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * 0.4;

    // menu anchor 的偏移
    final Offset menuOffset = Offset(screenWidth - menuWidth - 32, 0);

    return DefaultTextStyle.merge(
      style: TextStyle(fontWeight: FontWeight.bold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          widget.label ?? const SizedBox.shrink(),
          DropdownMenu<T>(
            width: double.infinity,
            controller: widget.controller,
            initialSelection: initialSelection,
            menuStyle: MenuStyle(
              fixedSize: WidgetStatePropertyAll(Size.fromWidth(menuWidth)),
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 4, vertical: 6)),
            ),
            alignmentOffset: menuOffset,

            /// 占位
            helperText: ' ',
            inputDecorationTheme: InputDecorationTheme(
              border: WidgetStateInputBorder.resolveWith((states) {
                if (states.contains(WidgetState.error)) {
                  return OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.red.shade400),
                  );
                }

                if (states.contains(WidgetState.focused)) {
                  return OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.inversePrimary),
                  );
                }

                return OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: DividerTheme.of(context).color ?? Colors.grey.shade300,
                  ),
                );
              }),
            ),

            onSelected: (T? value) {
              if (value != null) {
                setState(() {
                  currentValue = value;
                });
              }
              widget.onSelected?.call(value);
            },
            dropdownMenuEntries: List.generate(
              widget.data.length,
              (index) => widget.entryBuilder(context, widget.data[index], index),
            ),
            // widget.entryBuilder(context, widget.data),
          ),
        ],
      ),
    );
  }
}

final ButtonStyle _defaultMenuEntryStyle = ButtonStyle(
  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
);

class PDropdownMenuEntry<T> extends DropdownMenuEntry<T> {
  PDropdownMenuEntry({
    required super.value,
    required super.label,
    super.labelWidget,
    super.leadingIcon,
    super.trailingIcon,
    super.enabled,
    ButtonStyle? style,
  }) : super(style: style ?? _defaultMenuEntryStyle);
}
