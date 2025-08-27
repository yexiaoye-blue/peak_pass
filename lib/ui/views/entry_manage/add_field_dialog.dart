import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/ui/views/scanner_page.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/ui/widgets/p_choice_chip.dart';

class AddFieldDialog extends StatelessWidget {
  const AddFieldDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CurrentEntryController>();
    return AlertDialog(
      title: Text(loc(context).chooseFileType),
      content: Wrap(
        spacing: 4,
        children: [
          for (final item in provider.availableFields)
            PChoiceChip(
              avatar: Icon(
                item.icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(LocUtils.localizeFieldName(context, item.key.key)),
              selected: provider.selectedFieldKey == item.key,
              onSelected: (val) {
                if (val) {
                  provider.selectedFieldKey = item.key;
                }
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          child: Text(loc(context).confirm),
          onPressed: () {
            // 如果是 otp auth 则跳转到 扫码页面
            if (provider.selectedFieldKey == KdbxKeyCommon.OTP) {
              context.pushNamed(MobileScannerPage.routeName);
            } else {
              // 添加普通的 entry
              provider.addField(provider.selectedFieldKey!);
            }

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
