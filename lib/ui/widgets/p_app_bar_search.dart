// custom_app_bar.dart
import 'package:flutter/material.dart';

typedef OnUpdateSearchQuery = void Function(String newQuery);
typedef OnPressSearchButton = void Function(String query);

class PAppBarSearch extends StatefulWidget implements PreferredSizeWidget {
  // 输入文本改变的回调
  final OnUpdateSearchQuery onUpdateSearchQuery;

  // Callback when the user clicks the search button [not search icon]
  final OnPressSearchButton? onPressSearchButton;

  // 默认状态下的title
  final Widget? normalTitle;

  final String? hintText;

  // 如果添加，插入到actions的最左侧
  final List<Widget>? actions;

  final Color? backgroundColor;

  const PAppBarSearch({
    super.key,
    required this.onUpdateSearchQuery,
    this.onPressSearchButton,
    this.normalTitle,
    this.hintText,
    this.actions,
    this.backgroundColor,
  });

  @override
  State<PAppBarSearch> createState() => _PAppBarSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _PAppBarSearchState extends State<PAppBarSearch> {
  late final TextEditingController searchQueryController;
  bool isSearching = false;

  @override
  void initState() {
    searchQueryController =
        TextEditingController()..addListener(() {
          setState(() {});
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      // back button
      titleSpacing: isSearching ? 0 : null,
      leading:
          isSearching
              ? IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              )
              : null,
      // normal title / search field
      title: isSearching ? _buildSearchField() : widget.normalTitle,
      actions: [
        isSearching
            ? TextButton(
              style: TextButton.styleFrom(
                overlayColor: Colors.transparent, // 禁用按下背景
                splashFactory: NoSplash.splashFactory, // 禁用水波纹
              ).copyWith(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) =>
                      states.contains(WidgetState.pressed)
                          ? Theme.of(context).colorScheme.inversePrimary
                          : null,
                ),
              ),
              onPressed: () {
                widget.onPressSearchButton?.call(searchQueryController.text);
              },
              child: const Text('Search'),
            )
            : IconButton(
              icon: const Icon(Icons.search),
              onPressed: _startSearch,
            ),
        if (!isSearching) ...?widget.actions,
      ],
    );
  }

  @override
  void dispose() {
    searchQueryController.dispose();
    super.dispose();
  }

  Widget _buildSearchField() {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      height: 36,
      child: TextField(
        controller: searchQueryController,
        autofocus: true,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14.0,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainer,
          isDense: true,
          isCollapsed: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(24),
          ),

          // clear icon button
          suffixIcon: Visibility(
            visible: searchQueryController.text.isNotEmpty,
            child: GestureDetector(
              onTap: _clearSearchQuery,
              child: Icon(Icons.clear),
            ),
          ),
        ),
        onChanged: widget.onUpdateSearchQuery,
      ),
    );
  }

  void _startSearch() {
    // 向当前路由的本地历史中添加一个 条目（按返回键 `返回前`的状态）,当用户按返回按钮时触发该回调，
    // 也就是传递给onRemove的 _stopSearching
    ModalRoute.of(
      context,
    )?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      isSearching = true;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();
    setState(() {
      isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      searchQueryController.clear();
      widget.onUpdateSearchQuery('');
    });
  }
}
