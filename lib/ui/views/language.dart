import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/locale_provider.dart';
import 'package:provider/provider.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});
  static const String routeName = 'language';

  @override
  Widget build(BuildContext context) {
    final provider = context.read<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          loc(context).languages,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView.separated(
        itemCount: provider.supportedLocales.length,
        itemBuilder: (context, index) {
          final locale = provider.supportedLocales[index];
          final currentLocale = provider.locale;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: Text(LocUtils.getDisplayName(locale)),
              subtitle: Text(LocUtils.getLocalizedString(context, locale)),
              tileColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              onTap: () {
                try {
                  provider.setLocale(locale);
                } on BusinessException catch (err) {
                  logger.i(err);
                  showToastBottom(err.message);
                } catch (err) {
                  logger.e(err);
                }
              },
              selected: locale == currentLocale,
              selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
          );
        },
        separatorBuilder: (context, index) => const Gap.vertical(4),
      ),
    );
  }
}
