import 'package:flutter/material.dart';
import 'package:peak_pass/ui/views/search_page/search_body.dart';
import 'package:peak_pass/ui/views/search_page/search_header.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/view_models/search_page_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const String routeName = 'search-page';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final provider = SearchPageProvider(this, context.read<KdbxUIProvider>());

    return ChangeNotifierProvider<SearchPageProvider>.value(
      value: provider,
      child: Scaffold(
        appBar: SearchHeader(
          tabController: provider.tabController,
          searchController: provider.searchController,
        ),
        body: TabBarView(
          controller: provider.tabController,
          children: List.generate(provider.groups.length, (index) {
            // 只构建当前 tab，其余返回空容器
            return Selector<SearchPageProvider, int>(
              selector: (_, provider) => provider.currentGroupIndex,
              builder: (_, currentIndex, __) {
                return SearchBody(render: index == currentIndex);
              },
            );
          }),
        ),
      ),
    );
  }
}
