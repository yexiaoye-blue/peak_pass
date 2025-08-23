import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/views/welcome/welcome_page.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

import '../../widgets/gap.dart';
import '../password_generator.dart';
import '../settings.dart';

class PDrawer extends StatelessWidget {
  const PDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final isDark = context.read<ThemeProvider>().isDark;
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        children: [
          // DrawerHeader or UserAccountsDrawerHeader
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            height: 120 + statusBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor:
                      isDark
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                  radius: 32,
                  child: FlutterLogo(size: 32),
                ),
                const Gap.horizontal(8),
                SizedBox(
                  height: 64,
                  child: Center(
                    child: Text(
                      'Peak Pass',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // content
          Card(
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.abc),
                  title: Text(loc(context).passwordGenerator),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  onTap: () {
                    context.pushNamed(PasswordGeneratorPage.routeName);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.compare_arrows),
                  // title: Text(loc(context).exportOrImport),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  title: Text(loc(context).export),
                  onTap: () async {
                    // 1. 让他选一个路径/名字之类的
                    final dbFileModel =
                        Provider.of<KdbxService>(
                          context,
                          listen: false,
                        ).kdbxWrapper.fileModel;
                    final dirname =
                        await FilePicker.platform.getDirectoryPath();
                    if (dirname == null || dirname.isEmpty) {
                      showToastBottom('未选择存储路径');
                      return;
                    }
                    final targetPath = p.join(dirname, dbFileModel.basename);
                    final originBytes = await dbFileModel.file.readAsBytes();
                    await File(targetPath).writeAsBytes(originBytes);
                    showToastBottom('导出成功!');
                  },
                ),

                // TODO: 远程备份
                // ListTile(
                //   leading: const Icon(Icons.backup_outlined),
                //   title: Text(loc(context).backupOrRestore),
                //   onTap: () {},
                // ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  title: Text(loc(context).settings),
                  onTap: () {
                    context.pushNamed(SettingsPage.routeName);
                  },
                ),
                // TODO: 关于
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  title: Text(loc(context).about),
                  onTap: () {},
                ),
                // TODO: 评分
                ListTile(
                  leading: const Icon(Icons.star_border),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  title: Text(loc(context).rateApp),
                  onTap: () async {
                    // context.pushNamed<Barcode?>(MobileScannerPage.routeName);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  tileColor: Theme.of(context).colorScheme.surfaceContainer,
                  title: Text(loc(context).safeExit),
                  onTap: () {
                    Provider.of<KdbxService>(context, listen: false).close();

                    context.goNamed(WelcomePage.routeName);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
