import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/widgets/fade_cross_transition.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';

import 'package:peak_pass/ui/shared/category_filter.dart';
import 'package:peak_pass/ui/views/home/home_header.dart';
import 'package:peak_pass/ui/views/home/home_page_controller.dart';
import 'package:peak_pass/ui/views/home/p_drawer.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/ui/widgets/entry_list_tile.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/ui/widgets/sort_menu.dart';
import 'package:peak_pass/ui/views/search_page/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = 'home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // 初始化UI model
    final kdbxUIProvider = context.read<KdbxUIProvider>();
    kdbxUIProvider.resetUIModel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kdbxUIProvider.removeUnsaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<KdbxUIProvider, HomePageController>(
      create:
          (context) => HomePageController(
            tickerProvider: this,
            uiProvider: context.read<KdbxUIProvider>(),
            kdbxService: Provider.of<KdbxService>(context, listen: false),
          ),
      update: (context, kdbxUIProvider, previous) {
        previous?.update(kdbxUIProvider);
        return previous ??
            HomePageController(
              tickerProvider: this,
              uiProvider: context.read<KdbxUIProvider>(),
              kdbxService: Provider.of<KdbxService>(context, listen: false),
            );
      },

      /// TODO: 问题实际上就出在这里, _HomeScreen 中使用状态 并不是最新的
      child: Consumer<KdbxService>(
        builder: (context, kdbxService, child) {
          return _HomeScreen(key: ValueKey(kdbxService.initialized));
        },
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final kdbxUIProvider = context.watch<KdbxUIProvider>();
    final homeCtl = context.watch<HomePageController>();
    final kdbxService = Provider.of<KdbxService>(context, listen: false);

    return Scaffold(
      key: homeCtl.scaffoldKey,
      appBar: HomeHeader(
        animation: homeCtl.editingAnimation,
        leftNormalChild: Row(
          spacing: 4,
          children: [
            IconButton(
              onPressed: () {
                homeCtl.openDrawer();
              },
              icon: Icon(Icons.menu),
            ),
            Flexible(
              child: Text(
                kdbxService.databaseName ?? loc(context).passwordList,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        leftEditingChild: TextButton(
          onPressed: () {
            homeCtl.toggleEntrySelection();
          },
          child: Text(loc(context).checkAll),
        ),

        rightNormalChild: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // go search page
            IconButton(
              onPressed: () {
                context.pushNamed(SearchPage.routeName);
              },
              icon: const Icon(Icons.search_rounded),
            ),
            // change category layout
            IconButton(
              onPressed: () {
                homeCtl.toggleLayout();
              },
              icon: AnimatedCrossFade(
                firstChild: Icon(Icons.grid_view_rounded),
                secondChild: Icon(Icons.list_rounded),
                crossFadeState:
                    homeCtl.isGridLayout
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                duration: Durations.short4,
              ),
            ),
          ],
        ),

        rightEditingChild: TextButton(
          onPressed: homeCtl.toNormal,
          child: Text(loc(context).cancel),
        ),
      ),

      drawer: PDrawer(),
      body: RefreshIndicator(
        onRefresh: () => Future.delayed(const Duration(milliseconds: 250)),
        child: StreamBuilder(
          stream: kdbxService.dirtyObjectsChanged,
          builder: (context, snapshot) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Category filter title
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc(context).groups,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: homeCtl.selectedGroups.isNotEmpty ? 1 : 0,
                          duration: Durations.short4,
                          child: TextButton(
                            onPressed: () {
                              homeCtl.clearSelectedGroups();
                            },
                            child: Text(loc(context).clear),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: CategoryFilter(
                    isGridLayout: homeCtl.isGridLayout,
                    animation: homeCtl.categoryAnimationCtl.view,
                    groups: kdbxUIProvider.groupsUI,
                    selectedGroups: homeCtl.selectedGroups,
                    onValuesChanged: (groups) {
                      homeCtl.updateSelectedGroups(groups);
                    },
                  ),
                ),
                if (!homeCtl.isGridLayout) ...[
                  // List title
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc(context).lists,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SortMenu(
                            data: kdbxUIProvider.entriesUI,
                            sortType: homeCtl.sortType,
                            onPress: (val) {
                              homeCtl.updateSortType(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // List content
                  SliverList.separated(
                    itemCount: kdbxUIProvider.entriesUI.length,
                    itemBuilder: (context, index) {
                      return EntryListTile(
                        animation: homeCtl.editingAnimation,
                        entry: kdbxUIProvider.entriesUI[index],
                        onLongPress: () {
                          homeCtl.toEditing();
                        },
                        onTap: () {
                          context
                              .read<CurrentEntryController>()
                              .goEntryMangePage(
                                context: context,
                                type: EntryPageType.details,
                                kdbxEntry: kdbxUIProvider.entriesUI[index],
                              );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Gap.vertical(4),
                  ),
                ],

                // Gap
                SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FadeCrossTransition(
        animation: homeCtl.editingAnimation,
        firstChild: FloatingActionButton(
          heroTag: 'fab_add',
          onPressed: () {
            context.read<CurrentEntryController>().goEntryMangePage(
              context: context,
              type: EntryPageType.newEntry,
            );
          },
          tooltip: loc(context).newEntry,
          child: Icon(Icons.add),
        ),
        secondChild: FloatingActionButton(
          heroTag: 'fab_delete',
          onPressed: () => homeCtl.deleteSelectedEntries(context),
          tooltip: loc(context).delete,
          child: Icon(Icons.delete),
        ),
      ),
    );
  }
}
