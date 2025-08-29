
import 'package:flutter/material.dart';
import 'package:peak_pass/ui/widgets/fade_cross_transition.dart';

class AnimationHeader extends StatelessWidget implements PreferredSizeWidget {
  const AnimationHeader({
    super.key,
    required this.animation,
    this.leftEditingChild,
    this.rightEditingChild,
    this.leftNormalChild,
    this.rightNormalChild,
  });
  final Animation<double> animation;

  final Widget? leftEditingChild;
  final Widget? rightEditingChild;
  final Widget? leftNormalChild;
  final Widget? rightNormalChild;

  @override
  Widget build(BuildContext context) {

    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 0,
      titleSpacing: 8,
      title: FadeCrossTransition(
        animation: animation,
        alignment: Alignment.centerLeft,
        firstChild: leftNormalChild,
        secondChild: leftEditingChild,
      ),

      actionsPadding: const EdgeInsets.only(right: 12),
      actions: [
        FadeCrossTransition(
          animation: animation,
          alignment: Alignment.centerRight,
          firstChild: rightNormalChild,
          secondChild: rightEditingChild,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
