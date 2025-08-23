import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:peak_pass/common/enums/enums.dart';

import '../../common/constants/path_key.dart';

/// 应用资源路径管理
class AppPathManager {
  final Directory appDocumentsDir;
  final Directory appSupportDir;
  final Directory temporaryDir;

  AppPathManager._({
    required this.appDocumentsDir,
    required this.appSupportDir,
    required this.temporaryDir,
  });

  static Future<AppPathManager> setup() async {
    return AppPathManager._(
      appDocumentsDir: await getApplicationDocumentsDirectory(),
      appSupportDir: await getApplicationSupportDirectory(),
      temporaryDir: await getTemporaryDirectory(),
    );
  }

  /// 根据指定的目录类型 [DirType] 和子路径 [sub]，
  /// 返回对应的 [Directory] 对象，并在必要时自动创建该目录。
  ///
  /// - [DirType.appDoc]：使用应用文档目录（getApplicationDocumentsDirectory）
  /// - [DirType.appSupport]：使用应用支持目录（getApplicationSupportDirectory）
  /// - [DirType.temporary]：使用临时目录（getTemporaryDirectory）
  /// - [DirType.custom]：直接使用 [sub] 作为完整路径，不拼接父目录
  ///
  /// 子路径 [sub] 会与对应目录拼接，并确保目录存在（自动创建）
  ///
  /// 如果类型为 [DirType.custom]，不会创建，只返回对应目录对象。
  Future<Directory> _handleDirType(DirType type, String sub) async {
    if (type == DirType.custom) return Directory(sub);
    // 获取对应类型的基础目录
    final baseDir = switch (type) {
      DirType.appDoc => appDocumentsDir,
      DirType.appSupport => appSupportDir,
      DirType.temporary => temporaryDir,
      _ => throw UnsupportedError('Unsupported DirType: $type'),
    };
    // 拼接子目录路径并确保目录存在
    final target = Directory(p.join(baseDir.path, sub));
    return await target.exists()
        ? target
        : await target.create(recursive: true);
  }

  /// files/database
  Future<Directory> get dbDir async =>
      await _handleDirType(DirType.appSupport, PathKey.databaseDir);

  /// files/db_recycle_bin
  Future<Directory> get dbRecycleBinDir async =>
      await _handleDirType(DirType.appSupport, PathKey.databaseRecycleBinDir);

  /// files/keyfile
  Future<Directory> get keyfileRootDir async =>
      await _handleDirType(DirType.appSupport, PathKey.databaseDir);

  /// files/keyfile_recycle_bin
  Future<Directory> get keyfileRecycleBinDir async =>
      await _handleDirType(DirType.appSupport, PathKey.keyfileRecycleBinDir);

  /// app_flutter/user_assets
  Future<Directory> get userAssetsDir async =>
      await _handleDirType(DirType.appDoc, PathKey.userAssets);

  /// app_flutter/user_assets/icons
  Future<Directory> get userAssetsIconDir async =>
      await _handleDirType(DirType.appDoc, PathKey.userAssetsIcon);
}
