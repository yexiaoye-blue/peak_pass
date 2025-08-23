import 'package:flutter/material.dart';
import 'package:peak_pass/common/constants/storage_key.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/models/unlock_type_model.dart';
import 'package:peak_pass/data/repositories/storage_repository.dart';
import 'package:peak_pass/utils/common_utils.dart';

class StorageServiceUtils {
  static UnlockTypeModel getUnlockModel({
    FileModel? keyfileModel,
    String? password,
    bool touchId = false,
  }) {
    UnlockTypeModel unlockTypeModel = UnlockTypeModel();
    unlockTypeModel.usePassword = password != null && password.isNotEmpty;
    unlockTypeModel.keyfilePath = keyfileModel?.path;
    unlockTypeModel.useTouchId = touchId;

    return unlockTypeModel;
  }

  static void setUnlockMethod({
    required String nameWithoutExtension,
    required UnlockTypeModel value,
  }) {
    StorageRepository.setString(nameWithoutExtension, value.rawValue);
  }

  static UnlockTypeModel? getUnlockMethod(String nameWithoutExtension) {
    try {
      final res = StorageRepository.get<String?>(nameWithoutExtension);
      if (res == null || res.isEmpty) {
        throw 'Cannot found $nameWithoutExtension unlock method.';
      }
      return UnlockTypeModel(res);
    } catch (err) {
      // TODO:添加业务异常系统
      logger.d(err);
    }
    return null;
  }

  static removeUnlockMethod(String nameWithoutExtension) {
    StorageRepository.remove(nameWithoutExtension);
  }

  static void setCustomDbIfNotExists(FileModel model) {
    try {
      final res = getCustomDbModels();
      // 1. 如果获取不到则说明还未创建该条目
      if (res == null) {
        setCustomDbModels([model]);
        return;
      }
      // 2. 存在该key则查看是否已经添加个该用户自定义文件路径, 不存在则添加
      if (!res.contains(model)) {
        res.add(model);
        setCustomDbModels(res);
      }
    } catch (err) {
      logger.e(err);
      throw BusinessException(
        message: 'Failed to storage custom database path: ${model.path}.',
      );
    }
  }

  static void setCustomDbModels(List<FileModel> models) {
    final paths = models.map((model) => model.path).toList();
    StorageRepository.setStringList(StorageKey.customDatabaseDir, paths);
  }

  static List<FileModel>? getCustomDbModels() {
    final paths = StorageRepository.get<List<String>?>(
      StorageKey.customDatabaseDir,
    );
    if (paths != null && paths.isNotEmpty) {
      return paths.map((path) => FileModel(path)).toList();
    }
    return null;
  }

  static List<FileModel>? removeCustomDbModels(List<FileModel> models) {
    try {
      final res = StorageServiceUtils.getCustomDbModels();
      if (res != null && res.isNotEmpty) {
        res.removeWhere(
          (item) => models.any((info) => item.basename == info.basename),
        );
        StorageServiceUtils.setCustomDbModels(res);
      }
      return res;
    } catch (err) {
      logger.e(err);

      throw BusinessException(
        message: 'Failed to remove custom database path.',
      );
    }
  }

  /// 设置上一次打开的文件,用于快速解锁
  static void setLastModifyDbName(String databaseName) {
    StorageRepository.setString(StorageKey.lastOpenedDatabase, databaseName);
  }

  static String? getLastOpenedDbName() =>
      StorageRepository.get<String>(StorageKey.lastOpenedDatabase);

  static String? getThemeMode() =>
      StorageRepository.get<String?>(StorageKey.themeMode);

  static void setThemeMode(String themeMode) {
    if (themeMode != 'dark' && themeMode != 'light') {
      throw BusinessException(message: 'Illegal  ThemeMode value: $themeMode');
    }
    StorageRepository.setString(StorageKey.themeMode, themeMode);
  }

  static void setLocale(Locale locale) {
    StorageRepository.setString(StorageKey.locale, locale.toLanguageTag());
  }

  static Locale? getLocale() {
    final localeStr = StorageRepository.get<String?>(StorageKey.locale);
    if (localeStr == null || localeStr.isEmpty) return null;
    return CommonUtils.fromLanguageTagStr(localeStr);
  }
}
