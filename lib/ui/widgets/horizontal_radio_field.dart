import 'package:flutter/material.dart';

class HorizontalRadioField<T> extends StatefulWidget {
  const HorizontalRadioField({
    super.key,
    this.initialValue,
    required this.data,
    this.label,
    this.onSelected,
    this.errorPlaceholder = false,
  });
  final T? initialValue;
  final List<T> data;
  final Widget? label;
  final ValueChanged<T>? onSelected;

  /// 是否保留底部校验信息占位高度(TextFormField.helperText)
  final bool errorPlaceholder;

  @override
  State<HorizontalRadioField<T>> createState() => _HorizontalRadioFieldState<T>();
}

class _HorizontalRadioFieldState<T> extends State<HorizontalRadioField<T>> {
  late T currentValue;
  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue ?? widget.data[0];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(fontWeight: FontWeight.bold),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          widget.label ?? const SizedBox.shrink(),
          Row(
            spacing: 6,
            children: List.generate(widget.data.length, (index) {
              final item = widget.data[index];
              return TextButton.icon(
                onPressed: () {
                  setState(() {
                    currentValue = item;
                    widget.onSelected?.call(currentValue);
                  });
                },
                label: Text('$item', style: TextStyle(fontSize: 15)),
                icon: Icon(
                  currentValue == item
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
              );
            }),
          ),
          if (widget.errorPlaceholder) const SizedBox(height: 4),
        ],
      ),
    );
  }
}
