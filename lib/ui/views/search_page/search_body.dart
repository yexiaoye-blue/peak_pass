import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:provider/provider.dart';

import '../../../common/enums/enums.dart';
import '../../../view_models/search_page_provider.dart';
import '../../widgets/entry_list_tile.dart';
import '../entry_manage/entry_manage_page.dart';

class SearchBody extends StatelessWidget {
  const SearchBody({super.key, required this.render});
  final bool render;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchPageProvider>();
    final entries = provider.searchResult;
    final searching = provider.loading;
    return render && !searching
        ? entries.isNotEmpty
            ? ListView.separated(
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
                        // pathParameters: {EntryManagePage.paramMode: EntryManagePageType.details.mode},
                      );
                    },
                  ),
              separatorBuilder: (context, index) => const Gap.vertical(4),
            )
            : Center(child: const Text('No entries.'))
        : Center(child: CircularProgressIndicator());
  }
}
