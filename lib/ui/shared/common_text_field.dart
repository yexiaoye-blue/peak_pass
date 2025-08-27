import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/utils/validate_utils.dart';
import 'package:provider/provider.dart';

import '../../common/constants/preset_fields.dart';
import '../../utils/common_utils.dart';
import '../../utils/faker_utils.dart';
import '../views/entry_manage/action_menu.dart';
import '../views/password_generator.dart';

/// 展示与修改表单项 基于[PTextFormField]封装
class CommonTextField extends StatelessWidget {
  const CommonTextField({super.key, required this.field});

  final MapEntry<KdbxKey, StringValue?> field;

  shouldShowGenerateIcon(TextInputType inputType) {
    if (inputType == TextInputType.visiblePassword ||
        inputType == TextInputType.name ||
        inputType == TextInputType.text) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.read<CurrentEntryController>();
    final controller = entryProvider.ctlModels[field.key]?.controller;
    final focusNode = entryProvider.ctlModels[field.key]?.focusNode;

    return PTextFormField(
      key: ValueKey(field.key),
      readonly: entryProvider.readonly,
      showCopyButton: !entryProvider.readonly,
      focusNode: focusNode,
      controller: controller,
      label: Text(LocUtils.localizeFieldName(context, field.key.key)),
      maxLines: PresetFields.fromKdbxKey(field.key).maxLines,
      iconsAlignment:
          PresetFields.fromKdbxKey(field.key).maxLines > 1
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
      prefixIcon: Icon(PresetFields.fromKdbxKey(field.key).icon),
      keyboardType: PresetFields.fromKdbxKey(field.key).inputType,
      // initialValue: field.value?.getText() ?? '',
      showRandomGenButton: shouldShowGenerateIcon(
        PresetFields.fromKdbxKey(field.key).inputType,
      ),
      suffixIcons: [
        if (entryProvider.readonly == false)
          ActionMenu(
            onUp: () async {
              await entryProvider.moveFieldUp(field);
            },
            onDown: () async {
              await entryProvider.moveFieldDown(field);
            },
            onRemove: () async {
              await entryProvider.removeFieldByKey(field.key);
            },
          ),

        if (entryProvider.readonly == true)
          GestureDetector(
            onTap: () {
              if (controller == null) return;
              if (controller.text.isNotEmpty) {
                copyToClipboard(controller.text)
                    .then((res) => showToastBottom('Copied to clipboard'))
                    .catchError(
                      (err) => showToastBottom('Failed to copy to clipboard'),
                    );
              }
            },
            child: Icon(Icons.content_copy, size: 22),
          ),
      ],
      validator:
          (val) => ValidateUtils.notEmpty(val, loc(context).cannotBeEmpty),
      onRandomGen: (TextInputType? type) async {
        if (type == TextInputType.visiblePassword) {
          final password = await context.pushNamed<String?>(
            PasswordGeneratorPage.routeName,
            extra: true,
          );
          if (password != null) {
            controller?.text = password;
          }
        } else if (type == TextInputType.name) {
          controller?.text = FakerUtils.instance.name;
        } else if (type == TextInputType.text) {
          controller?.text = FakerUtils.instance.title;
        }
      },
    );
  }
}
