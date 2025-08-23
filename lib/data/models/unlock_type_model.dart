import 'package:peak_pass/common/constants/storage_key.dart';

/// 解锁方式
class UnlockTypeModel {
  /// 格式: UNLOCK_BY_PWD|UNLOCK_BY_KEYFILE(/path/to/keyfile.key)|UNLOCK_BY_TOUCH_ID
  String rawValue;

  bool get usePassword => rawValue.contains(StorageKey.unlockByPwd);
  bool get useKeyfile => rawValue.contains(StorageKey.unlockByKeyfile);
  bool get useTouchId => rawValue.contains(StorageKey.unlockByTouchId);

  String? get keyfilePath {
    final escapedKey = RegExp.escape(StorageKey.unlockByKeyfile);
    final regex = RegExp('$escapedKey\\((.*?)\\)');
    final match = regex.firstMatch(rawValue);
    return match?.group(1);
  }

  // 修复：允许空字符串初始化
  UnlockTypeModel([this.rawValue = '']);

  factory UnlockTypeModel.create({
    required bool usePassword,
    String? keyfilePath,
    required bool useTouchId,
  }) {
    final List<String> parts = [];

    if (usePassword) {
      parts.add(StorageKey.unlockByPwd);
    }
    if (keyfilePath != null) {
      parts.add('${StorageKey.unlockByKeyfile}($keyfilePath)');
    }
    if (useTouchId) {
      parts.add(StorageKey.unlockByTouchId);
    }

    return UnlockTypeModel(parts.join('|'));
  }

  set usePassword(bool value) => _setValue(value, StorageKey.unlockByPwd, null);
  set useTouchId(bool value) =>
      _setValue(value, StorageKey.unlockByTouchId, null);

  /// 设置keyfile路径，同时控制是否使用keyfile
  /// 如果path为null，则不使用keyfile
  set keyfilePath(String? path) =>
      _setValue(path != null, StorageKey.unlockByKeyfile, path);

  void _setValue(bool value, String key, String? extra) {
    final parts = rawValue.split('|').where((part) => part.isNotEmpty).toList();

    // 移除旧的keyfile项（无论是否带路径）
    if (key == StorageKey.unlockByKeyfile) {
      parts.removeWhere((part) => part.startsWith('${key}(') || part == key);
    } else {
      // 移除指定的项
      parts.remove(key);
    }

    // 如果是keyfile且有路径，则特殊处理
    if (key == StorageKey.unlockByKeyfile && value && extra != null) {
      parts.add('$key($extra)');
    } else if (value) {
      // 普通布尔值设置
      parts.add(key);
    }

    rawValue = parts.join('|');
  }

  /// 创建更新后的副本
  UnlockTypeModel copyWith({
    bool? usePassword,
    String? keyfilePath,
    bool? useTouchId,
  }) {
    return UnlockTypeModel.create(
      usePassword: usePassword ?? this.usePassword,
      keyfilePath: keyfilePath ?? this.keyfilePath,
      useTouchId: useTouchId ?? this.useTouchId,
    );
  }

  @override
  String toString() {
    return 'UnlockTypeModel(rawValue: $rawValue)';
  }
}
