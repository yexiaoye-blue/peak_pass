class StorageKey {
  const StorageKey._();

  static const String customIconsKey = 'CUSTOM_ICONS_KEY';
  static const String keyfileKey = 'KEYFILE_KEY';

  /// 当用户选择已存在的 数据库,则将其路径保存一份
  static const String customDatabaseDir = 'CUSTOM_DATABASE_DIR_KEY';

  static const String unlockByPwd = 'UNLOCK_BY_PWD';
  static const String unlockByKeyfile = 'UNLOCK_BY_KEYFILE';
  static const String unlockByTouchId = 'UNLOCK_BY_TOUCH_ID';

  static const String lastOpenedDatabase = 'LAST_OPENED_DATABASE';

  static const String themeMode = 'THEME_MODE';

  static const String locale = "LOCALE";
}
