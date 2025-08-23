import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/utils/common_utils.dart';

/// 用于 flutter icons data的转换等
class CustomIconUtils {
  const CustomIconUtils._();

  // 自定义标识符
  static const int softwareIconIdentifier = 0x1CAB1CAB; // 预设图标标识符

  // 将 IconData 转换为带标识符的 Uint8List
  static Uint8List encodePresetIcon(IconData iconData) {
    final bytes = Uint8List(8); // 4字节标识符 + 4字节codePoint
    final byteData = ByteData.view(bytes.buffer);

    // 写入标识符
    byteData.setUint32(0, softwareIconIdentifier, Endian.little);
    // 写入codePoint
    byteData.setUint32(4, iconData.codePoint, Endian.little);

    return bytes;
  }

  // 检查数据类型
  static bool isSoftwareIcon(Uint8List data) {
    // 检查数据长度是否足够
    if (data.length < 8) {
      return false;
    }

    try {
      final identifier = ByteData.view(data.buffer).getUint32(0, Endian.little);
      return identifier == softwareIconIdentifier;
    } catch (e) {
      // 处理可能的异常情况
      return false;
    }
  }

  // 从带标识符的数据中提取 IconData
  static IconData? decodePresetIcon(Uint8List data) {
    // 验证数据长度
    if (data.length != 8) return null;

    try {
      final identifier = ByteData.view(data.buffer).getUint32(0, Endian.little);
      if (identifier != softwareIconIdentifier) return null;

      final codePoint = ByteData.view(data.buffer).getUint32(4, Endian.little);
      // TODO: 这里将预设图标固定,减小应用体积
      // This application cannot tree shake icons fonts. It has non-constant instances of IconData at the following locations:
      //   - file:///D:/FlutterWorkspace/peak_pass/lib/utils/custom_icon_utils.dart:53:14
      // Target aot_android_asset_bundle failed: Error: Avoid non-constant invocations of IconData or try to build again with --no-tree-shake-icons.
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    } catch (e) {
      // 处理可能的异常情况
      return null;
    }
  }

  /// 渲染的时候 根据 type + 对应类型的值! 即可
  static IconModel getIconModelByEntry(KdbxEntry entry) {
    return getIconModel(entry.icon.get(), entry.customIcon);
  }

  static IconModel getIconModel(
    KdbxIcon? kdbxIcon,
    KdbxCustomIcon? customIcon,
  ) {
    // 1. 系统预设的icon , 并且保证preset的时候 该IconModel的kdbxIcon一定有值
    if (customIcon == null || customIcon.data.isEmpty) {
      // final index = kdbxIcon?.index ?? KdbxIcon.Key.index;

      return IconModel(
        type: IconModelType.kdbxPreset,
        kdbxIndex: kdbxIcon!.index,
      );
    }

    try {
      // 2. 系统预设
      final isSoftWareIcon = CustomIconUtils.isSoftwareIcon(customIcon.data);
      if (isSoftWareIcon) {
        return IconModel(
          type: IconModelType.softwarePreset,
          bytes: customIcon.data,
        );
      }
    } catch (err) {
      logger.e(err);
    }

    // 3. 用户自定义
    return IconModel(type: IconModelType.userCustom, bytes: customIcon.data);
  }
}
