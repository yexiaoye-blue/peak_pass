import 'dart:io' show File;

class AvatarModel {
  int? presetIconIndex;
  File? file;

  AvatarModel({this.presetIconIndex, this.file});

  factory AvatarModel.fromIndex(int presetIconIndex) =>
      AvatarModel(presetIconIndex: presetIconIndex, file: null);

  factory AvatarModel.fromFile(File file) =>
      AvatarModel(presetIconIndex: null, file: file);

  @override
  String toString() =>
      'AvatarModel(presetIconIndex: $presetIconIndex, file: $file)';

  @override
  bool operator ==(covariant AvatarModel other) {
    if (identical(this, other)) return true;

    return other.presetIconIndex == presetIconIndex && other.file == file;
  }

  @override
  int get hashCode => presetIconIndex.hashCode ^ file.hashCode;
}
