import 'package:flutter/material.dart';

class Headline extends StatelessWidget {
  const Headline(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
