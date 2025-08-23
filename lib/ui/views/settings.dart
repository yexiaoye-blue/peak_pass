import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/ui/views/home/home_page.dart';
import 'package:peak_pass/ui/views/language.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String routeName = 'settings';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.goNamed(HomePage.routeName);
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(loc(context).settings),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.language_outlined),
              tileColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              title: Text(loc(context).languages),
              onTap: () => context.pushNamed(LanguagePage.routeName),
            ),
            const Gap.vertical(4),
            ListTile(
              leading: Icon(
                themeProvider.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              title: Text(loc(context).theme),
              trailing: Switch(
                value: themeProvider.isDark,
                onChanged: (val) {
                  themeProvider.setTheme(val);
                },
              ),
              // onTap: () => context.pushNamed(LanguagePage.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
