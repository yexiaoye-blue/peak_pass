import 'package:flutter/material.dart';

class AnimatedListTile extends StatelessWidget {
  const AnimatedListTile({
    super.key,
    required this.animation,
    this.onTap,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final Animation<double> animation;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ListTile(
          onTap: onTap,
          minLeadingWidth: 0,
          horizontalTitleGap: 0,
          minVerticalPadding: 2,
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
          visualDensity: VisualDensity.comfortable,
          tileColor: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
          leading: Stack(
            children: [
              FadeTransition(
                opacity: animation,
                child: Checkbox(value: false, onChanged: (val) {}),
              ),
              FadeTransition(
                opacity: ReverseAnimation(animation),
                child: leading,
              ),
            ],
          ),
          title: title,
          subtitle: subtitle,
          trailing: trailing,
        );
      },
    );
  }
}
