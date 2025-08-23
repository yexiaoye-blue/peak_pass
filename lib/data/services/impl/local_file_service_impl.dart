import 'dart:io';
import 'dart:typed_data';

import 'package:peak_pass/common/constants/path_key.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/common/exceptions/file_operation_exception.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/models/unlock_type_model.dart';
import 'package:peak_pass/data/services/app_path_manager.dart';
import 'package:peak_pass/data/services/file_service.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';
import 'package:peak_pass/utils/path_utils.dart';
import 'package:path/path.dart' as p;

/// [FileService] 的实现类，用于处理本地文件操作。
///
/// 该服务提供读取、写入、查找、移动和管理本地文件系统中的数据库文件的方法。
/// 还处理与回收站功能相关的文件操作。
class LocalFileServiceImpl extends FileService {
  LocalFileServiceImpl(this.pathManager);

  late final AppPathManager pathManager;

  /// 读取指定文件的二进制数据内容。
  ///
  /// 从 [model] 表示的文件中读取所有字节，并将其作为 [Uint8List] 返回。
  ///
  /// [model]: 包含文件路径信息的文件模型。
  ///
  /// 返回一个 [Future]，完成后包含文件的字节数据。
  ///
  /// 如果文件读取操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<Uint8List> read(FileModel model) async {
    try {
      return await model.file.readAsBytes();
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'read',
        filePath: model.file.path,
        originalException: e,
        message: 'Failed to read file: ${model.file.path}',
      );
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while reading file: ${e.toString()}',
        code: BizErrorCode.unexpectedReadError,
      );
    }
  }

  /// 将字节数据写入指定文件。
  ///
  /// 将给定的 [bytes] 写入 [model] 表示的文件中。
  /// 如果文件已存在，将被覆盖。
  ///
  /// [model]: 包含文件路径信息的文件模型。
  /// [bytes]: 要写入文件的字节数据。
  ///
  /// 返回一个 [Future]，完成后包含更新的文件模型。
  ///
  /// 如果文件写入操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<FileModel> write(FileModel model, Uint8List bytes) async {
    try {
      await model.file.writeAsBytes(bytes);
      return model;
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'write',
        filePath: model.file.path,
        originalException: e,
        message: 'Failed to write file: ${model.file.path}',
      );
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while writing file: ${e.toString()}',
        code: BizErrorCode.unexpectedWriteError,
      );
    }
  }

  /// 查找具有指定基本名称的数据库文件。
  ///
  /// 在主数据库目录或回收站目录中搜索具有给定 [basename] 的数据库文件。
  ///
  /// [basename]: 要查找的文件的基本名称。必须以数据库扩展名结尾。
  /// [recycleBin]: 是否在回收站目录中搜索。默认为 false（在主数据库目录中搜索）。
  ///
  /// 返回一个 [Future]，完成后包含找到的文件模型，如果未找到匹配的文件则返回 null。
  ///
  /// 如果文件搜索操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<FileModel?> find(String basename, [bool recycleBin = false]) async {
    try {
      final targetDir =
          await (recycleBin ? pathManager.dbRecycleBinDir : pathManager.dbDir);

      if (!basename.endsWith(PathKey.databaseExtension)) {
        return null;
      }

      await for (final entity in targetDir.list()) {
        if (entity.path.endsWith(basename)) {
          return FileModel(entity.path);
        }
      }
      return null;
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'find',
        filePath: basename,
        originalException: e,
        message: 'Failed to find file: $basename',
      );
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while finding file: ${e.toString()}',
        code: BizErrorCode.unexpectedFindError,
      );
    }
  }

  /// 获取数据存储路径中的所有数据库文件。
  ///
  /// 列出主数据库目录或回收站目录中的所有数据库文件。
  ///
  /// [recycleBin]: 是否列出回收站目录中的文件。默认为 false（列出主数据库目录中的文件）。
  ///
  /// 返回一个 [Future]，完成后包含文件模型列表。
  ///
  /// 如果文件列表操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<List<FileModel>> findAll([bool recycleBin = false]) async {
    try {
      final targetDir =
          await (recycleBin ? pathManager.dbRecycleBinDir : pathManager.dbDir);
      final paths = await PathUtils.getAllFilePaths(
        targetDir.path,
        PathUtils.isKdbxFile,
      );
      return paths.map((path) => FileModel(path)).toList();
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'findAll',
        filePath: '',
        originalException: e,
        message: 'Failed to find all files',
      );
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while finding all files: ${e.toString()}',
        code: BizErrorCode.unexpectedFindAllError,
      );
    }
  }

  /// 根据数据库名称获取解锁方法。
  ///
  /// 检索指定数据库文件的解锁方法配置。
  ///
  /// [model]: 数据库文件模型。
  ///
  /// 返回解锁类型模型，如果未找到或发生错误则返回 null。
  UnlockTypeModel? getDatabaseUnlockMethod(FileModel model) {
    try {
      return StorageServiceUtils.getUnlockMethod(
        model.basenameWithoutExtension,
      );
    } catch (e) {
      // 这个方法不抛出异常，只是返回null
      return null;
    }
  }

  /// 将文件移动到回收站。
  /// 如果是用户自定义文件则只执行copy而不移除原文件
  ///
  /// 将指定的文件列表移动到回收站目录。
  ///
  /// [models]: 要移除的文件模型列表。
  ///
  /// 返回一个 [Future]，当所有文件都被移动后完成。
  ///
  /// 如果发生业务错误，则抛出 [BusinessException]。
  /// 如果文件操作失败，则抛出 [FileOperationException]。
  @override
  Future<void> remove(List<FileModel> models) async {
    try {
      if (models.isEmpty) return;

      final recyclerBinDir = await pathManager.dbRecycleBinDir;
      // 移除文件到回收站
      for (final info in models.toList()) {
        /// 检查要操作的文件是否为用户自定义
        if (info.dirname.endsWith(PathKey.databaseDir)) {
          await move(info, recyclerBinDir);
        } else {
          await copy(
            info,
            FileModel(p.join(recyclerBinDir.path, info.basename)),
          );
        }
      }
    } on BusinessException {
      rethrow;
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while removing files: ${e.toString()}',
        code: BizErrorCode.unexpectedRemoveError,
      );
    }
  }

  /// 从回收站中永久删除文件。
  ///
  /// 从回收站中永久移除指定的文件，并清理相关的配置信息。
  ///
  /// [models]: 要永久删除的文件模型列表。
  ///
  /// 返回一个 [Future]，当所有文件都被删除后完成。
  ///
  /// 如果文件删除操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<void> removeFromRecycleBin(List<FileModel> models) async {
    try {
      if (models.isEmpty) return;

      // 1. 根据数据库名称除 shared_pre 中缓存的用户自定义数据库路径
      StorageServiceUtils.removeCustomDbModels(models);

      // 2. 移除 shared_pre中 database对应解锁方式
      for (var info in models.toList()) {
        StorageServiceUtils.removeUnlockMethod(info.basenameWithoutExtension);
      }

      // 3. 真正移除文件
      for (final info in models) {
        await info.file.delete();
      }
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'removeFromRecycleBin',
        filePath: e.path ?? '',
        originalException: e,
        message: 'Failed to remove files from recycle bin',
      );
    } catch (e) {
      throw BusinessException(
        message:
            'Unexpected error while removing files from recycle bin: ${e.toString()}',
        code: BizErrorCode.unexpectedRemoveFromRecycleBinError,
      );
    }
  }

  /// 将文件移动到目标目录。
  ///
  /// 将源文件移动到目标目录。如果目标目录中已存在同名文件，则会重命名。
  ///
  /// [origin]: 源文件模型。
  /// [targetDir]: 目标目录。
  ///
  /// 返回一个 [Future]，当文件被移动后完成。
  ///
  /// 如果文件移动操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<void> move(FileModel origin, Directory targetDir) async {
    try {
      // 检查源文件是否存在
      if (!await origin.file.exists()) {
        throw FileOperationException(
          operation: 'move',
          filePath: origin.file.path,
          message: 'Source file does not exist: ${origin.file.path}',
        );
      }

      // 确保目标目录存在
      if (!await targetDir.exists()) {
        try {
          await targetDir.create(recursive: true);
        } catch (e) {
          throw FileOperationException(
            operation: 'create directory',
            filePath: targetDir.path,
            message: 'Failed to create target directory: ${targetDir.path}',
          );
        }
      }

      String targetPath = await _renameIfExists(
        p.join(targetDir.path, origin.basename),
      );

      try {
        // 尝试使用rename方法，如果在同一文件系统上会更高效
        await origin.file.rename(targetPath);
      } on FileSystemException catch (e) {
        // 如果rename失败，可能是因为跨文件系统，使用copy+delete
        if (e.osError?.errorCode == 18) {
          // EXDEV - Cross-device link
          try {
            await origin.file.copy(targetPath);
            await origin.file.delete();
          } catch (copyDeleteError) {
            // 清理可能创建的部分文件
            final targetFile = File(targetPath);
            if (await targetFile.exists()) {
              try {
                await targetFile.delete();
              } catch (deleteError) {
                // 忽略删除失败
              }
            }

            throw FileOperationException(
              operation: 'copy and delete',
              filePath: origin.file.path,
              originalException:
                  copyDeleteError is FileSystemException
                      ? copyDeleteError
                      : null,
              message: 'Failed to move file across storage devices',
            );
          }
        } else {
          // 其他文件系统错误
          throw FileOperationException(
            operation: 'rename',
            filePath: origin.file.path,
            originalException: e,
          );
        }
      }
    } on BusinessException {
      rethrow; // 重新抛出业务异常
    } catch (e) {
      // 包装其他异常为业务异常
      if (e is FileSystemException) {
        throw FileOperationException(
          operation: 'move',
          filePath: e.path,
          originalException: e,
        );
      } else {
        throw BusinessException(
          message:
              'Unexpected error during file move operation: ${e.toString()}',
          code: BizErrorCode.unexpectedError,
        );
      }
    }
  }

  @override
  Future<void> copy(FileModel origin, FileModel target) async {
    try {
      // 检查源文件是否存在
      if (!await origin.file.exists()) {
        throw FileOperationException(
          operation: 'copy',
          filePath: origin.file.path,
          message: 'Source file does not exist: ${origin.file.path}',
        );
      }

      // 确保目标目录存在 copy 需要检查目录么??
      await origin.file.copy(target.path);
    } catch (e) {
      // 包装其他异常为业务异常
      if (e is FileSystemException) {
        throw FileOperationException(
          operation: 'copy',
          filePath: e.path,
          originalException: e,
        );
      } else {
        throw BusinessException(
          message:
              'Unexpected error during file copy operation: ${e.toString()}',
          code: BizErrorCode.unexpectedError,
        );
      }
    }
  }

  /// 处理目标路径已存在文件的情况。
  ///
  /// 如果目标路径已存在文件，通过在括号中附加计数器生成新的无冲突文件名。
  ///
  /// [path]: 目标文件路径。
  ///
  /// 返回一个 [Future]，完成后包含可用的目标文件路径。
  ///
  /// 如果文件重命名操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  Future<String> _renameIfExists(String path) async {
    try {
      final file = File(path);
      final exists = await file.exists();
      if (exists) {
        final directory = p.dirname(path);
        final fullBasename = p.basenameWithoutExtension(path);
        final extension = p.extension(path);
        int counter = 1;
        String basename = fullBasename;

        // 使用正则表达式匹配类似 filename(1) 这样的格式
        final regex = RegExp(r'^(.*)\((\d+)\)$');
        final match = regex.firstMatch(fullBasename);
        if (match != null) {
          basename = match.group(1)!;
          final existingCounter = int.parse(match.group(2)!);
          counter = existingCounter + 1;
        } else {
          counter = 1;
        }

        // 查找下一个可用的编号
        String newPath;
        do {
          newPath = p.join(directory, '$basename($counter)$extension');
          counter++;
        } while (await File(newPath).exists());

        return newPath;
      }
      return file.path;
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'renameIfExists',
        filePath: path,
        originalException: e,
        message: 'Failed to check or rename file: $path',
      );
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while renaming file: ${e.toString()}',
        code: BizErrorCode.unexpectedRenameError,
      );
    }
  }

  /// 从回收站恢复文件。
  ///
  /// 将指定的文件从回收站移回主数据库目录。
  ///
  /// [models]: 要恢复的文件模型列表。
  ///
  /// 返回一个 [Future]，完成后包含已恢复的文件模型列表。
  ///
  /// 如果文件恢复操作失败，则抛出 [FileOperationException]。
  /// 如果发生意外错误，则抛出 [BusinessException]。
  @override
  Future<List<FileModel>> recover(List<FileModel> models) async {
    try {
      final List<FileModel> res = [];
      final dbDir = await pathManager.dbDir;
      for (var model in models) {
        if (await model.file.exists()) {
          await move(model, dbDir);
          res.add(FileModel(p.join(dbDir.path, model.basename)));
        }
      }
      return res;
    } on FileSystemException catch (e) {
      throw FileOperationException(
        operation: 'recover',
        filePath: '',
        originalException: e,
        message: 'Failed to recover files',
      );
    } catch (e) {
      throw BusinessException(
        message: 'Unexpected error while recovering files: ${e.toString()}',
        code: BizErrorCode.unexpectedRecoverError,
      );
    }
  }
}
