import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/data/models/otp_model.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/ui/views/enter_code_manually/totp_tab_view.dart';
import 'package:peak_pass/ui/views/entry_manage/entry_manage_page.dart';
import 'package:peak_pass/ui/views/scanner_page.dart';
import 'package:peak_pass/utils/validate_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/view_models/hotp_provider.dart';
import 'package:peak_pass/view_models/totp_provider.dart';
import 'package:provider/provider.dart';

import 'hotp_tab_view.dart';

class EnterCodeManuallyPage extends StatefulWidget {
  const EnterCodeManuallyPage({super.key});

  static const String routeName = 'enter-code-manually';

  @override
  State<EnterCodeManuallyPage> createState() => _EnterCodeManuallyPageState();
}

class _EnterCodeManuallyPageState extends State<EnterCodeManuallyPage>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final TextEditingController otpUriController = TextEditingController();

  TotpProvider totpProvider = TotpProvider();
  HotpProvider hotpProvider = HotpProvider();

  bool get isTotpTab => tabController.index == 0;

  bool isFromScannerPage = true;

  // 缓存用户从EntryManagePage页面过来传入数据,用于当用户点击返回而非修改时的回传
  String? strUriCache;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;

    if (strUriCache != null) return;
    if (extra != null && extra is String) {
      // 从EntryManagePage页面进入
      isFromScannerPage = false;
      setup(extra, true);
    } else {
      // 从MobileScannerPage页面进入
      isFromScannerPage = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    tabController.dispose();
    otpUriController.dispose();
  }

  void setup(String strUri, [bool cacheUri = false]) {
    final otpModel = OtpModel.fromUriStr(strUri);

    if (cacheUri) {
      strUriCache = strUri;
    }

    if (otpModel.type == OtpType.totp) {
      tabController.index = 0;
      totpProvider.model = otpModel;
    } else {
      tabController.index = 1;
      hotpProvider.model = otpModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            if (isFromScannerPage) {
              context.goNamed(MobileScannerPage.routeName);
              return;
            }
            context.goNamed(
              EntryManagePage.routeName,
              extra: {'otpUri': strUriCache},
            );
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          loc(context).enterManually,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Tooltip(
            message: loc(context).enterOTPUri,
            child: IconButton(
              onPressed: () async {
                final res = await showMutiLineInputDialog(
                  context: context,
                  title: Text(loc(context).enterOTPUri),
                  label: Text(loc(context).uri),
                  controller: otpUriController,
                  validator: ValidateUtils.otp,
                );
                if (res == true) {
                  setup(otpUriController.text);
                }
              },
              icon: Icon(Icons.code_rounded),
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.help_outline_rounded)),
        ],
      ),
      body: Column(
        children: [
          // Tab container
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: TabBar(
                controller: tabController,
                tabAlignment: TabAlignment.center,
                dividerColor: Colors.transparent,
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(17),
                  color: Theme.of(context).colorScheme.primary,
                ),
                labelColor: Theme.of(context).colorScheme.onPrimary,
                tabs: [
                  Tab(text: 'TOTP', height: 32),
                  Tab(height: 32, text: 'HOTP'),
                ],
                onTap: (index) async {},
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                ChangeNotifierProvider<TotpProvider>.value(
                  value: totpProvider,
                  child: TotpTabView(),
                ),
                ChangeNotifierProvider<HotpProvider>.value(
                  value: hotpProvider,
                  child: HotpTabView(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final provider = context.read<CurrentEntryController>();
          if (isTotpTab) {
            if (totpProvider.formKey.currentState!.validate()) {
              provider.updateField(
                KdbxKeyCommon.OTP,

                Uri.encodeComponent(totpProvider.uri.toString()),
              );

              provider.goEntryMangePage(context: context, shouldReset: false);
            }
          } else {
            if (hotpProvider.formKey.currentState!.validate()) {
              // save to entry

              provider.updateField(
                KdbxKeyCommon.OTP,
                Uri.encodeComponent(hotpProvider.uri.toString()),
              );
              provider.goEntryMangePage(context: context, shouldReset: false);
            }
          }
        },
        child: Icon(Icons.done),
      ),
    );
  }
}
