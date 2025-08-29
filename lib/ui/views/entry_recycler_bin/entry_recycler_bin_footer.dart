import 'package:flutter/material.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/services/error_handle_service.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_controller.dart';
import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';


class EntryRecyclerBinFooter extends StatefulWidget {
  const EntryRecyclerBinFooter({super.key});

  @override
  State<EntryRecyclerBinFooter> createState() => _EntryRecyclerBinFooterState();
}

class _EntryRecyclerBinFooterState extends State<EntryRecyclerBinFooter> {
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

    final provider = context.read<EntryRecyclerBinController>();

    slideDown = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, 1),
    ).chain(CurveTween(curve: Interval(0, 0.4))).animate(provider.animation);
    fadeOut = Tween<double>(
      begin: 1,
      end: 0,
    ).chain(CurveTween(curve: Interval(0.4, 0.5))).animate(provider.animation);
    slideUp = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(provider.animation);
    fadeIn = Tween<double>(begin: 0, end: 1).animate(provider.animation);
  }

  Widget _buildOperationButtons() {
    final provider = context.read<EntryRecyclerBinController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        PButtonContainer(
          child: FilledButton(
            onPressed: () async {
              if (provider.selectedEntries.isEmpty) return;

              final appLoc = loc(context);
              // 提示用户是否恢复
              final res = await showAlertDialog(
                context: context,
                title: Text(appLoc.recoveryConfirm),
                content: Text(appLoc.recoveryContent),
              );

              if (res != true) return;

              try {
                provider.recoverySelectedEntries();

                showToastBottom(appLoc.successfully(appLoc.recovery, ''));
              } catch (e, stackTrace) {
                if (mounted) {
                  if (e is BusinessException) {
                    ErrorHandlerService.handleBusinessException(appLoc, e);
                  } else {
                    ErrorHandlerService.handleException(context, e, stackTrace);
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
              if (provider.selectedEntries.isEmpty) return;

              final appLoc = loc(context);
              // 提示用户是否删除
              final res = await showAlertDialog(
                context: context,
                title: Text(appLoc.deleteFromRecycleBinConfirm),
                content: Text(appLoc.deleteFromRecycleBinContent),
              );

              if (res != true) return;

              try {
                provider.deleteSelectedEntries();
                showToastBottom(appLoc.successfully(appLoc.delete, ''));
              } catch (e, stackTrace) {
                if (mounted) {
                  if (e is BusinessException) {
                    ErrorHandlerService.handleBusinessException(appLoc, e);
                  } else {
                    ErrorHandlerService.handleException(context, e, stackTrace);
                  }
                }
              }
            },
            child: Text(loc(context).delete),
          ),
        ),
      ],
    );
  }

  Widget _buildNormal() {
    return FloatingActionButton(
      onPressed: () {
        context.read<EntryRecyclerBinController>().toEditing();
      },
      child: Icon(Icons.edit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntryRecyclerBinController>();
    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(),
          // Normal button
          Positioned(
            right: 24,
            top: -8,
            child: SlideTransition(
              position: slideDown,
              child: FadeTransition(
                opacity: fadeOut,
                child: IgnorePointer(
                  ignoring: !provider.isNormal,
                  child: _buildNormal(),
                ),
              ),
            ),
          ),
          // Operation button
          SlideTransition(
            position: slideUp,
            child: IgnorePointer(
              ignoring: provider.isNormal,
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
