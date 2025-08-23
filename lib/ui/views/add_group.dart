import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/common/constants/preset_groups.dart';
import 'package:peak_pass/common/global.dart';
import 'package:peak_pass/data/models/group_template_model.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/ui/views/choose_icon.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});
  static const String routeName = 'add-group';

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  /// 默认显示 edit
  IconModel _currentIconModel = IconModel(
    type: IconModelType.kdbxPreset,
    kdbxIndex: 0,
  );

  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _save(BuildContext context, GroupUIModel groupModel) async {
    final pop = context.pop<bool?>;

    final provider = context.read<CurrentEntryController>();
    final res = await showSimpleAlertDialog(
      context: context,
      title: 'Alert',
      content: 'Are you sure add the group: ${groupModel.name}',
    );

    if (res == true) {
      try {
        provider.createGroupAndAdd(groupModel.name, groupModel.iconModel);
        pop.call(true);
      } catch (err) {
        logger.d(err);
        showToastBottom(err.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Group',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  final resIconModel = await context.pushNamed<IconModel>(
                    ChooseIconPage.routeName,
                  );

                  if (resIconModel != null) {
                    setState(() {
                      _currentIconModel = resIconModel;
                    });
                  }
                },

                child: getAvatarWithProperty(
                  context: context,
                  iconModel: _currentIconModel,
                  dimension: 62,
                  iconColor:
                      isDark ? Theme.of(context).colorScheme.primary : null,
                  backgroundColor:
                      isDark
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              const Gap.vertical(16),
              Form(
                key: _formKey,
                child: PTextFormField(
                  controller: _controller,
                  label: const Text(
                    'Group name',
                    style: TextStyle(fontSize: 16),
                  ),
                  prefixIcon: Icon(Icons.title),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter name.';
                    }
                    return null;
                  },
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Group templates',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Gap.vertical(8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: PresetGroups.groupTemplates.length,
                itemBuilder:
                    (context, index) => ListTile(
                      onTap:
                          () => _save(
                            context,
                            PresetGroups.groupTemplates[index],
                          ),
                      tileColor: Theme.of(context).colorScheme.surfaceContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(8),
                      ),
                      leading: Icon(
                        PresetGroups.groupTemplates[index].iconModel.iconData,
                      ),
                      title: Text(PresetGroups.groupTemplates[index].name),
                    ),
                separatorBuilder: (context, index) => const SizedBox(height: 4),
              ),

              Gap.vertical(80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _save(
              context,
              GroupUIModel(
                name: _controller.text,
                iconModel: _currentIconModel,
              ),
            );
          }
        },
        child: Icon(Icons.save),
      ),
    );
  }
}
