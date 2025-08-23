import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show BackgroundIsolateBinaryMessenger, RootIsolateToken;
import 'package:path_provider/path_provider.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:path/path.dart' as path;

import '../common/enums/enums.dart';

Future<void> _writeBytesToFile(List<dynamic> params) async {
  try {
    Uint8List bytes = params[0];
    String filename = params[1];
    DirType? type = params[2];
    String? customDir = params[3];
    RootIsolateToken? token = params[4];
    BackgroundIsolateBinaryMessenger.ensureInitialized(token!);

    final file = await FileUtils.getFile(filename, type, customDir);
    // await file.writeAsBytes(bytes);
    file.writeAsBytesSync(bytes);
  } catch (err) {
    logger.e(err);
  }
}

/// 文件工具类
///
/// TODO
/// 1. 暂不考虑大文件， 按需添加
/// 2. 如果用户系统无法提供改目录的处理方式
/// database
/// keyfile
/// user assets => api : png => binary
class FileUtils {
  static Future<Directory?> _handleDirType(DirType? type, [String? customDir]) async {
    if (type == null) return null;

    switch (type) {
      case DirType.appDoc:
        return await getApplicationDocumentsDirectory();

      case DirType.appSupport:
        return await getApplicationSupportDirectory();

      case DirType.temporary:
        return await getTemporaryDirectory();

      case DirType.custom:
        if (customDir != null) {
          return Directory(customDir);
        } else {
          throw ArgumentError("'customDir' cannot be null when using DirType.custom");
        }
    }
  }

  /// 根据指定目录获取[File]
  /// - filename: 全路径名称或文件名
  /// - type: 目录类型
  static Future<File> getFile(String filename, [DirType? type, String? customDir]) async {
    if (filename.contains('/') || filename.contains('\\')) {
      if (customDir != null) {
        throw 'How is the file name a full path, then customDir must be empty.';
      }
      return File(filename);
    }

    if (type == null) {
      throw 'If filename is fullname, the parameter type is unnecessary.';
    }
    final dir = await _handleDirType(type, customDir);
    return File(path.join(dir!.path, filename));
  }

  static Future<Directory?> getDirectory(String sub, DirType type, [bool force = true, String? customDir]) async {
    try {
      final parent = await _handleDirType(type, customDir);
      final dir = Directory(path.join(parent!.path, sub));
      final exists = await dir.exists();
      if (exists) {
        return dir;
      } else {
        if (force) {
          return await dir.create(recursive: true);
        }
      }
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 读取文件内容
  /// 一次性读取文件中内容，以String类型返回
  static Future<String?> readFileAsString(String filename, {DirType? type, String? customDir}) async {
    try {
      final file = await getFile(filename, type, customDir);
      return await file.readAsString();
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 读取文件内容
  /// 一次性读取文件中内容，以Uint8List类型返回
  static Future<Uint8List?> readFileAsBinary(
    String filename, {
    DirType type = DirType.appDoc,
    String? customDir,
  }) async {
    try {
      final file = await getFile(filename, type, customDir);
      return await file.readAsBytes();
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 以Json数据写入到指定文件 当文件不存在时会自动创建
  static Future<File?> writeJsonToFile({
    required Object jsonData,
    required String filename,
    DirType? type,
    String? customDir,
  }) async {
    try {
      final file = await getFile(filename, type, customDir);
      return await file.writeAsString(json.encode(jsonData));
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 以String数据写入到指定文件 当文件不存在时会自动创建
  static Future<File?> writeStringToFile({
    required String data,
    required String filename,
    DirType? type,
    String? customDir,
  }) async {
    try {
      final file = await getFile(filename, type, customDir);
      return await file.writeAsString(data);
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 以bytes数据写入到指定文件 当文件不存在时会自动创建
  static Future<File?> writeBytesToFile({
    required Uint8List data,
    required String filename,
    DirType? type,
    String? customDir,
  }) async {
    try {
      final file = await getFile(filename, type, customDir);
      return await file.writeAsBytes(data);
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 使用isolate来保存二进制数据到文件
  static void writeBytesToFileCompute({
    required Uint8List data,
    required String filename,
    DirType? type,
    String? customDir,
  }) {
    compute<List<dynamic>, void>(_writeBytesToFile, [data, filename, type, customDir, RootIsolateToken.instance]);
  }

  /// 清空文件内容
  static Future<bool> clearFileContent(String filename, [DirType type = DirType.appDoc, String? customDir]) async {
    try {
      final file = await getFile(filename, type, customDir);
      // file.writeAsBytesSync([]);
      await file.writeAsBytes([]);
      return true;
    } catch (err) {
      logger.e(err);
    }
    return false;
  }

  /// 删除文件或文件夹
  /// - recursive 是否递归删除
  static Future<bool> deleteFile(
    String filename, [
    bool recursive = false,
    DirType type = DirType.appDoc,
    String? customDir,
  ]) async {
    bool res = false;
    try {
      final file = await getFile(filename, type, customDir);

      file.delete(recursive: recursive).then((val) {
        res = true;
      });
    } catch (err) {
      logger.e(err);
      res = false;
    }
    return res;
  }

  /// 判断文件是否存在
  /// - parentpath为空时，使用 应用程序目录
  static Future<bool> exists(String filename, [DirType type = DirType.appDoc, String? customDir]) async {
    try {
      final file = await getFile(filename, type, customDir);
      return await file.exists();
    } catch (err) {
      logger.e(err);
    }

    return false;
  }

  /// 创建目录
  static Future<Directory?> createDir(String directory, [DirType type = DirType.appDoc, String? customDir]) async {
    try {
      final parent = await _handleDirType(type, customDir);
      final dir = Directory(path.join(parent!.path, directory));

      bool exists = await dir.exists();
      if (exists) {
        throw '目录已经存在';
      }

      return await dir.create();
    } catch (err) {
      logger.e(err);
    }

    return null;
  }
}
