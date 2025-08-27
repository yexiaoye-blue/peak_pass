import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';

class KdbxUIProvider extends ChangeNotifier {
  final KdbxService kdbxService;
  KdbxUIProvider(this.kdbxService);

  void resetUIModel() {
    _entriesUI = _entries;
    _groupsUI = _groups;

    // 将rootGroup放在第一位
    _groupsUI.removeWhere((group) => group == rootGroup);
    _groupsUI.insert(0, rootGroup);
  }

  bool get initialized => kdbxService.initialized;

  KdbxGroup get rootGroup => kdbxService.rootGroup;
  // 当前数据库所有条目列表
  List<KdbxEntry> get _entries => kdbxService.allEntries;
  List<KdbxGroup> get _groups => kdbxService.allGroups;

  Set<KdbxObject> get dirtyObjects => kdbxService.kdbxFile.dirtyObjects;

  Stream<Set<KdbxObject>> get dirtyObjectsChanged =>
      kdbxService.kdbxFile.dirtyObjectsChanged;

  late List<KdbxEntry> _entriesUI;
  List<KdbxEntry> get entriesUI => _entriesUI;
  set entriesUI(List<KdbxEntry> entriesUI) {
    _entriesUI = entriesUI;
    notifyListeners();
  }

  late List<KdbxGroup> _groupsUI;
  List<KdbxGroup> get groupsUI => _groupsUI;
  set groupsUI(List<KdbxGroup> entriesUI) {
    _groupsUI = entriesUI;
    notifyListeners();
  }

  
  /// 对group name 做处理: 将rootGroup的名字渲染为All
  /// TODO loc
  // String getGroupName(KdbxGroup group) {
  //   if (group.uuid == rootGroup.uuid) {
  //     return 'All';
  //   }
  //   return group.name.get() ?? "Unknown";
  // }

  // 根据选定的分组过滤条目，并可选择对分组排序，将选中的分组移到前面
  void filterEntryByGroups(
    List<KdbxGroup> selectedGroups, [
    bool sortGroup = true,
  ]) {
    if (selectedGroups.isNotEmpty) {
      _entriesUI = selectedGroups.expand((group) => group.entries).toList();
      if (sortGroup) {
        _groupsUI.sort((a, b) {
          final aSelected = selectedGroups.contains(a);
          final bSelected = selectedGroups.contains(b);
          if (aSelected && !bSelected) return -1;
          if (!aSelected && bSelected) return 1;
          return 0;
        });
      }
    } else {
      resetUIModel();
    }
    notifyListeners();
  }

  List<KdbxEntry> filterEntryBySelected(List<KdbxEntry>? selectedEntries) {
    if (selectedEntries == null || selectedEntries.isEmpty) {
      return _entriesUI;
    }
    return _entriesUI
        .where((entry) => !selectedEntries.contains(entry))
        .toList();
  }

  void removeUnsaved() {
    kdbxService.cleanTempWorkspace();
    notifyListeners();
  }

  // 将当前数据库保存到内存中
  Future<void> saveToMemory() => kdbxService.cache();

  // 将当前数据库保存到持久存储
  Future<void> save() => kdbxService.save();
}
