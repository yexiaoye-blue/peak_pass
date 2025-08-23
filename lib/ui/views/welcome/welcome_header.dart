import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/ui/views/language.dart';
import 'package:peak_pass/ui/widgets/fade_cross_transition.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/file_provider.dart';

import 'package:provider/provider.dart';

class WelcomeHeader extends StatefulWidget implements PreferredSizeWidget {
  const WelcomeHeader({
    super.key,
    required this.onToggle,
    required this.animation,
  });
  final VoidCallback onToggle;
  final Animation<double> animation;

  @override
  State<WelcomeHeader> createState() => _WelcomeHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _WelcomeHeaderState extends State<WelcomeHeader> {
  @override
  Widget build(BuildContext context) {
    final fileProvider = context.watch<FileProvider>();
    return AppBar(
      title: FadeCrossTransition(
        animation: widget.animation,
        alignment: Alignment.centerLeft,
        firstChild: Text(
          fileProvider.isRecycleBinPage
              ? loc(context).recycleBin
              : loc(context).databases,
        ),
        secondChild: TextButton(
          onPressed: fileProvider.toggleSelects,
          child: Text(loc(context).checkAll),
        ),
      ),

      actionsPadding: const EdgeInsets.only(right: 12),
      actions: [
        FadeCrossTransition(
          animation: widget.animation,
          alignment: Alignment.centerRight,
          firstChild: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // recycle bin
              IconButton(
                onPressed: () async {
                  fileProvider.isRecycleBinPage =
                      !fileProvider.isRecycleBinPage;
                },
                icon: Icon(
                  fileProvider.isRecycleBinPage
                      ? Icons.storage_outlined
                      : Icons.restore_page_outlined,
                ),
              ),
              // check all
              IconButton(
                onPressed: widget.onToggle,
                icon: const Icon(Icons.check_box_outlined),
              ),
              IconButton(
                onPressed: () => context.pushNamed(LanguagePage.routeName),
                icon: Icon(Icons.translate_rounded),
              ),
            ],
          ),
          secondChild: TextButton(
            onPressed: widget.onToggle,
            child: Text(loc(context).cancel),
          ),
        ),
      ],
    );
  }
}
