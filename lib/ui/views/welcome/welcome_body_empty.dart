import 'package:flutter/material.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/utils/loc.dart';

/// 本地和用户自定义路径无数据文件时显示的空页面
class WelcomeBodyEmpty extends StatelessWidget {
  const WelcomeBodyEmpty({super.key, required this.isRecycleBin});
  final bool isRecycleBin;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 使用FractionallySizedBox处理由于FloatingButton的存在导致视觉中心偏上问题
        SizedBox(height: screenHeight / 4),
        Icon(
          isRecycleBin
              ? Icons.delete_forever_rounded
              : Icons.folder_off_rounded,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 60,
        ),
        Gap.vertical(6),
        Text(
          isRecycleBin
              ? loc(context).recycleBinIsEmpty
              : loc(context).noDatabaseAvailable,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 24,
          ),
        ),
        Row(),
      ],
    );
  }
}
