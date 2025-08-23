import 'dart:io';
import 'package:path/path.dart' as p;

extension FilePathExtensions on File {
  String get name => p.basename(path);
  String get nameWithoutExtension => p.basenameWithoutExtension(path);
  String get extension => p.extension(path);
  String get dirname => p.dirname(path);
}
