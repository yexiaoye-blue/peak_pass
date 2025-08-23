import 'dart:io';
import 'package:path/path.dart' as p;

class FileModel {
  final String path;
  FileModel(this.path);

  File get file => File(path);
  String get basename => p.basename(path);
  String get basenameWithoutExtension => p.basenameWithoutExtension(path);
  String get extension => p.extension(path);
  String get dirname => p.dirname(path);

  @override
  String toString() => 'FileModel{path: $path}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileModel &&
          runtimeType == other.runtimeType &&
          path == other.path;

  @override
  int get hashCode => path.hashCode;
}
