import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/constants/otp_parameters.dart';
import 'package:peak_pass/common/constants/preset_fields.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/services/error_handle_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:peak_pass/common/global.dart';
import 'package:peak_pass/ui/widgets/gap.dart';

class EntryRecyclerBinDetail extends StatelessWidget {
  const EntryRecyclerBinDetail({super.key, required this.entry});
  final KdbxEntry entry;

  static const String routeName = 'entry-recycler-bin-detail';

  @override
  Widget build(BuildContext context) {
    logger.d(entry);

    final isDark = context.read<ThemeProvider>().isDark;
    final kdbxService = Provider.of<KdbxService>(context, listen: false);
    final kdbxUIProvider = context.read<KdbxUIProvider>();

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text(
            'entry item detail',
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
              getAvatarWithProperty(
                context: context,
                iconModel: CustomIconUtils.getIconModelByEntry(entry),
                dimension: 62,
                iconColor:
                    isDark ? Theme.of(context).colorScheme.primary : null,
                backgroundColor:
                    isDark
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.inversePrimary,
              ),

              const Gap.vertical(18),

              // 所有表单输入框
              ListView.separated(
                shrinkWrap: true,
                itemCount: entry.stringEntries.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final strEntries = entry.stringEntries.toList();
                  return _TextField(field: strEntries[index]);
                },
                separatorBuilder: (context, index) => const Gap.vertical(6),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            PButtonContainer(
              child: FilledButton(
                onPressed: () async {
                  final appLoc = loc(context);
                  final navigator = Navigator.of(context);
                  // 提示用户是否恢复
                  final res = await showAlertDialog(
                    context: context,
                    title: Text(appLoc.recoveryConfirm),
                    content: Text(appLoc.recoveryContent),
                  );

                  if (res != true) return;

                  try {
                    kdbxService.move(entry, kdbxService.rootGroup);
                    await kdbxService.save();
                    kdbxUIProvider.resetUIModel();
                    navigator.pop();
                    showToastBottom(appLoc.successfully(appLoc.recovery, ''));
                  } catch (e, stackTrace) {
                    logger.e(e);
                    if (context.mounted) {
                      if (e is BusinessException) {
                        ErrorHandlerService.handleBusinessException(appLoc, e);
                      } else {
                        ErrorHandlerService.handleException(
                          context,
                          e,
                          stackTrace,
                        );
                      }
                    }
                  }
                },
                child: Text(loc(context).recovery),
              ),
            ),
            PButtonContainer(
              child: FilledButton.tonal(
                onPressed: () async {
                  final appLoc = loc(context);
                  final navigator = Navigator.of(context);
                  // 提示用户是否删除
                  final res = await showAlertDialog(
                    context: context,
                    title: Text(appLoc.deleteFromRecycleBinConfirm),
                    content: Text(appLoc.deleteFromRecycleBinContent),
                  );

                  if (res != true) return;

                  try {
                    kdbxService.removePermanently(entry);
                    await kdbxService.save();
                    kdbxUIProvider.resetUIModel();
                    navigator.pop();
                    showToastBottom(appLoc.successfully(appLoc.delete, ''));
                  } catch (e, stackTrace) {
                    if (context.mounted) {
                      if (e is BusinessException) {
                        ErrorHandlerService.handleBusinessException(appLoc, e);
                      } else {
                        ErrorHandlerService.handleException(
                          context,
                          e,
                          stackTrace,
                        );
                      }
                    }
                  }
                },
                child: Text(loc(context).delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({required this.field});
  final MapEntry<KdbxKey, StringValue?> field;

  String _parseIfOTPAuth(String? value) {
    if (value == null) return '';
    if (!value.startsWith(OtpParameters.prefix)) return value;
    return Uri.decodeComponent(value);
  }

  CrossAxisAlignment _iconsAlignment(KdbxKey key) {
    if (key == KdbxKeyCommon.OTP) return CrossAxisAlignment.start;
    if (PresetFields.fromKdbxKey(field.key).maxLines > 1) {
      return CrossAxisAlignment.start;
    }
    return CrossAxisAlignment.center;
  }

  @override
  Widget build(BuildContext context) {
    return PTextFormField(
      key: ValueKey(field.key),
      readonly: true,
      showCopyButton: false,
      label: Text(LocUtils.localizeFieldName(context, field.key.key)),
      autoWrap: field.key == KdbxKeyCommon.OTP,
      maxLines: PresetFields.fromKdbxKey(field.key).maxLines,

      initialValue: _parseIfOTPAuth(field.value?.getText()),
      iconsAlignment: _iconsAlignment(field.key),
      prefixIcon: Icon(PresetFields.fromKdbxKey(field.key).icon),
      keyboardType: PresetFields.fromKdbxKey(field.key).inputType,
      validator: (value) => null,
    );
  }
}
