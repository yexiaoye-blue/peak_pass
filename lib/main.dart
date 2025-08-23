import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:peak_pass/common/theme.dart';
import 'package:peak_pass/data/services/app_path_manager.dart';
import 'package:peak_pass/data/services/biometric_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/data/services/file_service.dart';
import 'package:peak_pass/data/services/impl/local_file_service_impl.dart';
import 'package:peak_pass/data/repositories/storage_repository.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';
import 'package:peak_pass/plugin/aufofill_plugin.dart';
import 'package:peak_pass/ui/views/entry_manage/current_entry_controller.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:peak_pass/view_models/icon_provider.dart';
import 'package:peak_pass/view_models/locale_provider.dart';
import 'package:peak_pass/view_models/route_stack_observer_provider.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:peak_pass/router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageRepository.setup();
  final appPathManager = await AppPathManager.setup();

  final localFileService = LocalFileServiceImpl(appPathManager);
  final biometricService = BiometricService();
  final kdbxService = KdbxService(localFileService);

  final iconProvider = IconProvider(appPathManager);
  await iconProvider.initialIcons();

  final fileProvider = await FileProvider.create(localFileService);
  final localProvider = LocaleProvider();

  // await load from share_pre
  // 设置自动填充channel
  AutofillService().setupAutofillChannel(kdbxService, biometricService);

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageServiceUtils>(create: (_) => StorageServiceUtils()),
        Provider<BiometricService>.value(value: biometricService),
        Provider<KdbxService>.value(value: kdbxService),
        Provider<AppPathManager>.value(value: appPathManager),
        Provider<FileService>.value(value: localFileService),

        ChangeNotifierProvider<FileProvider>.value(value: fileProvider),
        ChangeNotifierProvider<IconProvider>.value(value: iconProvider),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RouteStackObserverProvider()),
        ChangeNotifierProvider<KdbxUIProvider>(
          create: (context) => KdbxUIProvider(context.read<KdbxService>()),
        ),
        ChangeNotifierProvider<CurrentEntryController>(
          create:
              (context) => CurrentEntryController(
                kdbxService: context.read<KdbxService>(),
              ),
        ),
      ],
      child: ChangeNotifierProvider<LocaleProvider>.value(
        value: localProvider,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<LocaleProvider, ThemeProvider>(
      builder: (context, localeProvider, themeProvider, child) {
        return OKToast(
          child: MaterialApp.router(
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: RouteConfig.instance().router([
              routeObserver,
              context.read<RouteStackObserverProvider>().observer,
            ]),
            debugShowCheckedModeBanner: false,
            title: "Peak Pass",
            theme: createLightTheme(context),

            darkTheme: createDarkTheme(context),
            themeMode: themeProvider.themeMode,
          ),
        );
      },
    );
  }
}
