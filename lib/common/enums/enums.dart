import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

enum Languages {
  zh(name: 'Simple Chinese', code: 'zh'),
  zhHant(name: 'Traditional Chinese', code: 'zh_Hant'),
  en(name: 'English', code: 'en');

  const Languages({required this.name, required this.code});
  final String name;
  final String code;

  static String? getNameByLanguageCode(String code) =>
      Languages.values
          .firstWhereOrNull((language) => language.code == code)
          ?.name;
}

enum SortType {
  asc(name: 'Title(A-Z)', icon: Icons.arrow_upward_rounded),
  desc(name: 'Title(Z-A)', icon: Icons.arrow_downward_rounded),
  newest(name: 'Newest first', icon: Icons.hourglass_top_rounded),
  oldest(name: 'Oldest first', icon: Icons.hourglass_bottom_rounded);

  const SortType({required this.name, required this.icon});
  final String name;
  final IconData icon;
}

enum IconType {
  /// kdbx库预设
  preset,

  /// 软件预设
  software,

  /// 用户自定义
  userCustom,
}

enum EntryPageType {
  newEntry(title: 'New Entry', mode: 'NEW_ENTRY'),
  details(title: 'Details', mode: 'DETAILS');

  const EntryPageType({required this.title, required this.mode});
  final String title;
  final String mode;

  static EntryPageType getTypeByMode(String mode) =>
      EntryPageType.values.singleWhere((item) => item.mode == mode);
}

/// 目录类型
enum DirType {
  /// getApplicationDocumentDirectory
  /// e.g: /data/user/0/package_name/app_flutter
  appDoc,

  /// getApplicationSupportDirectory
  /// e.g: /data/user/0/package_name/files
  appSupport,

  /// getTemporaryDirectory
  /// e.g: /data/user/0/package_name/cache
  temporary,

  /// files/database
  /// keyfile
  custom,
}

enum CharacterType { uppercase, lowercase, digits, specialCharacter, unknown }

enum ItemFormatType {
  dateTimeDefault,
  dateTimeWithMilliseconds,
  fileSize,
  integer,
  doubleTwoDecimals,
  custom,
}

/// 该类在是为了通过handle error code然后做国际化
/// 那么这个还会导致一个问题, switch过多
enum BizErrorCode {
  unexpectedError,
  fileOperationError,
  unexpectedReadError,
  unexpectedWriteError,
  unexpectedFindError,
  unexpectedFindAllError,
  unexpectedRemoveError,
  unexpectedRemoveFromRecycleBinError,
  unexpectedRenameError,
  unexpectedRecoverError,

  biometricStorageEmpty,
}

enum AppTheme { dark, light }
