import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kdbx/kdbx.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:peak_pass/main.dart';
import 'package:peak_pass/ui/views/enter_code_manually/enter_code_manually_page.dart';
import 'package:peak_pass/ui/views/entry_manage/entry_manage_page.dart';
import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/utils/otp_utils.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:provider/provider.dart';

class MobileScannerPage extends StatefulWidget {
  const MobileScannerPage({super.key});
  static const String routeName = 'scanner-page';

  @override
  State<MobileScannerPage> createState() => _MobileScannerPageState();
}

class _MobileScannerPageState extends State<MobileScannerPage>
    with WidgetsBindingObserver, RouteAware {
  MobileScannerController? controller;
  Barcode? _barcode;
  bool flashStatus = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 添加观察者
    logger.d('init stat');

    controller = MobileScannerController(autoStart: false, autoZoom: true);
    unawaited(controller!.start());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPushNext() {
    super.didPushNext();
    unawaited(controller!.stop());
  }

  @override
  void didPopNext() {
    super.didPopNext();

    unawaited(controller!.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If the controller is not ready, do not try to start or stop it.
    // Permission dialogs can trigger lifecycle changes before the controller is ready.
    if (controller?.value.hasCameraPermission ?? false == false) {
      return;
    }
    logger.d(state);

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        unawaited(controller?.start());
      case AppLifecycleState.inactive:
        unawaited(controller?.stop());
    }
  }

  @override
  Future<void> dispose() async {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this); // 移除观察者
    await controller?.dispose();
    controller = null;
    super.dispose();
  }

  void _popWithBarcode(Barcode? barcode) async {
    if (barcode != null) {
      try {
        final provider = context.read<CurrentEntryController>();
        // 这里扫码成功直接在这里添加

        String codeValue = barcode.displayValue ?? '';
        // 1. 校验是否为 otp auth
        final isOtpAuth = OtpUtils.isOtpAuthUri(codeValue);
        if (!isOtpAuth) {
          showToastBottom('Not a legal otp auth.');
          return;
        }

        // 2. 校验是否已经 encode
        final isEncoded = OtpUtils.isUrlEncoded(codeValue);
        if (!isEncoded) {
          codeValue = Uri.encodeComponent(codeValue);
        }

        // 3. 更新 uri值
        provider.addField(KdbxKeyCommon.OTP, codeValue);

        provider.goEntryMangePage(context: context, shouldReset: false);
      } catch (err) {
        logger.e(err);
      }
    }
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted) {
      _barcode = barcodes.barcodes.firstOrNull;
      _popWithBarcode(_barcode);
    }
  }

  Future<void> _toggleTorch() async => controller?.toggleTorch();

  void _enterManually() =>
      context.pushNamed<String>(EnterCodeManuallyPage.routeName);

  Future<void> _analyzeImage() async {
    if (kIsWeb) {
      showToastBottom('Analyze image is not supported on web');
      return;
    }

    // loading
    final loaderOverlay = context.loaderOverlay;
    final appLoc = loc(context);
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    loaderOverlay.show();
    try {
      final BarcodeCapture? barcodes = await controller?.analyzeImage(
        image.path,
      );

      if (!context.mounted) return;

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        // TODO: 后续按需添加 当图片中存在多个barcode,由用户来选择
        // 默认使用第一个
        if (barcodes.barcodes.length > 1) {
          showToastBottom(appLoc.barcodeFindMultiple);
        } else {
          showToastBottom(appLoc.successfully(appLoc.scan, ''));
        }
        _barcode = barcodes.barcodes[0];
      } else {
        showToastBottom(appLoc.successfully(appLoc.scan, ''));
      }
    } catch (err) {
      logger.e(err);
      showToastBottom(appLoc.failed(appLoc.scan, ''));
    } finally {
      loaderOverlay.hide();
    }
    _popWithBarcode(_barcode);
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.goNamed(EntryManagePage.routeName),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text(
            loc(context).otpScanner,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            ValueListenableBuilder(
              valueListenable: controller!,
              builder: (context, state, child) {
                if (!state.isInitialized || !state.isRunning) {
                  return const SizedBox.shrink();
                }

                switch (state.torchState) {
                  case TorchState.auto:
                    return IconButton(
                      icon: const Icon(Icons.flash_auto_rounded),
                      onPressed: _toggleTorch,
                    );
                  case TorchState.off:
                    return IconButton(
                      icon: const Icon(Icons.flash_off_rounded),
                      onPressed: _toggleTorch,
                    );
                  case TorchState.on:
                    return IconButton(
                      icon: const Icon(Icons.flash_on_rounded),
                      onPressed: _toggleTorch,
                    );
                  case TorchState.unavailable:
                    return const SizedBox.square(
                      dimension: 40,
                      child: Icon(Icons.no_flash, size: 32, color: Colors.grey),
                    );
                }
              },
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.help_outline_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          child: Column(
            children: [
              controller == null
                  ? const SizedBox.shrink()
                  : SizedBox(
                    height: 360,
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 240,
                            height: 240,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            // TODO: 缩放
                            child: MobileScanner(
                              controller: controller,
                              onDetect: _handleBarcode,
                            ),
                          ),
                          // ScanWindowOverlay(controller: controller!, scanWindow: scanWindow),
                        ],
                      ),
                    ),
                  ),
              Spacer(),
              PButtonContainer(
                child: FilledButton(
                  onPressed: _enterManually,
                  child: Text(loc(context).enterManually),
                ),
              ),
              PButtonContainer(
                child: FilledButton.tonal(
                  onPressed: _analyzeImage,
                  child: Text(loc(context).album),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
