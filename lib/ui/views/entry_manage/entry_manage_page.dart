import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/ui/shared/common_text_field.dart';
import 'package:peak_pass/ui/shared/otp_auth_card.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:peak_pass/common/global.dart';
import 'package:peak_pass/ui/shared/category_selector.dart';
import 'package:peak_pass/ui/views/home/home_page.dart';
import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/ui/widgets/gap.dart';

class EntryManagePage extends StatefulWidget {
  const EntryManagePage({super.key});
  static const String routeName = 'entry-manage';

  @override
  State<EntryManagePage> createState() => _EntryManagePageState();
}

class _EntryManagePageState extends State<EntryManagePage> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CurrentEntryController>();
    final uiProvider = context.watch<KdbxUIProvider>();
    final isDark = context.read<ThemeProvider>().isDark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        context.goNamed(HomePage.routeName);
      },
      child: LoaderOverlay(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () => context.goNamed(HomePage.routeName),
              icon: Icon(Icons.arrow_back_ios_new_rounded),
            ),
            title: Text(
              controller.pageType == EntryPageType.newEntry
                  ? loc(context).newEntry
                  : loc(context).details,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
            child: Column(
              children: [
                const Gap.vertical(16),
                // Icon
                GestureDetector(
                  onTap: () async {
                    await controller.changeAvatar(context);
                  },

                  child: getAvatarWithProperty(
                    context: context,
                    iconModel: controller.iconModel,
                    dimension: 62,
                    iconColor:
                        isDark ? Theme.of(context).colorScheme.primary : null,
                    backgroundColor:
                        isDark
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),

                const Gap.vertical(18),

                // CategorySelector
                CategorySelector(
                  groups: uiProvider.groupsUI,
                  initialGroup: controller.targetGroup,
                  onExpansionChanged: (val) {
                    controller.readonly = false;
                  },
                  onSelected: (group) {
                    controller.readonly = false;
                    controller.targetGroup = group;
                  },
                  onTapAddGroup: () async {
                    await controller.showAddGroupDialog(context);
                  },
                ),

                const Gap.vertical(6),
                // 所有表单输入框
                Form(
                  key: controller.formKey,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.strEntries.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return controller.strEntries[index].key ==
                              KdbxKeyCommon.OTP
                          ? OtpAuthCard(field: controller.strEntries[index])
                          : CommonTextField(
                            field: controller.strEntries[index],
                          );
                    },
                    separatorBuilder: (context, index) => const Gap.vertical(6),
                  ),
                ),

                const Gap.vertical(8),
                // 'Add field' button
                if (controller.readonly == false)
                  PButtonContainer(
                    child: FilledButton.tonalIcon(
                      icon: Icon(
                        Icons.add_circle_outline_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => controller.showAddFieldDialog(context),
                      label: Text(loc(context).addField),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              if (!controller.readonly) {
                // 1. 编辑页面, 保存成功后 -> 浏览
                final isSuccess = await controller.save(context.loaderOverlay);
                if (isSuccess) {
                  controller.readonly = !controller.readonly;
                }
              } else {
                // 2. 浏览页面,点击后 -> 编辑
                controller.readonly = !controller.readonly;
              }
            },
            tooltip:
                controller.readonly ? loc(context).edit : loc(context).save,
            child: Icon(controller.readonly ? Icons.edit : Icons.save),
          ),
        ),
      ),
    );
  }
}
