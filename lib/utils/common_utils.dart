import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';

// Logger
var logger = Logger(printer: PrettyPrinter());

// Show Toast
showToastBottom(String message) {
  showToast(message, position: ToastPosition.bottom);
}

// Copy to clipboard
Future<void> copyToClipboard(String text) async =>
    await Clipboard.setData(ClipboardData(text: text));

class CommonUtils {
  const CommonUtils._();

  static Locale? fromLanguageTagStr(String languageTag) {
    final codes = languageTag.split('-');

    if (codes.length == 1) {
      return Locale(codes.single);
    }
    if (codes.length == 2) {
      return Locale(codes[0], codes[1]);
    }
    if (codes.length == 3) {
      return Locale.fromSubtags(
        languageCode: codes[0],
        scriptCode: codes[1],
        countryCode: codes[2],
      );
    }
    return null;
  }
}
