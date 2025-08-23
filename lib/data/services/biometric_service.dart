import 'package:base32/base32.dart';
import 'package:biometric_storage/biometric_storage.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/common/exceptions/biometric_exception.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/utils/common_utils.dart';

class BiometricService {
  static const String baseName = "QuickUnlock";

  BiometricStorageFile? _storageFile;

  Future<void> writeCredentials(String dbName, Credentials credentials) async {
    final storageFile = await _getStorageFile(dbName);
    final content = base32.encode(credentials.getHash());
    await storageFile.write(content);
  }

  Future<Credentials> readCredentials(String dbName) async {
    final storageFile = await _getStorageFile(dbName);
    final credHax = await storageFile.read();
    if (credHax == null) {
      throw BusinessException(
        message: '未查询到生物识别存储信息',
        code: BizErrorCode.biometricStorageEmpty,
      );
    }
    final bytes = base32.decode(credHax);
    return Credentials.fromHash(bytes);
  }

  Future<void> deleteCredentials(String dbName) async {
    final storageFile = await _getStorageFile(dbName);
    await storageFile.delete();
  }

  /// 这个初始化的时机应该是:
  /// 解锁: 在获取到解锁方式中存在  biometric解锁之后,直接尝试初始化
  /// 存储: open/create: 设置了biometric解锁后 之后尝试获取并更新
  ///
  Future<BiometricStorageFile> _getStorageFile(String name) async {
    final rawName = '${name}_$baseName';
    if (_storageFile != null && _storageFile!.name == rawName) {
      return _storageFile!;
    }

    final canAuth = await check();
    final supportsAuthenticated = isSupportsAuthenticated(canAuth);
    if (!supportsAuthenticated) {
      logger.e("get storage file failed: $canAuth");
      throw BiometricException(response: canAuth);
    }
    _storageFile = await BiometricStorage().getStorage(
      rawName,
      options: StorageFileInitOptions(),
    );
    return _storageFile!;
  }

  Future<CanAuthenticateResponse> check() async =>
      await BiometricStorage().canAuthenticate();

  // 在options: StorageFileInitOptions中指定是否需要认证
  // authenticationRequired: false 不需要, 否则需要
  bool isSupportsAuthenticated(CanAuthenticateResponse canAuthenticated) =>
      canAuthenticated == CanAuthenticateResponse.success ||
      canAuthenticated == CanAuthenticateResponse.statusUnknown;
}
