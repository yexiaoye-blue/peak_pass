import 'package:flutter/material.dart';

// 修改这个 KeyboardUtils工具类
// https://stackoverflow.com/questions/44991968/how-can-i-dismiss-the-on-screen-keyboard?page=1&tab=trending#tab-top
class KeyboardUtils {
  static void hide(BuildContext context) =>
      FocusManager.instance.primaryFocus?.unfocus();

  static void showKeyboard(BuildContext context, FocusNode focusNode) =>
      FocusScope.of(context).requestFocus(focusNode);

  // 这个并不能准确检测 键盘的显示与隐藏，例如
  // http://stackoverflow.com/questions/48750361/flutter-detect-keyboard-open-and-close/65477861
  // 如果要准确检测，使用 flutter_keyboard_visibility
  static bool state(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom > 0;
}
