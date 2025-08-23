import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peak_pass/common/constants/kdbx_key_common_ext.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/data/models/otp_model.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/models/field_controller_model.dart';
import 'package:peak_pass/ui/views/add_group.dart';
import 'package:peak_pass/ui/views/choose_icon.dart';
import 'package:peak_pass/ui/views/entry_manage/add_field_dialog.dart';
import 'package:peak_pass/ui/views/entry_manage/entry_manage_page.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';
import 'package:peak_pass/common/constants/preset_fields.dart';
import 'package:peak_pass/common/enums/enums.dart' show EntryPageType;
import 'package:peak_pass/utils/otp_utils.dart';

/// EntryManagePage页面对应的 controller
///
/// 这个在最外层提供是由于需要跨多个页面跳转后保留数据
/// 具体做法是通过该函数进行跳转goEntryMangePage
class CurrentEntryController extends ChangeNotifier {
  CurrentEntryController({required this.kdbxService}) {
    formKey = GlobalKey<FormState>();
  }

  final KdbxService kdbxService;

  late final GlobalKey<FormState> formKey;

  /// 当前操作的entry
  late KdbxEntry entry;

  /// 当前entry所对应IconModel
  late IconModel iconModel;

  /// 当前entry要添加到的group, 默认为rootGroup
  late KdbxGroup targetGroup;

  /// EntryManagePage的对应的类型: newEntry/details
  EntryPageType pageType = EntryPageType.newEntry;

  /// 页面相关的controller
  final Map<KdbxKey, FieldControllerModel> ctlModels = {};

  /// entry对应的Fields条目
  List<MapEntry<KdbxKey, StringValue?>> get strEntries =>
      entry.stringEntries.toList();

  /// TODO: 考虑某些字段是否可以重复添加, 不使用内置的key
  /// 未添加的字段
  /// 过滤掉已添加的字段(根据 key 来取差集)
  List<FieldType> get availableFields => List.of(PresetFields.types)
    ..retainWhere((type) => !strEntries.any((item) => item.key == type.key));

  /// 控制EntryManagePage页面Fields是否只读
  /// - true: 显示  copy button
  /// - false: 显示 more button
  bool _readonly = true;
  bool get readonly => _readonly;
  set readonly(bool value) {
    _readonly = value;
    notifyListeners();
  }

  /// 添加Field时候,当前选中的Field的index
  KdbxKey? _targetFieldKey;
  KdbxKey? get selectedFieldKey => _targetFieldKey;
  set selectedFieldKey(KdbxKey? value) {
    _targetFieldKey = value;
    notifyListeners();
  }

  /// 跳转到 EntryManagePage页面请使用该方法
  /// - [context]: BuildContext
  /// - [shouldReset]: 是否reset必要数据
  /// - [kdbxEntry]: KdbxEntry
  /// - [type]: 到EntryMangePage页面要做的操作类型
  void goEntryMangePage({
    required BuildContext context,
    bool shouldReset = true,
    KdbxEntry? kdbxEntry,
    EntryPageType? type,
  }) {
    final curPageType = type ?? pageType;

    if (curPageType == EntryPageType.newEntry) {
      if (shouldReset) {
        // 1. 创建entry
        final newEntry = kdbxService.createEntry(
          kdbxService.getTempWorkspaceOrCreate(),
        );
        // 2. 直接添加至 tempWorkspace, 如果未保存 则在退出时删除该entry
        kdbxService.addEntryTo(
          kdbxService.getTempWorkspaceOrCreate(),
          newEntry,
        );
        _reset(newEntry, EntryPageType.newEntry);
      }
    } else {
      if (shouldReset && kdbxEntry != null) {
        _reset(kdbxEntry, EntryPageType.details);
      }
    }

    context.goNamed(EntryManagePage.routeName);
  }

  /// 重置本页面必要的数据
  void _reset(KdbxEntry kdbxEntry, EntryPageType type) {
    entry = kdbxEntry;
    pageType = type;

    iconModel = CustomIconUtils.getIconModelByEntry(entry);
    _readonly = pageType == EntryPageType.newEntry ? false : true;

    targetGroup =
        pageType == EntryPageType.newEntry
            ? kdbxService.rootGroup
            : entry.parent ?? kdbxService.rootGroup;
    _resetController();
  }

  /// 根据key类型添加对应controller
  void _addController(KdbxKey key, StringValue? value) {
    if (ctlModels.containsKey(key)) {
      return;
    }

    ctlModels[key] = FieldControllerModel(
      controller: TextEditingController(text: value?.getText() ?? ''),
      focusNode: FocusNode(),
    );
  }

  void _resetController() {
    for (final key in ctlModels.keys) {
      ctlModels[key]?.controller.dispose();
      ctlModels[key]?.focusNode?.dispose();
    }

    // 确保全部移除
    ctlModels.clear();

    for (final mapEntry in entry.stringEntries) {
      _addController(mapEntry.key, mapEntry.value);
    }
  }

  void _removeController(KdbxKey key) {
    if (!ctlModels.containsKey(key)) {
      return;
    }

    ctlModels[key]?.controller.dispose();
    ctlModels[key]?.focusNode?.dispose();
    ctlModels.remove(key);
  }

  /// 根据key更新当前entry下的Field
  void updateField(KdbxKey key, String value) {
    kdbxService.updateEntry(entry, key, value);
  }

  Future<void> incrementHotpCounter(BuildContext context) async {
    final String? value = entry.getString(KdbxKeyCommon.OTP)?.getText();
    if (value != null && value.isNotEmpty) {
      final res = OtpUtils.parseUri(value);
      if (res == null) return;
      if (res.type != OtpType.hotp) return;

      res.counter = (res.counter! + 1);
      updateField(
        KdbxKeyCommon.OTP,
        Uri.encodeComponent(res.buildUri().toString()),
      );
    }
    await save(context.loaderOverlay, true);
  }

  /// 更新entry的所有Field数据
  Future<void> updateAllFields() async {
    // 1. 更新Fields值
    final models = ctlModels.values.toList();
    final Map<KdbxKey, String> data = collectAllData(models);
    kdbxService.updateEntryValues(entry, data);

    // 2. 更新icon
    kdbxService.setIcon(entry, iconModel);

    // 3. 移动分组
    if (!kdbxService.isInGroupSub(entry, targetGroup)) {
      kdbxService.move(entry, targetGroup);
    }
  }

  /// 收集页面所有字段数据到Map
  Map<KdbxKey, String> collectAllData(List<FieldControllerModel> models) {
    final Map<KdbxKey, String> res = {};

    for (final mapEntry in entry.stringEntries) {
      final key = mapEntry.key;
      final String value = mapEntry.value?.getText() ?? '';

      // 1. 处理 otp auth 的value
      if (key == KdbxKeyCommon.OTP) {
        if (value.isNotEmpty) {
          res[key] = value;
        }
        continue;
      }

      // 2. 在ctlModels没包含该key则不更新
      if (!ctlModels.containsKey(key)) {
        continue;
      }

      // 3. 处理TextField中的数据
      final ctlValue = ctlModels[key]?.controller.text;
      if (ctlValue != null && ctlValue.isNotEmpty && ctlValue != value) {
        res[key] = ctlValue;
      }
    }
    return res;
  }

  Future<void> changeAvatar(BuildContext context) async {
    final targetIcon = await context.pushNamed<IconModel>(
      ChooseIconPage.routeName,
      extra: CustomIconUtils.getIconModelByEntry(entry),
    );

    readonly = false;
    if (targetIcon != null) {
      iconModel = targetIcon;
    }
  }

  Future<void> showAddGroupDialog(BuildContext context) async {
    readonly = false;

    final loaderOverlay = context.loaderOverlay;
    final res = await context.pushNamed<bool?>(AddGroupPage.routeName);

    if (res == true) {
      try {
        // 添加组的操作 直接移到 AddGroupPage中做
        // 这里分组的添加默认保存
        await save(loaderOverlay, true);
        showToastBottom('Create group successfully.');
      } catch (error) {
        logger.e(error);
        showToastBottom(error.toString());
      }
    }
  }

  Future<void> showAddFieldDialog(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final resKey = await showDialog<bool?>(
      context: context,
      builder: (context) => AddFieldDialog(),
    );

    if (resKey == true) {}
  }

  /// 添加表单项
  MapEntry<KdbxKey, StringValue?> addField(KdbxKey key, [String? strValue]) {
    StringValue? value;
    if (key == KdbxKeyCommonExt.otp) {
      if (strValue == null) {
        throw 'Value must be passed in when adding otp auth.';
      }
      value = ProtectedValue.fromString(strValue);
    } else if (key == KdbxKeyCommonExt.password) {
      _addController(key, value);
      value = ProtectedValue.fromString(strValue ?? '');
    } else {
      _addController(key, value);
      value = PlainValue(strValue ?? '');
    }
    entry.setString(key, value);
    notifyListeners();
    return MapEntry(key, value);
  }

  /// 根据 key 移除entry下的条目
  Future<void> removeFieldByKey(KdbxKey key) async {
    entry.removeString(key);
    _removeController(key);
    await kdbxService.cache();
    notifyListeners();
  }

  /// 向上移动目标
  Future<void> moveFieldUp(MapEntry<KdbxKey, StringValue?> strEntry) async {
    kdbxService.moveUp(entry, strEntry);
    await kdbxService.cache();
    notifyListeners();
  }

  /// 向下移动目标entry
  Future<void> moveFieldDown(MapEntry<KdbxKey, StringValue?> strEntry) async {
    kdbxService.moveDown(entry, strEntry);
    await kdbxService.cache();
    notifyListeners();
  }

  /// 创建并添加分组.(kdbx可以创建多级分组,本软件不使用该功能,全部添加到rootGroup下)
  void createGroupAndAdd(String name, IconModel iconModel) {
    final group = kdbxService.createAndAddGroup(kdbxService.rootGroup, name);
    kdbxService.setIcon(group, iconModel);
  }

  // 临时缓存 (清除 dirty 数据)
  Future<void> cache() => kdbxService.cache();

  /// 持久保存
  /// silent, true则不显示toast,并且不校验
  Future<bool> save(
    OverlayExtensionHelper loaderOverlay, [
    bool silent = false,
  ]) async {
    if (!silent) {
      if (!formKey.currentState!.validate()) {
        return false;
      }
    }
    // 编辑状态, FAB显示为 save
    loaderOverlay.show();

    try {
      updateAllFields();
      await kdbxService.save();
      if (!silent) {
        showToastBottom(
          pageType == EntryPageType.newEntry
              ? 'Create entry successfully.'
              : 'Update entry successfully.',
        );
      }

      notifyListeners();
      return true;
    } catch (error) {
      logger.e(error);
      if (!silent) {
        showToastBottom('Failed to create entry.');
      }
    } finally {
      loaderOverlay.hide();
    }
    return false;
  }

  @override
  void dispose() {
    super.dispose();

    /// 释放当前页面数据
    for (final model in ctlModels.values) {
      model.controller.dispose();
      model.focusNode?.dispose();
    }
    ctlModels.clear();
  }
}
