import 'package:flutter/material.dart';

/// A global Dialog Route Manager for push/pop dialog as normal route.
class DialogRouteManager {
  static Future<T?> showDialogRoute<T>(
    BuildContext context, {
    required String routeName,
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(routeName, arguments: arguments);
  }

  static void popDialogRoute<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  static void popUntilDialogRoute(BuildContext context, String dialogRouteName) {
    Navigator.of(context).popUntil((route) => route.settings.name == dialogRouteName);
  }
}
