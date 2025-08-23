import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  final double extent;
  final bool isHorizontal;

  // 主构造函数改为 const
  const Gap._({required this.extent, required this.isHorizontal}) : super();

  // 工厂构造函数改为 const 命名构造函数
  const Gap.vertical(double extent)
    : this._(extent: extent, isHorizontal: false);

  const Gap.horizontal(double extent)
    : this._(extent: extent, isHorizontal: true);

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? SizedBox(width: extent) : SizedBox(height: extent);
  }
}
