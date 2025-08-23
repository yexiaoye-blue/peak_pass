import 'dart:io';
import 'dart:typed_data';

import 'package:peak_pass/data/models/file_model.dart';

abstract class FileService {
  Future<Uint8List> read(FileModel model);

  /// 保存文件
  Future<FileModel> write(FileModel model, Uint8List bytes);

  /// 移除文件, 至回收站
  Future<void> remove(List<FileModel> models);

  /// 移动文件
  /// - [origin]: 源文件
  /// - [target]: 目标目录
  Future<void> move(FileModel origin, Directory target);

  Future<void> copy(FileModel origin, FileModel target);

  // recover 从回收站恢复
  Future<List<FileModel>> recover(List<FileModel> models);

  /// 从回收站移除
  Future<void> removeFromRecycleBin(List<FileModel> models);

  /// 获取所有数据库
  /// - [recycleBin]: true: 获取回收站项目, false: 获取正常项目
  Future<List<FileModel>> findAll([bool recycleBin = false]);

  /// 根据 数据库名称(xxx.kdbx) 查找
  Future<FileModel?> find(String basename, [bool recycleBin = false]);
}
