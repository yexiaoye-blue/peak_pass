import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';

class CounterField extends StatelessWidget {
  const CounterField({
    super.key,
    this.label,
    this.min = 0,
    this.max,
    required this.controller,
  });
  final Widget? label;
  final int min;
  final int? max;

  final TextEditingController controller;

  void _handleSub() {
    int curCounter = int.parse(controller.text);
    if (curCounter <= min) return;
    controller.text = (int.parse(controller.text) - 1).toString();
  }

  void _handleAdd() {
    int curCounter = int.parse(controller.text);
    if (max != null) {
      if (curCounter >= curCounter) return;
    }
    controller.text = (int.parse(controller.text) + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    return PTextFormField(
      label: label,
      controller: controller,
      // readonly: true,
      prefixIcon: IconButton(onPressed: _handleSub, icon: Icon(Icons.remove)),
      suffixIcon: IconButton(onPressed: _handleAdd, icon: Icon(Icons.add)),
      textAlign: TextAlign.center,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => null,
    );
  }
}
