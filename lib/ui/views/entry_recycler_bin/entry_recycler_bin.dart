import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/helper/animation_header.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_controller.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_detail.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_footer.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_item.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:provider/provider.dart';

/// 条目回收站
class EntryRecyclerBin extends StatefulWidget {
  const EntryRecyclerBin({super.key});

  static const String routeName = "entry-recycle-bin";

  @override
  State<EntryRecyclerBin> createState() => _EntryRecyclerBinState();
}

class _EntryRecyclerBinState extends State<EntryRecyclerBin>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<
      KdbxUIProvider,
      EntryRecyclerBinController
    >(
      create:
          (context) => EntryRecyclerBinController(
            vsync: this,
            kdbxUIProvider: context.read<KdbxUIProvider>(),
            kdbxService: Provider.of<KdbxService>(context, listen: false),
          ),

      update: (context, value, previous) {
        previous?.kdbxUIProvider = value;
        return previous ??
            EntryRecyclerBinController(
              vsync: this,
              kdbxUIProvider: context.read<KdbxUIProvider>(),
              kdbxService: Provider.of<KdbxService>(context, listen: false),
            );
      },
      child: _EntryRecycleBin(),
    );
  }
}

class _EntryRecycleBin extends StatefulWidget {
  const _EntryRecycleBin();

  @override
  State<_EntryRecycleBin> createState() => __EntryRecycleBinState();
}

class __EntryRecycleBinState extends State<_EntryRecycleBin> {
  // 1. 首先是可以查看详情， 点进详情后，也是也可以（只可以）进行恢复操作的
  // 2.
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EntryRecyclerBinController>();
    return Scaffold(
      appBar: AnimationHeader(
        animation: controller.animation,
        leftNormalChild: Row(
          spacing: 4,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
            Flexible(
              child: Text(
                loc(context).recycleBin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        leftEditingChild: TextButton(
          onPressed: () {
            controller.toggleEntrySelection();
          },
          child: Text(loc(context).checkAll),
        ),
        rightEditingChild: TextButton(
          onPressed: () {
            controller.toNormal();
            controller.clearEntrySelection();
          },
          child: Text(loc(context).cancel),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: StreamBuilder(
          stream: controller.recycleBinChanges,
          builder: (context, asyncSnapshot) {
            return ListView.separated(
              itemBuilder: (context, index) {
                final entry = controller.entries[index];

                return Padding(
                  padding: EdgeInsets.only(
                    // 为最后一个添加padding, 避免底部被遮挡
                    bottom: controller.entries.length - 1 == index ? 120 : 0,
                  ),
                  child: EntryRecyclerBinItem(
                    animation: controller.animation,
                    entry: entry,
                    onLongPress: controller.toEditing,
                    onTap: () {
                      context.pushNamed(
                        EntryRecyclerBinDetail.routeName,
                        extra: entry,
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (_, _) => const Gap.vertical(4),
              itemCount: controller.entries.length,
            );
          },
        ),
      ),
      floatingActionButton: EntryRecyclerBinFooter(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
