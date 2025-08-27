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

  /// 分组名称本地化, 预设餐见[PresetGroups]
  static String localizeGroupName(BuildContext context, String? groupName) {
    final localizations = loc(context);

    if (groupName == null) return localizations.unknown;
    switch (groupName) {
      case 'All':
        return localizations.all;
      case 'Personal':
        return localizations.personal;
      case 'Work':
        return localizations.work;
      case 'Finance':
        return localizations.finance;
      case 'Shopping':
        return localizations.shopping;
      case 'Social':
        return localizations.social;
      case 'Other':
        return localizations.other;
      default:
        return groupName;
    }
  }

  /// 字段本地化, 预设参见[KdbxKeyCommonExt]
  static String localizeFieldName(BuildContext context, String? fieldName) {
    final localizations = loc(context);

    if (fieldName == null) return localizations.unknown;
    if (fieldName == 'OTPAuth') return fieldName;

    switch (fieldName) {
      case 'Title':
        return localizations.title;
      case 'URL':
        return localizations.url;
      case 'UserName':
        return localizations.username;
      case 'Password':
        return localizations.password;
      case 'Email':
        return localizations.email;
      case 'Notes':
        return localizations.notes;
      case 'DateTime':
        return localizations.datetime;
      case 'Number':
        return localizations.number;
      case 'Phone':
        return localizations.phone;
      default:
        return fieldName;
    }
  }
}
