import 'package:flutter/material.dart';

class PButtonContainer extends StatelessWidget {
  const PButtonContainer({
    super.key,
    this.padding = const EdgeInsets.all(0),
    required this.child,
  });

  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constrains) {
          return constrains.maxWidth != double.infinity
              // Column 占满父容器宽度
              ? ConstrainedBox(
                constraints: BoxConstraints(minWidth: constrains.maxWidth),
                child: child,
              )
              // Row 最大宽度为屏幕宽度(Row: 0 < width < double.infinity)
              : ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width,
                ),
                child: child,
              );
        },
      ),
    );
  }
}
