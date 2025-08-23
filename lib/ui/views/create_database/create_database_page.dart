import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/common/constants/path_key.dart';
import 'package:peak_pass/data/services/biometric_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/views/create_database/create_database_controller.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/ui/widgets/p_button_container.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/validate_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';

class CreateDatabasePage extends StatelessWidget {
  const CreateDatabasePage({super.key});

  static const String routeName = 'create-database';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => CreateDatabaseController(
            kdbxService: Provider.of<KdbxService>(context, listen: false),
            biometricService: Provider.of<BiometricService>(
              context,
              listen: false,
            ),
          ),
      child: _CreateDatabaseScreen(),
    );
  }
}

class _CreateDatabaseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CreateDatabaseController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc(context).createDatabase,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.help_outline_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 数据库名称
                PTextFormField(
                  controller: controller.nameController,
                  label: Text(
                    loc(context).databaseName,
                    style: TextStyle(fontSize: 16),
                  ),
                  hintText: loc(context).enterDatabaseName,
                  suffixIcons: [Text(PathKey.databaseExtension)],
                  validator: (p0) {
                    return ValidateUtils.notEmpty(
                      p0,
                      loc(context).cannotBeEmpty,
                    );
                  },
                ),
                Gap.vertical(6),
                Column(
                  children: [
                    // 密码
                    PTextFormField(
                      readonly: !controller.usePassword,
                      label: Text(
                        loc(context).masterPassword,
                        style: TextStyle(fontSize: 16),
                      ),
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
                      controller: controller.passwordController,
                      hintText: loc(context).enterPassword,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (val) {
                        return controller.usePassword
                            ? ValidateUtils.notEmpty(
                              val,
                              loc(context).cannotBeEmpty,
                            )
                            : null;
                      },
                    ),
                    Gap.vertical(6),
                    PTextFormField(
                      readonly: !controller.usePassword,
                      controller: controller.pwdConfirmController,
                      hintText: loc(context).confirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (p0) {
                        if (!controller.usePassword) {
                          return null;
                        }
                        final notEmpty = ValidateUtils.notEmpty(
                          p0,
                          loc(context).cannotBeEmpty,
                        );
                        if (notEmpty != null) {
                          return notEmpty;
                        }
                        if (controller.passwordController.text.trim() != p0) {
                          return loc(context).passwordInconsistentTwice;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                // Gap.vertical(16),
                Column(
                  children: [
                    // keyfile
                    PTextFormField(
                      label: Text(
                        loc(context).keyfile,
                        style: TextStyle(fontSize: 16),
                      ),
                      readonly: true,
                      controller: controller.keyfileController,
                      hintText: loc(context).clickToSelectOrGen,
                      suffixIcons: [Text(PathKey.keyfileExtension)],
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
                      validator: (p0) {
                        return controller.useKeyfile
                            ? ValidateUtils.notEmpty(
                              p0,
                              loc(context).cannotBeEmpty,
                            )
                            : null;
                      },
                      onTap: () async {
                        await controller.chooseKeyfile(context);
                      },
                    ),
                  ],
                ),

                const Gap.vertical(6),
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      PButtonContainer(
                        child: FilledButton(
                          onPressed: () async {
                            await controller.createDatabase(context);
                          },

                          child: Text(loc(context).create),
                        ),
                      ),
                      PButtonContainer(
                        child: FilledButton.tonal(
                          onPressed: () => context.pop(),
                          child: Text(loc(context).cancel),
                        ),
                      ),
                    ],
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
