import 'package:flutter/material.dart';

class PButton extends StatefulWidget {
  const PButton({
    super.key,
    required this.onPressed,
    this.backgroundColor,
    this.icon,
    this.fillWidth = true,
    this.isTonal = false,
    required this.child,
  });

  /// 是否填满父容器宽度
  final bool fillWidth;

  /// 是否为主色调的浅色按钮
  final bool isTonal;
  final dynamic Function() onPressed;

  final Widget child;
  final Widget? icon;
  final Color? backgroundColor;

  @override
  State<PButton> createState() => _PButtonState();
}

class _PButtonState extends State<PButton> {
  bool _loading = false;

  Future<void> _handlePress() async {
    final result = widget.onPressed();
    if (result is Future) {
      setState(() => _loading = true);
      try {
        await result;
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _loading ? null : _handlePress,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          widget.backgroundColor ??
              (widget.isTonal
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.primary),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
        ),
      ),

      icon: widget.icon,
      // TODO: loading child 例如: ElevatedButton(onpress, child: loadingChild)
      // 根据 p_button_container的思路进行封装
      label: DefaultTextStyle.merge(
        style: TextStyle(
          color:
              widget.isTonal
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.onPrimary,
        ),
        child: AnimatedSwitcher(
          duration: Durations.short3,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              _loading ? _buildLoading(context) : widget.child,

              // Just a placeholder to fix the size of the button based on its content.
              Opacity(opacity: 0, child: widget.child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.surface,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
