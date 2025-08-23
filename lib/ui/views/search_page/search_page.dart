import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
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
  late final TextEditingController _searchController;
  late List<KdbxGroup> defaultGroups;

  late final TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _searchController =
        TextEditingController()..addListener(() {
          setState(() {});
        });

    final dbProvider = context.read<KdbxUIProvider>();
    defaultGroups = dbProvider.groupsUI;

    _tabController = TabController(
      length: defaultGroups.length + 1,
      vsync: this,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchPageProvider = SearchPageProvider(
      context.read<KdbxUIProvider>().entriesUI,
      context.read<KdbxUIProvider>().groupsUI,
    );

    return ChangeNotifierProvider<SearchPageProvider>.value(
      value: searchPageProvider,
      child: Scaffold(
        appBar: SearchHeader(
          tabController: _tabController,
          searchController: _searchController,
          defaultGroups: defaultGroups,
        ),
        body: TabBarView(
          controller: _tabController,
          children: List.generate(defaultGroups.length + 1, (index) {
            // 只构建当前 tab，其余返回空容器，真正不渲染
            return SearchBody(render: _currentTabIndex == index);
          }),
        ),
      ),
    );
  }
}
