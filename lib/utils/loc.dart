import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations loc(BuildContext context) => AppLocalizations.of(context)!;

class LocUtils {
  const LocUtils._();

  /// 获取对应的本地化值
  static String getLocalizedString(BuildContext context, Locale locale) {
    final localizations = loc(context);

    switch (locale.toString()) {
      case 'zh':
        return localizations.zh;
      case 'zh_HK':
        return localizations.zhHant;
      case 'zh_TW':
        return localizations.zhHant;
      case 'en':
        return localizations.en;
      default:
        return 'Unknown';
    }
  }

  // 获取对应语言的显示名称
  static String getDisplayName(Locale locale) {
    switch (locale.toString()) {
      case 'zh':
        return "简体中文";
      case 'zh_HK':
        return "繁體中文（香港）";
      case 'zh_TW':
        return "繁體中文（台灣）";
      case 'en':
        return "English";
      default:
        return 'Unknown';
    }
  }
}
