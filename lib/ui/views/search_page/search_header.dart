import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';

import '../../../view_models/search_page_provider.dart';

class SearchHeader extends StatelessWidget implements PreferredSizeWidget {
  const SearchHeader({
    super.key,
    required this.tabController,
    required this.searchController,
    required this.defaultGroups,
  });

  final TabController tabController;
  final TextEditingController searchController;
  final List<KdbxGroup> defaultGroups;

  static const double tabBarHeight = 36;

  @override
  Widget build(BuildContext context) {
    final searchPageProvider = context.read<SearchPageProvider>();

    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 8,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
      elevation: 1,
      title: SearchBar(
        controller: searchController,
        onChanged: (val) async {
          await searchPageProvider.searchByKeyword(val);
        },
        constraints: const BoxConstraints(
          minWidth: 360,
          maxWidth: 800,
          minHeight: 40,
          maxHeight: 40,
        ),
        padding: const WidgetStatePropertyAll<EdgeInsets>(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        elevation: const WidgetStatePropertyAll(0),
        leading: const Icon(Icons.search_rounded),
        trailing: [
          // Clear
          if (searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () async {
                searchController.clear();
                await searchPageProvider.searchByKeyword(searchController.text);
                tabController.index = 0;
              },
              child: Icon(Icons.clear),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await searchPageProvider.searchByKeyword(searchController.text);
          },
          child: Text(loc(context).search),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(tabBarHeight),
        child: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          overlayColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainer,
          ),
          padding: EdgeInsets.all(0),
          tabs: [
            Tab(text: 'All', height: tabBarHeight),
            ...List.generate(
              defaultGroups.length,
              (index) => Tab(text: defaultGroups[index].name.get(), height: 36),
            ),
          ],
          onTap: (index) async {
            await searchPageProvider.filterSearchResultByGroups(
              searchController.text,
              index == 0 ? [] : [defaultGroups[index]],
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + tabBarHeight);
}
