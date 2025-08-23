import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color get lightColor {
    final originalColor = HSLColor.fromColor(this);
    // 亮度增加1.4倍
    final lightness = originalColor.lightness * 1.4;
    // 饱和度增加1.4倍
    final saturation = originalColor.saturation * 1.4;
    return originalColor
        .withLightness(lightness.clamp(0.0, 1.0))
        .withSaturation(saturation.clamp(0.0, 1.0))
        .toColor();
  }
}
