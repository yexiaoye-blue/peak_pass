import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/ui/views/add_group.dart';
import 'package:peak_pass/ui/views/choose_icon.dart';
import 'package:peak_pass/ui/views/create_database/create_database_page.dart';
import 'package:peak_pass/ui/views/enter_code_manually/enter_code_manually_page.dart';
import 'package:peak_pass/ui/views/entry_manage/entry_manage_page.dart';
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
import 'package:peak_pass/view_models/kdbx_ui_provider.dart';
import 'package:peak_pass/view_models/file_provider.dart';
import 'package:peak_pass/view_models/theme_provider.dart';
import 'package:provider/provider.dart';

class RouteConfig {
  RouteConfig._();
  static final _instance = RouteConfig._();
  static RouteConfig instance() => _instance;

  String getLocation(String routeName) => '/$routeName';

  GoRouter router(List<NavigatorObserver>? observers) {
    return GoRouter(
      initialLocation: getLocation(WelcomePage.routeName),
      debugLogDiagnostics: true,

      redirect: (context, state) {
        final initialized = context.read<KdbxUIProvider>().initialized;
        // 1. 白名单：直接放行（与初始化状态无关）
        const alwaysAllow = <String>[LanguagePage.routeName];
        if (alwaysAllow.any(
          (name) => state.matchedLocation.startsWith(getLocation(name)),
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
          (name) => state.matchedLocation.startsWith(getLocation(name)),
        )) {
          // 在设置页面切换主题色时,保持在该页面
          final themeProvider = context.read<ThemeProvider>();
          if (initialized && themeProvider.isSettingsPage) {
            themeProvider.isSettingsPage = false;
            return getLocation(SettingsPage.routeName);
          }
          if (initialized) {
            return getLocation(HomePage.routeName);
          }
          return null;
        }
        // 3. 其他页面，初始化前一律跳 Welcome
        if (!initialized) {
          return getLocation(WelcomePage.routeName);
        }
        // 4. 其他情况放行
        return null;
      },

      observers: observers,
      routes: [
        GoRoute(
          name: WelcomePage.routeName,
          path: getLocation(WelcomePage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            context.read<FileProvider>().reload();
            return WelcomePage();
          },
        ),
        GoRoute(
          name: HomePage.routeName,
          path: getLocation(HomePage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
        ),
        GoRoute(
          name: SearchPage.routeName,
          path: getLocation(SearchPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return const SearchPage();
          },
        ),
        GoRoute(
          name: UnlockDatabasePage.routeName,
          path: getLocation(UnlockDatabasePage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            // if (extra is DatabaseInfoModel) {
            final dbFileModel = state.extra as FileModel;
            return UnlockDatabasePage(databaseInfoModel: dbFileModel);
          },
        ),
        GoRoute(
          name: EntryManagePage.routeName,
          // path: '${getLocation(EntryManagePage.routeName)}/:${EntryManagePage.paramMode}',
          path: getLocation(EntryManagePage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            // final extra = state.extra;
            // if (extra != null && extra is Map?) {
            //   final data = extra as Map<String, dynamic>;
            //   final entry = data['KDBX_ENTRY'] as KdbxEntry?;
            //   final pageType = data['PAGE_TYPE'] as EntryManagePageType?;
            //   return EntryManagePage(entry: entry, type: pageType);
            // }

            return EntryManagePage();
          },
        ),
        GoRoute(
          name: PasswordGeneratorPage.routeName,
          path: getLocation(PasswordGeneratorPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return PasswordGeneratorPage(isPopResult: state.extra == true);
          },
        ),
        GoRoute(
          name: ChooseIconPage.routeName,
          path: getLocation(ChooseIconPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            IconModel? defaultIcon;
            if (state.extra is IconModel || state.extra is IconModel?) {
              defaultIcon = state.extra as IconModel?;
            }
            return ChooseIconPage(defaultIcon: defaultIcon);
          },
        ),
        GoRoute(
          name: SettingsPage.routeName,
          path: getLocation(SettingsPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsPage();
          },
        ),
        GoRoute(
          name: AddGroupPage.routeName,
          path: getLocation(AddGroupPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return const AddGroupPage();
          },
        ),
        GoRoute(
          name: CreateDatabasePage.routeName,
          path: getLocation(CreateDatabasePage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return CreateDatabasePage();
          },
        ),

        GoRoute(
          name: OtpSettingPage.routeName,
          path: getLocation(OtpSettingPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return OtpSettingPage();
          },
        ),
        GoRoute(
          name: EnterCodeManuallyPage.routeName,
          path: getLocation(EnterCodeManuallyPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return EnterCodeManuallyPage();
          },
        ),
        GoRoute(
          name: MobileScannerPage.routeName,
          path: getLocation(MobileScannerPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return MobileScannerPage();
          },
        ),
        GoRoute(
          name: ErrorPage.routeName,
          path: getLocation(ErrorPage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return ErrorPage();
          },
        ),

        GoRoute(
          name: LanguagePage.routeName,
          path: getLocation(LanguagePage.routeName),
          builder: (BuildContext context, GoRouterState state) {
            return LanguagePage();
          },
        ),
      ],
    );
  }
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
