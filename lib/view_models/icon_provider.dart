import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/data/services/app_path_manager.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/utils/path_utils.dart';
import '../common/constants/preset_icons.dart';

/// 用户自定义图标 + 系统预设图标
/// 删除该类 ,直接使用 customIcon, 然后看一下怎么将  Icons 转byes 互转 ??

// 1. 首先加载 用户已经存储过的 自定义图片
// 2. 后续考虑 添加软件预设图标
// 3. 加载 kdbx库中预设的图标

class IconProvider extends ChangeNotifier {
  IconProvider(this.appPathManager);

  late final AppPathManager appPathManager;

  /// 用户自定义图标数量,用于修正index位置
  int useCustomIconCount = 0;

  List<IconModel> _icons = [];
  List<IconModel> get icons => _icons;
  set icons(List<IconModel> icons) {
    _icons = icons;
    notifyListeners();
  }

  IconModel get defaultIcon => _icons[0];

  /// 刷新icon
  Future<void> refreshIcons() async => icons = await initialIcons();

  /// 获取用户自定义图标路径下的所有文件
  Future<List<IconModel>> initialIcons() async {
    final iconDir = await appPathManager.userAssetsIconDir;
    final List<IconModel> userCustomIcons = [];
    await for (final item in iconDir.list()) {
      userCustomIcons.add(
        IconModel(path: item.path, type: IconModelType.userCustom),
      );
    }
    _icons.clear();
    _icons.addAll(userCustomIcons);
    useCustomIconCount = userCustomIcons.length;

    // 添加 软件预设
    _addSoftwareIcons();

    // 添加 kdbx 预设
    for (int i = 0; i < PresetIcons.values.length; i++) {
      _icons.add(IconModel(type: IconModelType.kdbxPreset, kdbxIndex: i));
    }

    return _icons;
  }

  List<IconModel> _addSoftwareIcons() {
    return [
      IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.abc),
      ),
      IconModel(
        type: IconModelType.softwarePreset,
        bytes: CustomIconUtils.encodePresetIcon(Icons.delete),
      ),
    ];
  }

  /// 新增用户自定义图标 [ImagePicker]
  Future<bool> addCustomIcon(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final originPath = PathUtils.renameByTimestamp(file.path);
      final targetDir = await appPathManager.userAssetsIconDir;

      final resFile = await File(
        p.join(targetDir.path, p.basename(originPath)),
      ).writeAsBytes(bytes);
      icons.insert(
        0,
        IconModel(
          type: IconModelType.userCustom,
          path: resFile.path,
          bytes: bytes,
        ),
      );

      useCustomIconCount++;
      notifyListeners();
      return true;
    } catch (err) {
      logger.e(err);
    }
    return false;
  }

  // TODO
  void modify() {}
}
