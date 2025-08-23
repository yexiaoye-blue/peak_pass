class PathKey {
  const PathKey._();

  /// files/database
  static const String databaseDir = 'databases';
  static const String databaseRecycleBinDir = 'db_recycle_bin';

  /// files/keyfile
  static const String keyfileDir = 'keyfile';
  static const String keyfileRecycleBinDir = 'keyfile_recycle_bin';

  /// app_flutter/user_assets
  static const String userAssets = 'user_assets';
  static const String userAssetsIcon = '$userAssets/icons';

  static const String keyfileExtension = '.keyx';
  static const String databaseExtension = '.kdbx';
}
