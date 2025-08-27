import 'package:flutter/material.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/search_page_provider.dart';
import 'package:provider/provider.dart';

class SearchHeader extends StatelessWidget implements PreferredSizeWidget {
  const SearchHeader({
    super.key,
    required this.tabController,
    required this.searchController,
  });

  final TabController tabController;
  final TextEditingController searchController;

  static const double tabBarHeight = 36;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SearchPageProvider>();

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
                await provider.searchEntry('');
                tabController.index = 0;
              },
              child: Icon(Icons.clear),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await provider.searchEntry(
              searchController.text,
              provider.currentGroup,
            );
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
          tabs: List.generate(
            provider.groups.length,
            (index) => Tab(
              text: LocUtils.localizeGroupName(
                context,
                provider.groups[index].name,
              ),
              height: 36,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight + tabBarHeight);
}
