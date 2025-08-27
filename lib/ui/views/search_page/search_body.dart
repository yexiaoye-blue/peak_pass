import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/ui/views/entry_manage/entry_manage_page.dart';
import 'package:peak_pass/ui/widgets/entry_list_tile.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/view_models/search_page_provider.dart';
import 'package:provider/provider.dart';

class SearchBody extends StatelessWidget {
  const SearchBody({super.key, required this.render});

  /// 是否渲染该页面
  final bool render;

  @override
  Widget build(BuildContext context) {
    if (!render) return const SizedBox();

    final provider = context.watch<SearchPageProvider>();
    final loading = provider.loading;

    if (loading) return const Center(child: CircularProgressIndicator());

    final entries = provider.searchResult;
    if (entries.isEmpty) return const Center(child: Text('No result'));

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8),
      itemCount: entries.length,
      itemBuilder:
          (context, index) => EntryListTile(
            key: ValueKey(entries[index].uuid),
            entry: entries[index],
            onTap: () {
              context.pushNamed(
                EntryManagePage.routeName,
                extra: <String, dynamic>{
                  'kdbxEntry': entries[index],
                  'pageType': EntryPageType.details,
                },
              );
            },
          ),
      separatorBuilder: (context, index) => const Gap.vertical(4),
    );
  }
}
