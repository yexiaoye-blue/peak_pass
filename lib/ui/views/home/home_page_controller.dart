import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/helper/dialogs.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';

class HomePageController extends ChangeNotifier {
  final TickerProvider tickerProvider;
  final KdbxService kdbxService;
  KdbxUIProvider uiProvider;

  HomePageController({
    required this.tickerProvider,
    required this.uiProvider,
    required this.kdbxService,
  }) {
    categoryAnimationCtl = AnimationController(
      vsync: tickerProvider,
      duration: duration,
    );

    editingAnimationCtl = AnimationController(
      vsync: tickerProvider,
      duration: duration,
    );
    editingAnimation = CurvedAnimation(
      parent: editingAnimationCtl,
      curve: Curves.linear,
    )..addStatusListener((status) {
      notifyListeners();
    });
  }
  void update(KdbxUIProvider kdbxUIProvider) => uiProvider = kdbxUIProvider;

  static const Duration duration = Durations.short4;

  late final AnimationController categoryAnimationCtl;
  // late final Animation<double> categoryAnimation;

  late final AnimationController editingAnimationCtl;
  late final Animation<double> editingAnimation;

  bool get isEditing => editingAnimation.isForwardOrCompleted;
  bool get isNormal => !isEditing;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // 添加状态变量
  SortType _sortType = SortType.asc;
  SortType get sortType => _sortType;

  bool _isGridLayout = false;
  bool get isGridLayout => _isGridLayout;

  final List<KdbxEntry> _selectedEntries = [];
  List<KdbxEntry> get selectedEntries => _selectedEntries;

  List<KdbxGroup> _selectedGroups = [];
  List<KdbxGroup> get selectedGroups => _selectedGroups;

  void openDrawer() {
    scaffoldKey.currentState!.openDrawer();
  }

  void closeDrawer(BuildContext context) {
    Navigator.of(context).pop();
  }

  void toEditing() {
    editingAnimationCtl.forward();
  }

  void toNormal() {
    clearEntrySelection();
    editingAnimationCtl.reverse();
  }

  void toggleLayout() {
    _isGridLayout = !_isGridLayout;
    // 清空选中的group, 以保证grid layout中的group顺序是默认的
    uiProvider.filterEntryByGroups([]);

    if (_isGridLayout) {
      categoryAnimationCtl.forward();
    } else {
      categoryAnimationCtl.reverse();
    }
    notifyListeners();
  }

  bool isEntrySelected(KdbxEntry entry) => _selectedEntries.contains(entry);

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
      _selectedEntries.addAll(uiProvider.entriesUI);
    } else if (_selectedEntries.length != uiProvider.entriesUI.length) {
      // 3. 如果选中条目与原始数据长度不一致,则添加未选中的
      _selectedEntries.addAll(
        uiProvider.entriesUI.where(
          (entry) => !_selectedEntries.contains(entry),
        ),
      );
    } else {
      // 部分选中，则全选
      _selectedEntries.clear();
    }

    notifyListeners();
  }

  void deleteSelectedEntries(BuildContext context) async {
    final confirm = await showSimpleAlertDialog(
      context: context,
      title: 'Alert',
      content: 'Whether to confirm the deletion?',
    );
    if (confirm != true) return;

    try {
      for (final item in _selectedEntries) {
        kdbxService.removeEntry(item);
      }
      _selectedEntries.clear();
      uiProvider.resetUIModel();
      await kdbxService.save();

      showToastBottom('Delete successfully.');
      notifyListeners();
    } catch (err) {
      logger.d(err);
    }
  }

  void clearSelectedGroups() {
    _selectedGroups.clear();
    uiProvider.filterEntryByGroups(_selectedGroups);
    notifyListeners();
  }

  void updateSelectedGroups(List<KdbxGroup> groups) {
    _selectedGroups = groups;
    uiProvider.filterEntryByGroups(_selectedGroups);

    if (_isGridLayout) {
      _isGridLayout = false;
      categoryAnimationCtl.reverse();
    }
    notifyListeners();
  }

  void updateSortType(SortType sortType) {
    _sortType = sortType;
    notifyListeners();
  }

  void test() {
    notifyListeners();
  }
}
