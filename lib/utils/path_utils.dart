import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:peak_pass/common/constants/path_key.dart';
import 'package:uuid/uuid.dart';

class PathUtils {
  /// 重命名.默认 uuid v4 (random) id
  /// - [name]: 如果name不为空,则使用该name作为新文件名
  static String renameWithUuid(String path, [String? name]) {
    final dir = p.dirname(path);
    final ext = p.extension(path);
    return p.join(dir, '${name ?? const Uuid().v4()}$ext');
  }

  static String renameByTimestamp(String path) {
    final dir = p.dirname(path);
    final ext = p.extension(path);
    return p.join(dir, '${DateTime.now().millisecondsSinceEpoch}$ext');
  }

  /// 判断是否以.kdbx结尾
  static bool isKdbxFile(String fullname) =>
      fullname.toLowerCase().endsWith(PathKey.databaseExtension);

  /// 判断是否以.kdbx结尾
  static const String keyfileExtension = '.keyx';
  static bool isKeyfile(String fullname) =>
      fullname.toLowerCase().endsWith(PathKey.keyfileExtension);

  /// 获取指定路径下的所有满足条件的文件全路径
  /// - [parent]: 目标目录
  /// - [condition]: 判断函数,true 添加; false 不添加
  static Future<List<String>> getAllFilePaths(
    String parent,
    bool Function(String) condition,
  ) async {
    Directory parentDir = Directory(parent);
    final exists = await parentDir.exists();
    if (!exists) {
      parentDir = await parentDir.create(recursive: true);
    }
    final List<String> filenames = [];
    await for (final entity in Directory(parent).list()) {
      if (condition(entity.path)) filenames.add(entity.path);
    }

    return filenames;
  }
}
