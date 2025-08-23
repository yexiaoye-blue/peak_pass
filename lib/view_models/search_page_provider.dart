import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';

import '../utils/common_utils.dart';

class SearchPageProvider extends ChangeNotifier {
  final List<KdbxEntry> entries;
  final List<KdbxGroup> groups;
  SearchPageProvider(this.entries, this.groups) {
    // Tab: 'All' 默认加载10条
    _searchResult = entries.take(10).toList();
  }

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
  Future<List<KdbxEntry>> searchByKeyword(String keyword, [int? maxCount]) {
    loading = true;
    final completer = Completer<List<KdbxEntry>>();
    _debounce?.cancel();

    // keyword empty
    if (keyword.isEmpty) {
      if (maxCount != null) {
        searchResult =
            entries
                .getRange(
                  0,
                  maxCount >= entries.length ? entries.length : maxCount,
                )
                .toList();
        completer.complete(searchResult);
      } else {
        searchResult = entries;
        completer.complete(searchResult);
      }

      loading = false;
      return completer.future;
    }

    _debounce = Timer(const Duration(milliseconds: 200), () {
      try {
        // 关键词搜索
        final List<KdbxEntry> res = [];
        for (var entry in entries) {
          if (entry.debugLabel()?.toLowerCase().contains(
                keyword.toLowerCase(),
              ) ??
              true) {
            if (maxCount != null && res.length >= maxCount) {
              break;
            } else {
              res.add(entry);
            }
          }
        }
        searchResult = res;
      } catch (err) {
        logger.e(err);

        searchResult = [];
      } finally {
        completer.complete(searchResult);
        loading = false;
      }
    });
    return completer.future;
  }

  /// 根据关键词搜索 + 分组过滤
  Future<List<KdbxEntry>> filterSearchResultByGroups(
    String keyword,
    List<KdbxGroup> selectedGroups, [
    bool sortGroup = false,
  ]) async {
    if (sortGroup) {
      groups.sort((a, b) {
        final aSelected = selectedGroups.contains(a);
        final bSelected = selectedGroups.contains(b);

        if (aSelected && !bSelected) return -1;
        if (!aSelected && bSelected) return 1;

        // 保持原顺序
        return 0;
      });
    }

    final searchRes = await searchByKeyword(keyword);
    if (selectedGroups.isEmpty) {
      searchResult = searchRes;
      return searchRes;
    }
    searchResult =
        selectedGroups
            .expand((group) => group.entries)
            .where((entry) => searchRes.contains(entry))
            .toList();
    return searchResult;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
