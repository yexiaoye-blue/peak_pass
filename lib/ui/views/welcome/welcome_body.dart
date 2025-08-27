import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/ui/views/unlock_database/unlock_database.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:peak_pass/view_models/locale_provider.dart';
import 'package:provider/provider.dart';

class WelcomeBody extends StatelessWidget {
  const WelcomeBody({
    super.key,
    required this.databaseInfo,
    required this.animation,
    this.onLongPress
  });
  final List<FileModel> databaseInfo;
  final Animation<double> animation;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          itemCount: databaseInfo.length,
          itemBuilder: (BuildContext context, int index) {
            return _EntryListTile(
              key: ValueKey(databaseInfo[index].basenameWithoutExtension),
              animation: animation,
              info: databaseInfo[index],
              onLongPress: onLongPress,
            );
          },
          separatorBuilder: (context, index) => SizedBox(height: 4),
        ),
        SizedBox(height: 150),
      ],
    );
  }
}

class _EntryListTile extends StatelessWidget {
  const _EntryListTile({
    super.key,
    required this.animation,
    required this.info,
    this.onLongPress,
  });
  final Animation<double> animation;
  final FileModel info;
  final VoidCallback? onLongPress;

  static const double checkBoxWidth = 32;

  void _handleTap(FileProvider provider, BuildContext context, bool canToggle) {
    if (canToggle) {
      provider.toggleSelects([info]);
      return;
    }
    if (provider.isRecycleBinPage) {
      // 点击 提示用户是否恢复
      showAlertDialog(
        context: context,
        title: const Text('Alert'),
        content: const Text('Recovery it from Recycle Bin?'),
      ).then((res) {
        if (res == true) {
          provider.recoverModels([info]);
        }
      });
    } else {
      // 普通数据锁页库跳转到解锁页面
      context.pushNamed(UnlockDatabasePage.routeName, extra: info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileProvider = context.read<FileProvider>();
    final locale = context.read<LocaleProvider>().locale;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final value = animation.value;
        return ListTile(
          onTap: () => _handleTap(fileProvider, context, value > 0.5),
          onLongPress: () {
            onLongPress?.call();
          },
          minLeadingWidth: 0,
          horizontalTitleGap: 0,
          minVerticalPadding: 2,
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
          visualDensity: VisualDensity.comfortable,
          tileColor: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(8),
          ),
          leading: SizedBox.shrink(
            child: Opacity(
              opacity: value,
              child: Checkbox(
                value: fileProvider.isSelected(info),
                onChanged: (val) {},
              ),
            ),
          ),
          title: Transform.translate(
            offset: Offset(_EntryListTile.checkBoxWidth * value, 0),
            child: Text(
              info.basenameWithoutExtension,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          subtitle: Transform.translate(
            offset: Offset(_EntryListTile.checkBoxWidth * value, 0),
            child: FutureBuilder<FileStat>(
              future: info.file.stat(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final createdTime = DateFormat.yMMMMd(
                    locale.toString(),
                  ).add_Hms().format(snapshot.data!.changed);

                  return Text(createdTime);
                } else if (snapshot.hasError) {
                  return const Text('');
                }
                return const Center(child: CircularProgressIndicator(),);
              },
            ),
          ),
          trailing:
              value < 0.95
                  ? Transform.translate(
                    offset: Offset(
                      // 移出 tileColor范围 后隐藏
                      value * (_EntryListTile.checkBoxWidth - 16),
                      0,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                    ),
                  )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}
