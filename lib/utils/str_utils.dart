import 'package:dart_levenshtein/dart_levenshtein.dart';

class StrUtils {
  const StrUtils._();

  static bool equalsIgnoreCase(String str1, String str2) {
    return str1.trim().toUpperCase() == str2.trim().toUpperCase();
  }

  // 检查字符串是否为空或仅包含空白字符
  static bool isBlank(String? str) {
    return str == null || str.trim().isEmpty;
  }

  // 检查字符串是否非空且包含非空白字符
  static bool isNotBlank(String? str) {
    return !isBlank(str);
  }

  // 将字符串首字母大写
  static String capitalize(String str) {
    if (isBlank(str)) return str;
    return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();
  }

  // 检查字符串是否包含指定子字符串（忽略大小写）
  static bool containsIgnoreCase(String str, String substring) {
    return str.toLowerCase().contains(substring.toLowerCase());
  }

  /// 计算两个字符串的相似度，返回值在0到1之间
  static Future<double> calculateSimilarity(String str1, String str2) async {
    if (str1.isEmpty && str2.isEmpty) return 1.0;
    if (str1.isEmpty || str2.isEmpty) return 0.0;

    // 转换为小写进行比较
    final s1 = str1.toLowerCase();
    final s2 = str2.toLowerCase();

    // 使用编辑距离算法计算相似度
    final distance = await s1.levenshteinDistance(s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;

    return 1.0 - (distance / maxLength);
  }

  /// 判断两个字符串是否匹配（相似度80%以上）
  static Future<bool> isMatch(String str1, String str2) async {
    final similarity = await calculateSimilarity(str1, str2);
    return similarity >= 0.8; // 80%相似度阈值
  }
}
