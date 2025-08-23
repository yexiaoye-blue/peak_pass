import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/ui/views/enter_code_manually/enter_code_manually_page.dart';
import 'package:peak_pass/ui/widgets/circular_countdown.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:provider/provider.dart';

import '../../data/models/otp_model.dart';
import '../../utils/common_utils.dart';
import '../../utils/otp_utils.dart';
import '../views/entry_manage/action_menu.dart';

/// 这里存储真实数据 uri
class OtpAuthCardController extends ValueNotifier<String> {
  OtpAuthCardController(super.value);
}

class OtpAuthCard extends StatefulWidget {
  const OtpAuthCard({super.key, required this.field, this.onTap});

  /// HOTP 点击后显示的状态的保存时长
  static const Duration displayDuration = Duration(seconds: 6);

  final MapEntry<KdbxKey, StringValue?> field;

  /// 点击回调
  final VoidCallback? onTap;

  @override
  State<OtpAuthCard> createState() => _OtpAuthCardState();
}

class _OtpAuthCardState extends State<OtpAuthCard>
    with SingleTickerProviderStateMixin {
  late OtpModel otpModel;
  late String code;
  late bool obscureText;

  AnimationController? hotpController;
  Timer? timer;

  String get otpAuthUri => widget.field.value?.getText() ?? '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    timer?.cancel();
    hotpController?.dispose();

    super.dispose();
  }

  void _init() {
    try {
      // 1. 初始化 model
      if (otpAuthUri.isEmpty) {
        throw 'otp auth is null or empty';
      }
      final res = OtpUtils.parseUri(otpAuthUri);
      if (res == null) {
        throw 'otp auth invalid.';
      }

      otpModel = res;

      // 2. 生成code
      code = OtpUtils.generateCode(otpModel);
    } on FormatException catch (err) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToastBottom(err.message);
      });

      otpModel = OtpModel.empty();
      code = 'xxxxxx';
    } catch (err) {
      // 对UI渲染进行保底,确保不会影响其他部分
      otpModel = OtpModel.empty();
      code = 'xxxxxx';
      logger.e(err);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showToastBottom(err.toString());
      });
    }

    // 3. 初始化controller 和 ui样式
    if (otpModel.type == OtpType.hotp) {
      hotpController = AnimationController(
        vsync: this,
        duration: OtpAuthCard.displayDuration,
      );
      obscureText = true;
    } else {
      obscureText = false;
    }
  }

  void toggle() {
    widget.onTap?.call();

    context.read<CurrentEntryController>().incrementHotpCounter(context);

    if (otpModel.type == OtpType.hotp) {
      hotpController!.reset();
      hotpController!.forward();

      setState(() {
        obscureText = false;
      });
      timer?.cancel();
      timer = Timer(OtpAuthCard.displayDuration, () {
        setState(() {
          obscureText = true;
        });
        timer = null;
        Future.delayed(const Duration(milliseconds: 200), () {
          hotpController!.reset();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryProvider = context.read<CurrentEntryController>();
    return Padding(
      // 这个padding 是为了 与PTextFormField为helperText预留的高度保持一致
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.field.key.key,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: toggle,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 0, 12),
              constraints: BoxConstraints(minHeight: 56),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DividerTheme.of(context).color ?? Colors.grey.shade300,
                ),
              ),
              child: Column(
                spacing: 6,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // issuer
                          Text(
                            otpModel.issuer,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // account
                          Text(otpModel.account ?? ''),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child:
                            otpModel.type == OtpType.totp
                                ? CircularCountdown(duration: 30, isLoop: true)
                                : AnimatedCrossFade(
                                  firstChild: CircularCountdown(
                                    controller: hotpController,
                                    autoStart: false,
                                    duration:
                                        OtpAuthCard.displayDuration.inSeconds,
                                    showNumber: false,
                                  ),
                                  secondChild: SizedBox.fromSize(
                                    size: Size.fromRadius(16),
                                  ),
                                  crossFadeState:
                                      obscureText
                                          ? CrossFadeState.showSecond
                                          : CrossFadeState.showFirst,
                                  duration: Durations.short2,
                                ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TextRow(text: code, obscureText: obscureText),
                      if (entryProvider.readonly == true)
                        IconButton(
                          onPressed: () {
                            copyToClipboard(code)
                                .then(
                                  (res) =>
                                      showToastBottom('Copied to clipboard'),
                                )
                                .catchError(
                                  (err) => showToastBottom(
                                    'Failed to copy to clipboard',
                                  ),
                                );
                          },
                          iconSize: 22,
                          icon: Icon(Icons.copy),
                        ),
                      if (entryProvider.readonly == false)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ActionMenu(
                            onModify: () {
                              context.goNamed(
                                EnterCodeManuallyPage.routeName,
                                extra: otpAuthUri,
                              );
                            },
                            onUp: () async {
                              await entryProvider.moveFieldUp(widget.field);
                            },
                            onDown: () async {
                              await entryProvider.moveFieldDown(widget.field);
                            },
                            onRemove: () async {
                              await entryProvider.removeFieldByKey(
                                widget.field.key,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow({required this.text, this.obscureText = false});
  final String text;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    int separate = (text.length / 2).floor() - 1;
    List<Widget> group1 = [];
    List<Widget> group2 = [];
    for (int i = 0; i < text.length; i++) {
      if (i <= separate) {
        group1.add(
          _TextCard(text: text[i], dimension: 32, obscureText: obscureText),
        );
      } else {
        group2.add(
          _TextCard(text: text[i], dimension: 32, obscureText: obscureText),
        );
      }
    }

    return Row(
      spacing: text.length.isOdd ? 4 : 12,
      children: [
        Row(spacing: 4, children: group1),
        Row(spacing: 4, children: group2),
      ],
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({
    required this.text,
    required this.dimension,
    this.obscureText = false,
  });
  final String text;
  final double dimension;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle.merge(
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      child: Container(
        constraints: BoxConstraints.tight(Size.square(dimension)),
        alignment: obscureText ? Alignment(0, 0.4) : Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        child: AnimatedCrossFade(
          firstCurve: Curves.easeOutExpo,
          secondCurve: Curves.decelerate,
          firstChild: Text(
            key: UniqueKey(),
            '*',
            style: TextStyle(fontSize: 24, height: 0.7),
          ),
          secondChild: Text(key: UniqueKey(), text),
          crossFadeState:
              obscureText
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
          duration: Durations.short4,
        ),
      ),
    );
  }
}
