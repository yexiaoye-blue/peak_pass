import 'package:flutter/material.dart';

import 'p_button.dart';

class ConfirmBottomSheet extends StatefulWidget {
  final String title;
  final String? message;
  final Widget? content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final Future<dynamic> Function()? onConfirm;

  const ConfirmBottomSheet({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    Widget? content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    Future<T> Function()? onConfirm,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder:
          (_) => ConfirmBottomSheet(
            title: title,
            message: message,
            content: content,
            confirmText: confirmText,
            cancelText: cancelText,
            isDestructive: isDestructive,
            onConfirm: onConfirm,
          ),
    );
  }

  @override
  State<ConfirmBottomSheet> createState() => _ConfirmBottomSheetState();
}

class _ConfirmBottomSheetState extends State<ConfirmBottomSheet> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    if (widget.onConfirm != null) {
      setState(() => _isLoading = true);
      try {
        final result = await widget.onConfirm!();
        await Future.delayed(Duration(seconds: 5));
        if (mounted) Navigator.of(context).pop(result);
      } catch (e) {
        debugPrint('ConfirmBottomSheet error: $e');
        setState(() => _isLoading = false);
      }
    } else {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 8),
            Text(widget.message!),
          ],
          if (widget.content != null) ...[
            const SizedBox(height: 16),
            widget.content!,
          ],
          const SizedBox(height: 16),

          Row(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PButton(
                  isTonal: true,
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(widget.cancelText),
                ),
              ),
              Expanded(
                child: PButton(
                  onPressed: () async {
                    _isLoading ? null : await _handleConfirm();
                  },
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : Text(widget.confirmText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
