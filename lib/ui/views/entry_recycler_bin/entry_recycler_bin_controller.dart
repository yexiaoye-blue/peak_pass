import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';

class EntryRecyclerBinController extends ChangeNotifier {
  EntryRecyclerBinController({
    required TickerProvider vsync,
    required KdbxUIProvider kdbxUIProvider,
    required this.kdbxService,
  }) {
    _kdbxUIProvider = kdbxUIProvider;
    animationController = AnimationController(vsync: vsync, duration: duration);
    animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.linear,
    );
  }

  static const Duration duration = Durations.short4;

  late final AnimationController animationController;
  late final Animation<double> animation;
  final KdbxService kdbxService;

  late KdbxUIProvider _kdbxUIProvider;
  set kdbxUIProvider(KdbxUIProvider value) => _kdbxUIProvider = value;

  bool get isNormal => !animation.isForwardOrCompleted;

  KdbxGroup get recycleBin => kdbxService.kdbxFile.getRecycleBinOrCreate();

  Stream<ChangeEvent<KdbxNode>> get recycleBinChanges => recycleBin.changes;

  List<KdbxEntry> get entries => recycleBin.entries;

  List<KdbxEntry> _selectedEntries = [];
  List<KdbxEntry> get selectedEntries => _selectedEntries;

  bool isSelected(KdbxEntry entry) => _selectedEntries.contains(entry);

  void clearEntrySelection() {
    _selectedEntries.clear();
    notifyListeners();
  }

  /// TODO: 封装通用工具函数
  void toggleEntrySelection([List<KdbxEntry>? selectedEntries]) {
    if (selectedEntries != null) {
      // 1. 反选
      for (var entry in selectedEntries) {
        if (_selectedEntries.contains(entry)) {
          _selectedEntries.remove(entry);
        } else {
          _selectedEntries.add(entry);
        }
      }
      notifyListeners();
      return;
    }
    if (_selectedEntries.isEmpty) {
      // 2. 如果没有指定条目，则进行全选/取消全选操作
      _selectedEntries.addAll(entries);
    } else if (_selectedEntries.length != entries.length) {
      // 3. 如果选中条目与原始数据长度不一致,则添加未选中的
      _selectedEntries.addAll(
        entries.where((entry) => !_selectedEntries.contains(entry)),
      );
    } else {
      // 部分选中，则全选
      _selectedEntries.clear();
    }

    notifyListeners();
  }

  void toEditing() {
    animationController.forward();
    notifyListeners();
  }

  void toNormal() {
    animationController.reverse();

    notifyListeners();
  }

  void recoveryEntry(KdbxEntry entry) =>
      kdbxService.move(entry, kdbxService.rootGroup);
  void deleteEntry(KdbxEntry entry) => kdbxService.removePermanently(entry);

  void deleteSelectedEntries() async {
    for (var entry in _selectedEntries) {
      deleteEntry(entry);
    }

    clearEntrySelection();
    _kdbxUIProvider.resetUIModel();

    await kdbxService.save();
  }

  void recoverySelectedEntries() async {
    for (var entry in _selectedEntries) {
      recoveryEntry(entry);
    }
    clearEntrySelection();
    _kdbxUIProvider.resetUIModel();
    await kdbxService.save();
  }
}
