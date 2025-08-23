import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/utils/custom_icon_utils.dart';

enum IconModelType {
  userCustom, // 用户自定义图标 (文件路径)
  kdbxPreset, // KDBX 预设图标 (KdbxIcon)
  softwarePreset, // 软件预设图标 (IconData 编码为 bytes)
}

/// userCustom: path一定有值, 先尝试读取 bytes, bytes没有值通过 path readAsBytes
/// kdbxPreset: kdbxIndex一定有值. 通过 [KdbxIcon.values[kdbxIndex]] 获取
/// softwarePreset: iconData一有值. 它实际的存储也是在bytes中
class IconModel {
  final IconModelType type;
  final String? path; // 用户自定义图标的文件路径
  final int? kdbxIndex; // KDBX 预设图标的索引
  Uint8List? bytes; // 软件预设图标的编码数据或用户图标的字节数据

  IconModel({required this.type, this.path, this.kdbxIndex, this.bytes});

  // 创建用户自定义图标模型
  static IconModel createUserCustom(String path) {
    return IconModel(type: IconModelType.userCustom, path: path);
  }

  // 创建 KDBX 预设图标模型
  static IconModel createKdbxPreset(int index) {
    return IconModel(type: IconModelType.kdbxPreset, kdbxIndex: index);
  }

  // 创建软件预设图标模型
  static IconModel createSoftwarePreset(IconData iconData) {
    final bytes = CustomIconUtils.encodePresetIcon(iconData);
    return IconModel(type: IconModelType.softwarePreset, bytes: bytes);
  }

  // 获取对应的 IconData (仅对软件预设图标有效)
  IconData? get iconData {
    if (type == IconModelType.softwarePreset && bytes != null) {
      return CustomIconUtils.decodePresetIcon(bytes!);
    }
    return null;
  }

  // 获取 KdbxIcon (仅对 KDBX 预设图标有效)
  KdbxIcon? get kdbxIcon {
    if (type == IconModelType.kdbxPreset && kdbxIndex != null) {
      if (kdbxIndex! >= 0 && kdbxIndex! < KdbxIcon.values.length) {
        return KdbxIcon.values[kdbxIndex!];
      }
    }
    return null;
  }

  // 检查是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IconModel) return false;

    return type == other.type &&
        path == other.path &&
        kdbxIndex == other.kdbxIndex &&
        bytes == other.bytes;
  }

  @override
  int get hashCode => Object.hash(type, path, kdbxIndex, bytes);
}
