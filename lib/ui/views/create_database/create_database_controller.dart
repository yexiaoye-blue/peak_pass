import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:peak_pass/common/constants/path_key.dart';
import 'package:peak_pass/common/exceptions/biometric_exception.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/services/app_path_manager.dart';
import 'package:peak_pass/data/services/biometric_service.dart';
import 'package:peak_pass/data/services/error_handle_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';
import 'package:peak_pass/ui/views/create_database/keyfile_bottom_sheet.dart';
import 'package:peak_pass/ui/views/home/home_page.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';

class CreateDatabaseController extends ChangeNotifier {
  CreateDatabaseController({
    required this.kdbxService,
    required this.biometricService,
  }) {
    nameController = TextEditingController();
    passwordController = TextEditingController();
    pwdConfirmController = TextEditingController();
    keyfileController = TextEditingController();
    formKey = GlobalKey<FormState>();
  }
  final KdbxService kdbxService;
  final BiometricService biometricService;

  late final GlobalKey<FormState> formKey;
  late final TextEditingController nameController;
  late final TextEditingController passwordController;
  late final TextEditingController pwdConfirmController;
  late final TextEditingController keyfileController;

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

  Future<void> chooseKeyfile(BuildContext context) async {
    if (!_useKeyfile) {
      showToastBottom(loc(context).pleaseOpenUseKeyfileUnlockDatabase);
      return;
    }

    keyfileModel = await KeyfileBottomSheet.show(context);
    if (keyfileModel != null) {
      keyfileController.text = keyfileModel!.basenameWithoutExtension;
    }
  }

  Future<void> createDatabase(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final pushReplacementNamed = context.pushReplacementNamed;
    final appLoc = loc(context);

    String databaseName = nameController.text.trim();

    final appPathManager = Provider.of<AppPathManager>(context, listen: false);

    try {
      final dbPath = await appPathManager.dbDir;
      final fullPath = p.setExtension(
        p.join(dbPath.path, databaseName),
        PathKey.databaseExtension,
      );
      final credentials = await kdbxService.compositeCre(
        keyfileModel: useKeyfile ? keyfileModel : null,
        password: usePassword ? passwordController.text.trim() : null,
        biometric: useBiometric,
      );
      await kdbxService.createDatabase(
        dbModel: FileModel(fullPath),
        credentials: credentials,
      );

      // 3. 更新解锁方式
      StorageServiceUtils.setUnlockMethod(
        nameWithoutExtension: databaseName,
        value: StorageServiceUtils.getUnlockModel(
          keyfileModel: useKeyfile ? keyfileModel : null,
          password: usePassword ? passwordController.text.trim() : null,
          touchId: useBiometric,
        ),
      );

      // 4. 更新最新打开的数据库
      StorageServiceUtils.setLastModifyDbName(databaseName);

      //5.  使用生物识别, 则休要存储 对应的 key cre
      // 那么就是在每一次打开应该,如果设置了 生物存储,那么就直接弹窗
      if (useBiometric) {
        // 名称不可重复
        await biometricService.writeCredentials(databaseName, credentials);
      }

      showToastBottom(appLoc.successfully(appLoc.create, appLoc.databases));

      pushReplacementNamed.call(HomePage.routeName);
    } on BiometricException catch (err) {
      logger.e(err);
      ErrorHandlerService.handleBiometricException(appLoc, err);
    } on BusinessException catch (err) {
      logger.e(err);
      showToastBottom(err.message);
    } catch (err) {
      logger.e(err);
      showToastBottom(appLoc.failed(appLoc.create, appLoc.databases));
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    pwdConfirmController.dispose();
    keyfileController.dispose();
    super.dispose();
  }
}
