import 'package:flutter/material.dart';
import 'package:peak_pass/common/constants/preset_icons.dart';
import 'package:peak_pass/data/models/group_template_model.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';

class PresetGroups {
  const PresetGroups._();

  static const String tempWorkspaceName = 'TempWorkspace';

  /// 预设group 模板
  /// See [PresetIcons].icons additional.
  static final List<GroupUIModel> groupTemplates = [
    GroupUIModel(
      name: 'Personal',
      iconModel: IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.person),
      ),
    ),
    GroupUIModel(
      name: 'Work',
      iconModel: IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.work),
      ),
    ),
    GroupUIModel(
      name: 'Finance',
      iconModel: IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.attach_money),
      ),
    ),
    GroupUIModel(
      name: 'Shopping',
      iconModel: IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.shopping_cart),
      ),
    ),
    GroupUIModel(
      name: 'Social',
      iconModel: IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.share),
      ),
    ),
    GroupUIModel(
      name: 'Other',
      iconModel: IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.more_horiz_outlined),
      ),
    ),
  ];
}
