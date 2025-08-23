import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:path/path.dart' as path;

class ImageUtils {
  static Future<XFile?> pickImage() async {
    try {
      return await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxHeight: 120,
        maxWidth: 120,
        requestFullMetadata: false,
      );
    } catch (err) {
      logger.e(err);
    }
    return null;
  }

  /// 存储到 getApplicationDocumentsDirectory()/user_assets/icons/xxx
  /// 文件以时间戳重命名
  /// return 存储的全路径
  static Future<String?> saveTo(XFile file, Directory targetDir) async {
    try {
      // final iconRootDir = await AppPathManager.userAssetsIconDir;

      final fileName = path.setExtension(
        DateTime.now().millisecondsSinceEpoch.toString(),
        path.extension(file.name),
      );
      final userAssetsIconPath = path.join(targetDir.path, fileName);

      await file.saveTo(userAssetsIconPath);
      return userAssetsIconPath;
    } catch (err) {
      logger.e(err);
    }
    return null;
  }
}
