import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/ui/views/add_group.dart';
import 'package:peak_pass/ui/views/choose_icon.dart';
import 'package:peak_pass/ui/views/create_database/create_database_page.dart';
import 'package:peak_pass/ui/views/enter_code_manually/enter_code_manually_page.dart';
import 'package:peak_pass/ui/views/entry_manage/entry_manage_page.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin.dart';
import 'package:peak_pass/ui/views/entry_recycler_bin/entry_recycler_bin_detail.dart';
import 'package:peak_pass/ui/views/error.dart';
import 'package:peak_pass/ui/views/home/home_page.dart';
import 'package:peak_pass/ui/views/language.dart';
import 'package:peak_pass/ui/views/otp_parameter_setting.dart';
import 'package:peak_pass/ui/views/password_generator.dart';
import 'package:peak_pass/ui/views/scanner_page.dart';
import 'package:peak_pass/ui/views/search_page/search_page.dart';
import 'package:peak_pass/ui/views/settings.dart';
import 'package:peak_pass/ui/views/unlock_database/unlock_database.dart';
import 'package:peak_pass/ui/views/welcome/welcome_page.dart';
import 'package:peak_pass/ui/widgets/privacy_protection.dart';
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

class RouteConfig {
  const RouteConfig._();
  static final _instance = RouteConfig._();
  static RouteConfig instance() => _instance;

  GoRouter router(List<NavigatorObserver>? observers) => GoRouter(
    initialLocation: _path(WelcomePage.routeName),
    debugLogDiagnostics: true,
    redirect: _redirect,
    observers: observers,
    routes: [
      ShellRoute(
        routes: _routes(),
        builder: (context, state, child) => PrivacyProtection(child: child),
      ),
    ],
  );

  List<RouteBase> _routes() => [
    GoRoute(
      name: WelcomePage.routeName,
      path: _path(WelcomePage.routeName),
      builder: (context, _) {
        context.read<FileProvider>().reload();
        return const WelcomePage();
      },
    ),
    GoRoute(
      name: HomePage.routeName,
      path: _path(HomePage.routeName),
      builder: (_, _) => const HomePage(),
    ),
    GoRoute(
      name: SearchPage.routeName,
      path: _path(SearchPage.routeName),
      builder: (_, _) => const SearchPage(),
    ),
    GoRoute(
      name: UnlockDatabasePage.routeName,
      path: _path(UnlockDatabasePage.routeName),
      builder: (_, state) {
        final dbFileModel = state.extra as FileModel;
        return UnlockDatabasePage(databaseInfoModel: dbFileModel);
      },
    ),
    GoRoute(
      name: EntryManagePage.routeName,
      path: _path(EntryManagePage.routeName),
      builder: (_, _) => const EntryManagePage(),
    ),
    GoRoute(
      name: PasswordGeneratorPage.routeName,
      path: _path(PasswordGeneratorPage.routeName),
      builder:
          (_, state) => PasswordGeneratorPage(isPopResult: state.extra == true),
    ),
    GoRoute(
      name: ChooseIconPage.routeName,
      path: _path(ChooseIconPage.routeName),
      builder: (_, state) {
        IconModel? defaultIcon;
        if (state.extra is IconModel || state.extra is IconModel?) {
          defaultIcon = state.extra as IconModel?;
        }
        return ChooseIconPage(defaultIcon: defaultIcon);
      },
    ),
    GoRoute(
      name: SettingsPage.routeName,
      path: _path(SettingsPage.routeName),
      builder: (_, _) => const SettingsPage(),
    ),
    GoRoute(
      name: AddGroupPage.routeName,
      path: _path(AddGroupPage.routeName),
      builder: (_, _) => const AddGroupPage(),
    ),
    GoRoute(
      name: CreateDatabasePage.routeName,
      path: _path(CreateDatabasePage.routeName),
      builder: (_, _) => const CreateDatabasePage(),
    ),
    GoRoute(
      name: OtpSettingPage.routeName,
      path: _path(OtpSettingPage.routeName),
      builder: (_, _) => const OtpSettingPage(),
    ),
    GoRoute(
      name: EnterCodeManuallyPage.routeName,
      path: _path(EnterCodeManuallyPage.routeName),
      builder: (_, _) => const EnterCodeManuallyPage(),
    ),
    GoRoute(
      name: MobileScannerPage.routeName,
      path: _path(MobileScannerPage.routeName),
      builder: (_, _) => const MobileScannerPage(),
    ),
    GoRoute(
      name: LanguagePage.routeName,
      path: _path(LanguagePage.routeName),
      builder: (_, _) => const LanguagePage(),
    ),
    GoRoute(
      name: EntryRecyclerBin.routeName,
      path: _path(EntryRecyclerBin.routeName),
      builder: (_, _) => const EntryRecyclerBin(),
    ),
    GoRoute(
      name: EntryRecyclerBinDetail.routeName,
      path: _path(EntryRecyclerBinDetail.routeName),
      builder: (_, state) {
        final entry = state.extra as KdbxEntry;
        return EntryRecyclerBinDetail(entry: entry);
      },
    ),
    GoRoute(
      name: ErrorPage.routeName,
      path: _path(ErrorPage.routeName),
      builder: (_, _) => const ErrorPage(),
    ),
  ];

  FutureOr<String?> _redirect(BuildContext context, GoRouterState state) {
    final initialized = context.read<KdbxUIProvider>().initialized;
    // 1. 白名单：直接放行（与初始化状态无关）
    const alwaysAllow = <String>[LanguagePage.routeName];
    if (alwaysAllow.any(
      (name) => state.matchedLocation.startsWith(_path(name)),
    )) {
      return null;
    }
    // 2. 初始化前可访问，但初始化后直接跳首页
    const beforeInitOnly = <String>[
      WelcomePage.routeName,
      UnlockDatabasePage.routeName,
      CreateDatabasePage.routeName,
    ];
    if (beforeInitOnly.any(
      (name) => state.matchedLocation.startsWith(_path(name)),
    )) {
      // 在设置页面切换主题色时,保持在该页面
      final themeProvider = context.read<ThemeProvider>();
      if (initialized && themeProvider.isSettingsPage) {
        themeProvider.isSettingsPage = false;
        return _path(SettingsPage.routeName);
      }
      if (initialized) {
        return _path(HomePage.routeName);
      }
      return null;
    }
    // 3. 其他页面，初始化前一律跳 Welcome
    if (!initialized) {
      return _path(WelcomePage.routeName);
    }
    // 4. 其他情况放行
    return null;
  }

  String _path(String routeName) => '/$routeName';
}

class RouteStackObserver extends NavigatorObserver {
  // 用于保存路由栈的路径列表
  final List<String> routeStack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeStack.add(route.settings.name ?? '');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeStack.removeLast();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    routeStack.removeWhere((name) => name == route.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final res = routeStack.indexOf(oldRoute?.settings.name ?? '');
    if (res != -1) routeStack[res] = newRoute?.settings.name ?? '';
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    super.didChangeTop(topRoute, previousTopRoute);
    if (topRoute.settings.name != null) {
      if (routeStack.length - 1 >= 0) {
        routeStack[routeStack.length - 1] = topRoute.settings.name!;
      }
    }
  }

  // 获取当前栈中的最后一个页面
  String get lastRoute => routeStack.isNotEmpty ? routeStack.last : '';
}
