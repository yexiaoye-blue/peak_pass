import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/ui/shared/file_info_item.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/loc.dart';

Future<bool?> showSimpleAlertDialog({
  required BuildContext context,
  required String title,
  required String content,
}) async {
  return showAlertDialog(
    context: context,
    title: Text(title),
    content: Text(content),
  );
}

final BorderRadius unifiedBorderRadius = BorderRadius.circular(18);

Future<bool?> showAlertDialog({
  required BuildContext context,
  required Widget? title,
  required Widget? content,
  List<Widget>? actions,
}) async => showDialog<bool?>(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      shape: RoundedRectangleBorder(borderRadius: unifiedBorderRadius),
      actions:
          actions ??
          [
            TextButton(
              style: ButtonStyle(
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.96),
                ),
              ),
              child: Text(loc(context).cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(loc(context).confirm),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
    );
  },
);

Future<bool?> showMutiLineInputDialog({
  required BuildContext context,
  int maxLines = 3,
  required Widget title,
  required Widget label,
  required TextEditingController controller,
  String? Function(String? value)? validator,
}) async {
  final GlobalKey<FormState> _formKey = GlobalKey();
  return showCommonDialog(
    context: context,
    title: title,
    contents: [
      Form(
        key: _formKey,
        child: PTextFormField(
          controller: controller,
          maxLines: maxLines,
          label: label,
          validator: validator,
        ),
      ),
    ],
    actions: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 6,
        children: [
          FilledButton.tonal(
            onPressed: () {
              controller.clear();
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            child: Text(loc(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? true) {
                Navigator.of(context).pop(true);
              }
            },
            style: ButtonStyle(
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            child: Text(loc(context).confirm),
          ),
        ],
      ),
    ],
  );
}

/// confirm: return true
/// cancel: return null
Future<bool?> showCommonDialog({
  required BuildContext context,
  required Widget title,
  TextStyle? titleStyle,
  List<Widget>? contents,
  List<Widget>? actions,
}) async => showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: unifiedBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            DefaultTextStyle.merge(
              style: titleStyle ?? TextTheme.of(context).titleMedium,
              child: title,
            ),
            const SizedBox(height: 16),
            if (contents != null) ...contents,
            if (contents != null) const SizedBox(height: 24),
            if (actions != null)
              ...actions
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 6,
                children: [
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: Text(loc(context).cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ButtonStyle(
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: Text(loc(context).confirm),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  },
);

Future<void> showEmptyDialog({
  required BuildContext context,
  required Widget child,
}) async => showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: unifiedBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: child,
      ),
    );
  },
);

Future<void> showDbInfoDialog({
  required BuildContext context,
  required FileModel model,
}) async => showDialog(
  context: context,
  builder: (BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24.0),
      shape: RoundedRectangleBorder(borderRadius: unifiedBorderRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            FileInfoItem(title: loc(context).path, content: model.path),
            FileInfoItem<int>(
              title: loc(context).size,
              content: FileStat.statSync(model.path).size,
              formatType: ItemFormatType.fileSize,
            ),
            FileInfoItem<DateTime>(
              title: loc(context).createdAt,
              content: FileStat.statSync(model.path).modified,
              formatType: ItemFormatType.dateTimeDefault,
            ),
            FileInfoItem<DateTime>(
              title: loc(context).accessedAt,
              content: FileStat.statSync(model.path).accessed,
              formatType: ItemFormatType.dateTimeDefault,
            ),

            FileInfoItem<DateTime>(
              title: loc(context).modifiedAt,
              content: FileStat.statSync(model.path).modified,
              formatType: ItemFormatType.dateTimeDefault,
            ),
          ],
        ),
      ),
    );
  },
);

Dialog errorDialog = Dialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
  ), //this right here
  child: Container(
    height: 300.0,
    width: 300.0,

    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('Cool', style: TextStyle(color: Colors.red)),
        ),
        Padding(
          padding: EdgeInsets.all(15.0),
          child: Text('Awesome', style: TextStyle(color: Colors.red)),
        ),
        Padding(padding: EdgeInsets.only(top: 50.0)),
        TextButton(
          onPressed: () {
            // Navigator.of(context).pop();
          },
          child: Text(
            'Got It!',
            style: TextStyle(color: Colors.purple, fontSize: 18.0),
          ),
        ),
      ],
    ),
  ),
);
