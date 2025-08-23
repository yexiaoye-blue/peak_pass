import 'package:flutter/material.dart';

// PExpansionCard by ExpansionTile
class PExpansionCard extends StatefulWidget {
  const PExpansionCard({
    super.key,
    required this.title,
    this.trailing,
    required this.children,
    this.initiallyExpanded = false,
    this.controller,
    this.onExpansionChanged,
    this.shape,
  });

  final Widget title;
  final Widget? trailing;
  final List<Widget> children;
  final bool initiallyExpanded;
  final ShapeBorder? shape;

  final ValueChanged<bool>? onExpansionChanged;
  final ExpansibleController? controller;

  @override
  State<PExpansionCard> createState() => _PExpansionCardState();
}

class _PExpansionCardState extends State<PExpansionCard> {
  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      controller: widget.controller,
      onExpansionChanged: widget.onExpansionChanged,
      expandedAlignment: Alignment.topLeft,

      // normal style
      initiallyExpanded: widget.initiallyExpanded,
      childrenPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      // backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      collapsedShape:
          widget.shape ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: DividerTheme.of(context).color ?? Colors.grey.shade400,
            ),
          ),

      // collapsed style
      shape:
          widget.shape ??
          OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: DividerTheme.of(context).color ?? Colors.grey.shade400,
            ),
          ),

      // collapsedBackgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      title: widget.title,
      trailing: widget.trailing,
      children: widget.children,
    );
  }
}
