import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import '../utils/common_utils.dart';

/// Search page group 展示所用group
class SearchPageGroupVM {
  final String? name;
  final KdbxGroup? group;
  SearchPageGroupVM({required this.name, this.group});

  @override
  bool operator ==(covariant SearchPageGroupVM other) {
    if (identical(this, other)) return true;
  
    return 
      other.name == name &&
      other.group == group;
  }

  @override
  int get hashCode => name.hashCode ^ group.hashCode;
}

class SearchPageProvider extends ChangeNotifier {
  SearchPageProvider(TickerProvider vsync, this.kdbxUIProvider) {
    groups =
        kdbxUIProvider.groupsUI
            .map(
              (group) =>
                  SearchPageGroupVM(name: group.name.get(), group: group),
            )
            .toList();
    groups.insert(0, groupAll);

    entries = kdbxUIProvider.entriesUI;
    searchController = TextEditingController();
    tabController = TabController(length: groups.length, vsync: vsync);
    tabController.addListener(handleTabChange);
    searchController.addListener(handleTextChange);

    // 默认加载rootGroup(所有)中maxCount条
    _searchResult = entries.take(defaultMaxCount).toList();
  }

  static const int defaultMaxCount = 1000;
  static final SearchPageGroupVM groupAll = SearchPageGroupVM(name: 'All');

  late final KdbxUIProvider kdbxUIProvider;
  late final TextEditingController searchController;
  late final TabController tabController;
  late final List<KdbxEntry> entries;
  late final List<SearchPageGroupVM> groups;

  int _currentGroupIndex = 0;
  int get currentGroupIndex => _currentGroupIndex;
  set currentGroupIndex(int index) {
    _currentGroupIndex = index;
    notifyListeners();
  }

  /// 当前tab所在的分组
  SearchPageGroupVM get currentGroup => groups[_currentGroupIndex];

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool searching) {
    _loading = searching;
    notifyListeners();
  }

  List<KdbxEntry> _searchResult = [];
  List<KdbxEntry> get searchResult => _searchResult;
  set searchResult(List<KdbxEntry> entries) {
    _searchResult = entries;
    notifyListeners();
  }

  Timer? _debounce;

  /// 根据关键词搜索
  Future<List<KdbxEntry>> _searchByKeyword(String keyword, int maxCount) {
    final completer = Completer<List<KdbxEntry>>();
    _debounce?.cancel();
    if (keyword.isEmpty) {
      try {
        completer.complete(entries.take(maxCount).toList());
        return completer.future;
      } catch (e) {
        logger.e(e);
        completer.completeError(e);
      }
    }

    _debounce = Timer(const Duration(milliseconds: 200), () {
      try {
        final matchedEntries = entries.where(
          (entry) =>
              entry.debugLabel()?.toLowerCase().contains(
                keyword.toLowerCase(),
              ) ??
              true,
        );
        completer.complete(matchedEntries.take(maxCount).toList());
      } catch (err) {
        logger.e(err);
        completer.completeError(err);
      }
    });
    return completer.future;
  }

  /// 根据关键词搜索 + 分组过滤
  /// - keyword: 搜索关键词
  /// - selectedGroups: 筛选的分组
  /// - maxCount: 最多返回的条目数
  Future<void> searchEntry(
    String keyword, [
    SearchPageGroupVM? targetGroup,
    int maxCount = defaultMaxCount,
  ]) async {
    loading = true;
    targetGroup ??= groupAll;
    try {
      // 1. 根据关键字搜索
      final keywordResult = await _searchByKeyword(keyword, maxCount);

      // 2. 如果是groupAll, 那么则是搜索全部并通过keywordResult再次筛选
      if (targetGroup == groupAll) {
        searchResult =
            kdbxUIProvider.rootGroup.getAllEntries().where(keywordResult.contains).toList();
        return;
      }
      // 3. 否则搜索指定分组
      assert(targetGroup.group != null);

      searchResult = targetGroup.group!.entries.where(keywordResult.contains).toList();
    } catch (e) {
      logger.e(e);
      rethrow;
    } finally {
      loading = false;
    }
  }

  void handleTabChange() async {
    if (tabController.indexIsChanging) return;
    _currentGroupIndex = tabController.index;
    await searchEntry(searchController.text, currentGroup);
  }

  void handleTextChange() async =>
      await searchEntry(searchController.text, currentGroup);

  @override
  void dispose() {
    searchController.removeListener(handleTextChange);
    tabController.removeListener(handleTabChange);

    _debounce?.cancel();
    searchController.dispose();
    tabController.dispose();
    super.dispose();
  }
}
