import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/services/error_handle_service.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';

import 'package:peak_pass/ui/views/unlock_database/unlock_database.dart';

import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:provider/provider.dart';

import '../create_database/create_database_page.dart';

class WelcomeFooter extends StatefulWidget {
  const WelcomeFooter({
    super.key,
    required this.alignment,
    required this.animation,
  });

  /// 按钮排列方式: vertical or horizontal
  final Axis alignment;
  final Animation<double> animation;

  @override
  State<WelcomeFooter> createState() => _WelcomeFooterState();
}

class _WelcomeFooterState extends State<WelcomeFooter> {
  // 正常按钮: 向下
  late final Animation<Offset> slideDown;
  // 正常按钮: opacity 1 -> 0
  late final Animation<double> fadeOut;

  // 删除按钮: 向上
  late final Animation<Offset> slideUp;
  // 删除按钮: opacity 0 -> 1
  late final Animation<double> fadeIn;

  @override
  void initState() {
    super.initState();
    slideDown = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 1),
    ).chain(CurveTween(curve: Interval(0, 0.4))).animate(widget.animation);
    fadeOut = Tween<double>(
      begin: 1,
      end: 0,
    ).chain(CurveTween(curve: Interval(0.4, 0.5))).animate(widget.animation);
    slideUp = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(widget.animation);
    fadeIn = Tween<double>(begin: 0, end: 1).animate(widget.animation);
  }

  Widget _buildOperationButtons() {
    final provider = context.read<FileProvider>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        if (provider.isRecycleBinPage)
          PButtonContainer(
            child: ElevatedButton(
              onPressed: () async {
                if (provider.selectedModels.isEmpty) {
                  return;
                }
                final appLoc = loc(context);

                // 提示用户是否删除
                final res = await showAlertDialog(
                  context: context,
                  title: Text(appLoc.recoveryConfirm),
                  content: Text(appLoc.recoveryContent),
                );
                if (res == true) {
                  try {
                    provider.recoverModels();
                    showToastBottom(
                      appLoc.successfully(appLoc.recovery, appLoc.databases),
                    );
                  } on BusinessException catch (err) {
                    // TODO: 异常信息处理
                    showToastBottom(err.message);
                  } catch (err) {
                    logger.e(err);
                  }
                }
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              child: Text(loc(context).recovery),
            ),
          ),
        PButtonContainer(
          child: ElevatedButton(
            onPressed: () async {
              if (provider.selectedModels.isEmpty) {
                return;
              }
              final appLoc = loc(context);
              // 提示用户是否删除
              final res = await showAlertDialog(
                context: context,
                title: Text(
                  provider.isRecycleBinPage
                      ? appLoc.deleteFromRecycleBinConfirm
                      : appLoc.deleteConfirm,
                ),
                content: Text(
                  provider.isRecycleBinPage
                      ? appLoc.deleteFromRecycleBinContent
                      : appLoc.deleteContent,
                ),
              );
              if (res == true) {
                try {
                  await provider.removeSelectedFile();

                  showToastBottom(appLoc.successfully(appLoc.delete, ''));
                } catch (e, stackTrace) {
                  if (mounted) {
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
              }
            },
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.secondaryContainer,
              ),
              foregroundColor: WidgetStatePropertyAll(
                Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            child: Text(loc(context).delete),
          ),
        ),
      ],
    );
  }

  Widget _buildNormal(BuildContext context) {
    /// TODO: direction: horizontal在真机上,跳转至其他页面, 按钮高度会被拉伸至全屏
    return Flex(
      direction: widget.alignment,
      spacing: widget.alignment == Axis.horizontal ? 12 : 6,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        PButtonContainer(
          child: FilledButton(
            onPressed: () async {
              await context.pushNamed(CreateDatabasePage.routeName);
            },
            child: Text(loc(context).createNew),
          ),
        ),
        PButtonContainer(
          child: FilledButton.tonal(
            onPressed: () async {
              final pushNamed = context.pushNamed;
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                pushNamed(
                  UnlockDatabasePage.routeName,
                  extra: FileModel(result.files.single.path!),
                );
              } else {
                logger.d("User did not select the file.");
              }
            },
            child: Text(loc(context).openExists),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // body区域改变,这里的高度会变换, 这里固定一下
      // vertical: 102
      // horizontal: 48
      // height: widget.alignment == Axis.horizontal ? 56 : 110,
      height: 110,
      margin: EdgeInsets.symmetric(
        // horizontal: widget.alignment == Axis.horizontal ? 64 : 32,
        horizontal: 32,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Normal button
          SlideTransition(
            position: slideDown,
            child: FadeTransition(
              opacity: fadeOut,
              child: IgnorePointer(
                ignoring: widget.animation.isForwardOrCompleted,
                child: _buildNormal(context),
              ),
            ),
          ),
          // Delete button
          SlideTransition(
            position: slideUp,
            child: IgnorePointer(
              ignoring: !widget.animation.isForwardOrCompleted,
              child: FadeTransition(
                opacity: fadeIn,
                child: _buildOperationButtons(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
