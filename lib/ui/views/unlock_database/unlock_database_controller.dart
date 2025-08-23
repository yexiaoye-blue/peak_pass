import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kdbx/kdbx.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:peak_pass/common/exceptions/biometric_exception.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';

import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/services/biometric_service.dart';
import 'package:peak_pass/data/services/error_handle_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';
import 'package:peak_pass/ui/views/home/home_page.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/file_provider.dart';

class UnlockDatabaseController extends ChangeNotifier {
  UnlockDatabaseController({
    required this.dbFileModel,
    required this.fileProvider,
    required this.kdbxService,
    required this.biometricService,
  }) {
    passwordController = TextEditingController();
    keyfileController = TextEditingController();
    formKey = GlobalKey<FormState>();
    // TODO: biometric初始化时机
    // biometricService.init(dbFileModel.basenameWithoutExtension);
  }

  final FileModel dbFileModel;
  final KdbxService kdbxService;
  final BiometricService biometricService;
  FileProvider fileProvider;

  late final TextEditingController passwordController;
  late final TextEditingController keyfileController;

  late final GlobalKey<FormState> formKey;

  FileModel? keyfileModel;

  bool _usePassword = true;

  /// 是否使用主密码解锁
  bool get usePassword => _usePassword;
  set usePassword(bool value) {
    _usePassword = value;
    notifyListeners();
  }

  bool _useKeyfile = false;

  /// 是否使用keyfile解锁
  bool get useKeyfile => _useKeyfile;
  set useKeyfile(bool value) {
    _useKeyfile = value;
    notifyListeners();
  }

  bool _useBiometric = false;

  /// 是否使用生物识别解锁
  bool get useBiometric => _useBiometric;
  set useBiometric(bool value) {
    _useBiometric = value;
    notifyListeners();
  }

  UnlockDatabaseController update(FileProvider provider) {
    fileProvider = provider;
    return this;
  }

  /// 初始化该数据库对应的解锁方式
  void initUnlockMethod() {
    try {
      final res = fileProvider.getUnlockType(dbFileModel);

      if (res != null) {
        _usePassword = res.usePassword;
        _useKeyfile = res.useKeyfile;
        final keyfilePath = res.keyfilePath;
        if (_useKeyfile && keyfilePath != null) {
          keyfileModel = FileModel(keyfilePath);
          keyfileController.text = keyfileModel!.basenameWithoutExtension;
        }
        _useBiometric = res.useTouchId;
      }
    } catch (err) {
      logger.e(err);
    }
  }

  Future<void> unlockByBiometric(BuildContext context) async {
    final pushReplacementNamed = context.pushReplacementNamed;
    final appLoc = loc(context);
    try {
      // 1. 从biometric storage中根据数据库名称读取以存储的credentials
      final credentials = await biometricService.readCredentials(
        dbFileModel.basenameWithoutExtension,
      );

      // 2. 解锁
      await kdbxService.open(dbModel: dbFileModel, credentials: credentials);

      showToastBottom(appLoc.successfully(appLoc.unlock, appLoc.databases));
      pushReplacementNamed.call(HomePage.routeName);
    } on BiometricException catch (err) {
      ErrorHandlerService.handleBiometricException(appLoc, err);
    } on KdbxInvalidKeyException catch (err) {
      logger.i(err);
      showToastBottom(appLoc.unlockFailed(appLoc.invalidKey));
    } on BusinessException catch (err) {
      ErrorHandlerService.handleBusinessException(appLoc, err);
    } catch (err) {
      showToastBottom(appLoc.unlockFailed(''));
      logger.e(err.toString());
    }
  }

  Future<void> pickKeyfile(BuildContext context) async {
    // 未勾选 keyfile switch那么则不可以点击选择keyfile
    if (!useKeyfile) {
      showToastBottom(loc(context).pleaseOpenUseKeyfileUnlockDatabase);
      return;
    }
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return;
      keyfileModel = FileModel(result.files.single.path!);
      keyfileController.text = keyfileModel!.basenameWithoutExtension;
    } catch (err) {
      showToastBottom('Failed to pick keyfile!');
      logger.e(err);
    }
  }

  Future<void> unlock(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final appLoc = loc(context);
    if (_usePassword == false && _useKeyfile == false) {
      showToastBottom(appLoc.chooseAtLeastOneUnlockingMethod);
      return;
    }

    final loaderOverlay = context.loaderOverlay;
    final pushReplacementNamed = context.pushReplacementNamed;

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      loaderOverlay.show();

      // 1. 生成凭证
      final credentials = await kdbxService.compositeCre(
        keyfileModel: _useKeyfile ? keyfileModel : null,
        password: _usePassword ? passwordController.text.trim() : null,
        biometric: _useBiometric,
      );

      // 2. 解锁数据库
      await kdbxService.open(dbModel: dbFileModel, credentials: credentials);

      // 3. 更新解锁方式
      StorageServiceUtils.setUnlockMethod(
        nameWithoutExtension: dbFileModel.basenameWithoutExtension,
        value: StorageServiceUtils.getUnlockModel(
          keyfileModel: _useKeyfile ? keyfileModel : null,
          password: _usePassword ? passwordController.text.trim() : null,
          touchId: _useBiometric,
        ),
      );

      // 4. 更新最新打开的数据库
      StorageServiceUtils.setLastModifyDbName(
        dbFileModel.basenameWithoutExtension,
      );

      // 5. 使用生物识别, 则休要存储 对应的 key cre
      // 那么就是在每一次打开应该,如果设置了 生物存储,那么就直接弹窗
      if (_useBiometric) {
        // 名称不可重复
        biometricService.writeCredentials(
          dbFileModel.basenameWithoutExtension,
          credentials,
        );
      }

      // 6. 尝试更新用户自定义选择外部的database file
      fileProvider.addUserCustomModelsIfNotExists([dbFileModel]);

      showToastBottom(appLoc.successfully(appLoc.unlock, appLoc.databases));
      pushReplacementNamed.call(HomePage.routeName);
    } on BiometricException catch (err) {
      ErrorHandlerService.handleBiometricException(appLoc, err);
    } on KdbxInvalidKeyException catch (err) {
      logger.i(err);
      showToastBottom(appLoc.unlockFailed(appLoc.invalidKey));
    } on BusinessException catch (err) {
      ErrorHandlerService.handleBusinessException(appLoc, err);
    } catch (err) {
      showToastBottom(appLoc.unlockFailed(''));
      logger.e(err.toString());
    } finally {
      loaderOverlay.hide();
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    keyfileController.dispose();
    super.dispose();
  }
}
