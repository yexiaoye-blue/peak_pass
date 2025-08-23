import 'package:kdbx/kdbx.dart';

class DatabaseModel {
  final KdbxFile kdbxFile;

  /// groups获取的当前group其下的group, entries同理
  DatabaseModel(this.kdbxFile);

  KdbxMeta get meta => kdbxFile.body.meta;
  Credentials get credentials => kdbxFile.credentials;
  KdbxBody get body => kdbxFile.body;
  KdbxGroup get rootGroup => kdbxFile.body.rootGroup;

  /// 去除掉rootGroup
  List<KdbxGroup> get allGroups =>
      kdbxFile.body.rootGroup
          .getAllGroups()
          .where((group) => group != rootGroup)
          .toList();
  List<KdbxEntry> get allEntries => kdbxFile.body.rootGroup.getAllEntries();

  @override
  String toString() {
    return 'DatabaseModel{databaseName: ${meta.databaseName.name}, kdbxFile: $kdbxFile}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatabaseModel &&
          runtimeType == other.runtimeType &&
          kdbxFile == other.kdbxFile;

  @override
  int get hashCode => kdbxFile.hashCode;
}
