import 'package:flutter/material.dart';
import 'package:peak_pass/router.dart';

class RouteStackObserverProvider extends ChangeNotifier {
  final RouteStackObserver _observer = RouteStackObserver();

  RouteStackObserver get observer => _observer;

  // 提供对路由栈的访问
  List<String> get routeStack => _observer.routeStack;

  Future<void> popUntilRoute(BuildContext context, String targetRouteName) async {
    final navigator = Navigator.of(context);
    while (routeStack.isNotEmpty && observer.lastRoute != targetRouteName) {
      if (navigator.canPop()) {
        navigator.pop();
        await Future.delayed(const Duration(milliseconds: 10)); // 等待pop后stack刷新
      } else {
        break; // 已经没有页面可以pop
      }
    }
  }
}
