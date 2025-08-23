import 'dart:io';
import 'package:flutter/material.dart';
import 'package:peak_pass/common/constants/preset_icons.dart';
import 'package:peak_pass/data/models/icon_model.dart';

/// 获取圆形Avatar
Widget getAvatar(
  IconModel iconModel,
  BuildContext context, [
  Color? iconColor,
]) {
  return _prettifyLogo(
    context: context,
    dimension: 62,
    radius: 31,
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    child: getOriginalIcon(iconModel, iconColor),
  );
}

// TODO: 统一图标构建

/// 获取圆形Avatar
Widget getAvatarWithProperty({
  required BuildContext context,
  required IconModel iconModel,
  required double dimension,
  required Color? backgroundColor,
  Color? iconColor,
}) {
  return _prettifyLogo(
    context: context,
    dimension: dimension,
    radius: dimension / 2,
    backgroundColor: backgroundColor,
    child: getOriginalIcon(iconModel, iconColor),
  );
}

/// 获取带有样式的Icon
Widget getIcon(IconModel model, BuildContext context, [Color? iconColor]) {
  return _prettifyLogo(
    context: context,
    dimension: 46,
    radius: 12,
    child: getOriginalIcon(model, iconColor),
  );
}

/// 获取原始Icon
Widget getOriginalIcon(IconModel model, [Color? iconColor]) {
  if (model.type == IconModelType.kdbxPreset) {
    // 没有直接使用 bytes解析的原因是:
    // 由于 KdbxIcon.values.index 这里预设[PresetIcons]了对应的 IconData
    return Icon(PresetIcons.values[model.kdbxIndex!].icon, color: iconColor);
  }
  if (model.type == IconModelType.softwarePreset) {
    return Icon(model.iconData, color: iconColor);
  }

  if (model.bytes != null) {
    return Image.memory(model.bytes!);
  }

  return FutureBuilder(
    future: File(model.path!).readAsBytes(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return Image.memory(snapshot.data!);
      }
      if (snapshot.hasError) {
        return Icon(Icons.folder, color: iconColor);
      }
      return Center(child: CircularProgressIndicator(strokeWidth: 1));
    },
  );
}

Widget _prettifyLogo({
  required BuildContext context,
  required double dimension,
  required double radius,
  required Widget child,
  Color? backgroundColor,
}) {
  return Container(
    width: dimension,
    height: dimension,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Center(child: child),
  );
}
