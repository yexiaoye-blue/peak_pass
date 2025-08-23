class RegUtils {
  static String getParentPath(String path) {
    final regex = RegExp(r'^(.*/)[^/]+$');
    final match = regex.firstMatch(path);
    if (match != null) {
      String res = match.group(1)!;
      return res.endsWith('/')
          ? res.substring(0, res.length - 1)
          : res; // 移除末尾多余的斜杠
    }
    return '';
  }

  static String getFileName(String path) {
    final regex = RegExp(r'^.*/([^/]+)$');
    final match = regex.firstMatch(path);
    if (match != null) {
      return match.group(1)!;
    }
    return '';
  }

  static String getFileNameWithoutExtension(String filename) {
    final regex = RegExp(r'/([^/]*)\.[^.]+$');
    final match = regex.firstMatch(filename);
    if (match != null) {
      return match.group(1)!;
    }
    return filename; // 无后缀时返回原名
  }
}
