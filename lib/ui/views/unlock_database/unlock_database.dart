import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/services/biometric_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/ui/views/unlock_database/unlock_database_controller.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/utils/validate_utils.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:provider/provider.dart';

class UnlockDatabasePage extends StatelessWidget {
  const UnlockDatabasePage({super.key, required this.databaseInfoModel});
  static const String routeName = 'unlock-database';
  final FileModel databaseInfoModel;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<FileProvider, UnlockDatabaseController>(
      create:
          (context) => UnlockDatabaseController(
            dbFileModel: databaseInfoModel,
            fileProvider: context.read<FileProvider>(),
            kdbxService: Provider.of<KdbxService>(context, listen: false),
            biometricService: Provider.of<BiometricService>(
              context,
              listen: false,
            ),
          ),
      update: (context, value, previous) {
        previous?.update(value);
        return previous ??
            UnlockDatabaseController(
              dbFileModel: databaseInfoModel,
              fileProvider: context.read<FileProvider>(),
              kdbxService: Provider.of<KdbxService>(context, listen: false),
              biometricService: Provider.of<BiometricService>(
                context,
                listen: false,
              ),
            );
      },
      child: _UnlockDatabaseScreen(key: ValueKey(databaseInfoModel)),
    );
  }
}

class _UnlockDatabaseScreen extends StatefulWidget {
  const _UnlockDatabaseScreen({super.key});

  @override
  State<_UnlockDatabaseScreen> createState() => __UnlockDatabaseScreenState();
}

class __UnlockDatabaseScreenState extends State<_UnlockDatabaseScreen> {
  @override
  void initState() {
    super.initState();
    final controller = context.read<UnlockDatabaseController>();
    controller.initUnlockMethod();
    // 如果 _useTouchId则尝试获取生物识别
    if (controller.useBiometric) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.unlockByBiometric(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UnlockDatabaseController>();

    return LoaderOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc(context).unlockDatabase),
          actions: [
            IconButton(
              onPressed: () {
                showDbInfoDialog(
                  context: context,
                  model: controller.dbFileModel,
                );
              },
              icon: Icon(Icons.info_outline_rounded),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Text(
                  controller.dbFileModel.basenameWithoutExtension,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Gap.vertical(24),
                PTextFormField(
                  label: Text(
                    loc(context).password,
                    style: TextStyle(fontSize: 16),
                  ),
                  controller: controller.passwordController,
                  labelActions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: SizedBox(
                        height: 32,
                        child: FittedBox(
                          child: Switch(
                            value: controller.usePassword,
                            onChanged: (val) {
                              controller.usePassword = val;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                  readonly: !controller.usePassword,
                  hintText: loc(context).enterPassword,
                  prefixIcon: Icon(Icons.person),
                  validator:
                      (val) => ValidateUtils.notEmpty(
                        val,
                        loc(context).pleaseEnterPassword,
                      ),
                  keyboardType: TextInputType.visiblePassword,
                ),
                PTextFormField(
                  label: Text(
                    loc(context).keyfile,
                    style: TextStyle(fontSize: 16),
                  ),
                  controller: controller.keyfileController,
                  labelActions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: SizedBox(
                        height: 32,
                        child: FittedBox(
                          child: Switch(
                            value: controller.useKeyfile,
                            onChanged: (val) {
                              controller.useKeyfile = val;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                  // initialValue:
                  //     controller.keyfileModel?.basenameWithoutExtension,
                  hintText: loc(context).clickToSelectOrGen,
                  readonly: true,
                  prefixIcon: Icon(Icons.key_rounded),
                  onTap: () => controller.pickKeyfile(context),
                ),

                Gap.vertical(24),

                Row(
                  children: [
                    Spacer(),
                    CheckboxMenuButton(
                      value: controller.useBiometric,
                      onChanged: (val) {
                        if (val != null) {
                          controller.useBiometric = val;
                        }
                      },
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                        ),
                      ),
                      child: Text(loc(context).biometrics),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: PButtonContainer(
                    child: FilledButton(
                      onPressed: () async {
                        await controller.unlock(context);
                      },
                      child: Text(loc(context).unlock),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
