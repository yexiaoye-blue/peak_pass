import 'package:kdbx/kdbx.dart';

import 'package:peak_pass/data/models/file_model.dart';

/// 对KdbxFile的封装,简化数据获取
class KdbxFileWrapper {
  KdbxFileWrapper({required this.kdbxFile, required this.fileModel});

  /// 实际的 KDBX 文件对象
  final KdbxFile kdbxFile;
  final FileModel fileModel;

  @override
  String toString() =>
      'KdbxFileWrapper(kdbxFile: $kdbxFile, fileModel: $fileModel)';

  @override
  bool operator ==(covariant KdbxFileWrapper other) {
    if (identical(this, other)) return true;

    return other.kdbxFile == kdbxFile && other.fileModel == fileModel;
  }

  @override
  int get hashCode => kdbxFile.hashCode ^ fileModel.hashCode;
}
