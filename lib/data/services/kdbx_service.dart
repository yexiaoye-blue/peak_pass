import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/constants/kdbx_key_common_ext.dart';
import 'package:peak_pass/common/constants/preset_groups.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/data/services/file_service.dart';
import 'package:peak_pass/utils/common_utils.dart';

import '../models/kdbx_file_wrapper.dart';

class KdbxService {
  KdbxService(this.fileService);

  bool get initialized => _kdbxWrapper != null;

  KdbxFileWrapper? _kdbxWrapper;
  KdbxFileWrapper get kdbxWrapper {
    if (_kdbxWrapper == null) {
      throw 'Call open or create to complete the wrapper.';
    }
    return _kdbxWrapper!;
  }

  /// 当前数据库对应的解锁方式
  Credentials? credentials;

  // 用该service完成文件的操作(远程/本地)
  final FileService fileService;

  KdbxFile get kdbxFile => kdbxWrapper.kdbxFile;

  /// 数据库名称
  String? get databaseName => kdbxFile.body.meta.databaseName.get();

  /// 文件是否已修改
  bool get isDirty => kdbxFile.isDirty;
  // Set<KdbxObject> get dirtyObjects => kdbxFile.dirtyObjects;

  // Stream<Set<KdbxObject>> get dirtyObjectsChanged =>
  //     kdbxFile.dirtyObjectsChanged;
  Stream<Set<KdbxObject>> get dirtyObjectsChanged =>
      _kdbxWrapper != null
          ? kdbxFile.dirtyObjectsChanged
          : const Stream.empty();

  /// 根组
  KdbxGroup get rootGroup => kdbxFile.body.rootGroup;

  /// 获取回收站分组
  KdbxGroup? get recycleBin => kdbxFile.recycleBin;

  CachedValue<KdbxGroup>? _tempWorkspace;

  /// 临时工作区分组
  KdbxGroup? get tempWorkspace =>
      (_tempWorkspace ??= _findTempWorkspace()).value;

  KdbxGroup getTempWorkspaceOrCreate() =>
      tempWorkspace ?? _createTempWorkspace(rootGroup);

  CachedValue<KdbxGroup> _findTempWorkspace() {
    final group = findGroupByName(PresetGroups.tempWorkspaceName);
    if (group == null) {
      return CachedValue.withNull();
    }
    return CachedValue.withValue(group);
  }

  /// 获取所有条目
  /// 过滤: recycleBinGroup.entries / tempWorkspace.entries
  List<KdbxEntry> get allEntries =>
      rootGroup
          .getAllEntries()
          .where(
            (entry) =>
                !entry.isInRecycleBin() &&
                !getTempWorkspaceOrCreate().entries.contains(entry),
          )
          .toList();

  /// 获取所有组
  /// 过滤: rootGroup / recycleBinGroup / tempWorkspace
  List<KdbxGroup> get allGroups =>
      kdbxFile.body.rootGroup
          .getAllGroups()
          .where(
            (group) =>
                group != recycleBin &&
                group.name.get() != getTempWorkspaceOrCreate().name.get(),
          )
          .toList();

  Future<Credentials> compositeCre({
    FileModel? keyfileModel,
    String? password,
    bool biometric = false,
  }) async {
    if (password == null && keyfileModel == null) {
      throw 'Credentials cannot all be `null`.';
    }

    ProtectedValue? protectedPassword;
    if (password != null && password.isNotEmpty) {
      protectedPassword = ProtectedValue.fromString(password);
    }
    Uint8List? keyfileBytes = await keyfileModel?.file.readAsBytes();

    credentials = Credentials.composite(protectedPassword, keyfileBytes);
    return credentials!;
  }

  Future<KdbxFileWrapper> open({
    required FileModel dbModel,
    // 考虑传入,还是直接使用缓存的
    required Credentials credentials,
  }) async {
    // 确保之前的实例被正确清理
    if (_kdbxWrapper != null) {
      _kdbxWrapper!.kdbxFile.dispose();
      _kdbxWrapper = null;
    }

    final dbBytes = await fileService.read(dbModel);

    final kdbxFile = await KdbxFormat().read(dbBytes, credentials);

    // TODO: 存储该数据库对应的解锁方式
    // StorageServiceUtils.setUnlockMethod(
    //   nameWithoutExtension: dbModel.basenameWithoutExtension,
    //   value: unlockTypeModel,
    // );

    _kdbxWrapper = KdbxFileWrapper(kdbxFile: kdbxFile, fileModel: dbModel);
    // 创建临时工作区分组
    getTempWorkspaceOrCreate();

    return _kdbxWrapper!;
  }

  /// 创建新的数据库
  /// - [otpModel]: 指定路径
  /// - [credentials]: 凭证
  /// - [name]: 数据库名称, 为空则使用[otpModel.basenameWithoutExtension]
  Future<KdbxFileWrapper> createDatabase({
    required FileModel dbModel,
    required Credentials credentials,
    String? name,
  }) async {
    // 确保之前的实例被正确清理
    if (_kdbxWrapper != null) {
      _kdbxWrapper!.kdbxFile.dispose();
      _kdbxWrapper = null;
    }

    // 4. 创建数据库
    final kdbxFile = KdbxFormat().create(
      credentials,
      name ?? dbModel.basenameWithoutExtension,
    );
    // 5. 初始化 kdbx file wrapper
    _kdbxWrapper = KdbxFileWrapper(kdbxFile: kdbxFile, fileModel: dbModel);

    // 6. 添加预设分组
    for (var group in PresetGroups.groupTemplates) {
      final res = createAndAddGroup(rootGroup, group.name);
      // 设置icon
      setIcon(res, group.iconModel);
    }

    // 7. 创建临时工作区分组
    getTempWorkspaceOrCreate();

    // 8. 保存
    await save();

    // 9.  TODO: 存储该数据库对应的解锁方式
    // StorageServiceUtils.setUnlockMethod(
    //   nameWithoutExtension: dbModel.basenameWithoutExtension,
    //   value: unlockTypeModel,
    // );
    return _kdbxWrapper!;
  }

  /// 保存到内存,真正保存操作请调用[save]
  Future<Uint8List> cache() async {
    return await kdbxFile.save();
  }

  /// 保存到文件
  Future<void> save() async {
    await kdbxFile.saveTo((bytes) async {
      return await fileService.write(kdbxWrapper.fileModel, bytes);
    });
  }

  /// 创建临时工作区分组
  /// 用于在新建页面时默认创建的entry/group,添加到该分组,如果用户未保存,则清空该分组
  /// 该分组以及其下所有KdbxObject均不会在页面中显示
  KdbxGroup _createTempWorkspace(KdbxGroup rootGroup) {
    final tempWorkspace = createAndAddGroup(
      rootGroup,
      PresetGroups.tempWorkspaceName,
    );
    tempWorkspace.enableAutoType.set(false);
    tempWorkspace.enableSearching.set(false);
    _tempWorkspace = CachedValue.withValue(tempWorkspace);
    return tempWorkspace;
  }

  /// 新建 entry 时添加默认的 entry
  void _addDefaultField(KdbxEntry entry) {
    entry.setString(KdbxKeyCommonExt.title, PlainValue(''));
    entry.setString(KdbxKeyCommonExt.username, PlainValue(''));
    entry.setString(KdbxKeyCommonExt.password, ProtectedValue.fromString(''));
  }

  /// 创建 keyfile凭证
  KeyFileCredentials createKeyFileCredentials() => KeyFileCredentials.random();

  /// 保存keyfile到指定路径
  Future<void> saveKeyfile(FileModel keyfileModel, Uint8List bytes) =>
      fileService.write(keyfileModel, bytes);

  /// 判断entry是否在rootGroup下
  bool isInRootGroup(KdbxEntry entry) => isInGroupSub(entry, rootGroup);

  bool isInGroupSub(KdbxEntry entry, KdbxGroup group) =>
      group.entries.contains(entry);

  /// 创建并添加条目, 如果不传递则默认创建到 TempWorkspace中
  KdbxEntry createEntry([KdbxGroup? parent, bool addDefault = true]) {
    final group = parent ?? getTempWorkspaceOrCreate();
    final entry = KdbxEntry.create(kdbxFile, group);
    if (addDefault) {
      _addDefaultField(entry);
    }
    return entry;
  }

  /// 添加条目到组
  void addEntryTo(KdbxGroup parent, KdbxEntry entry) {
    parent.addEntry(entry);
  }

  /// 删除条目
  void removeEntry(KdbxEntry entry) {
    kdbxFile.deleteEntry(entry);
  }

  void cleanTempWorkspace() {
    try {
      final tempEntries = getTempWorkspaceOrCreate().entries;
      for (var entry in tempEntries) {
        // TODO: 是否考虑永久删除
        // removePermanently(object)

        removeEntry(entry);
      }
      final tempGroups = getTempWorkspaceOrCreate().groups;
      for (var group in tempGroups) {
        removeGroup(group);
      }
    } catch (err) {
      logger.e(err);
      throw BusinessException(
        message:
            "Internal error: cannot remove item from TempWorkspace(${getTempWorkspaceOrCreate().name.name})",
      );
    }
  }

  /// 考虑是否直接传入String 我们在这里进行判断
  void updateEntry(KdbxEntry entry, KdbxKey key, String value) {
    if (value.isEmpty) return;
    entry.setString(key, _convertValue(MapEntry(key, value)));
  }

  /// 根据传入的数据更新条目
  void updateEntryValues(KdbxEntry entry, Map<KdbxKey, String> values) {
    for (var mapEntry in values.entries) {
      if (mapEntry.value.isEmpty) {
        continue;
      }
      entry.setString(mapEntry.key, _convertValue(mapEntry));
    }
  }

  void setIcon(KdbxObject kdbxObject, IconModel iconModel) {
    if (iconModel.type == IconModelType.kdbxPreset) {
      kdbxObject.icon.set(KdbxIcon.values[iconModel.kdbxIndex!]);
    } else {
      kdbxObject.customIcon = KdbxCustomIcon(
        uuid: KdbxUuid.random(),
        data: iconModel.bytes!,
      );
    }
  }

  StringValue _convertValue(MapEntry<KdbxKey, String> mapEntry) {
    if (mapEntry.key == KdbxKeyCommon.PASSWORD ||
        mapEntry.key == KdbxKeyCommon.OTP) {
      return ProtectedValue.fromString(mapEntry.value);
    }
    return PlainValue(mapEntry.value);
  }

  /// 移动 entry/group到目标分组
  void move(KdbxObject source, KdbxGroup target) {
    kdbxFile.move(source, target);
  }

  /// 创建并添加组
  KdbxGroup createAndAddGroup(KdbxGroup parent, String name) {
    final exists =
        parent.groups.where((group) => group.name.get() == name).firstOrNull;
    if (exists != null) {
      throw 'Group: `$name` already exists.';
    }
    return kdbxFile.createGroup(parent: parent, name: name);
  }

  /// 删除组
  void removeGroup(KdbxGroup group) {
    kdbxFile.deleteGroup(group);
  }

  /// 永久删除对象
  void removePermanently(KdbxObject object) {
    kdbxFile.deletePermanently(object);
  }

  /// 查找条目
  KdbxEntry? findEntryByUuid(String uuid) {
    return kdbxFile.body.rootGroup.getAllEntries().firstWhereOrNull(
      (entry) => entry.uuid.uuid == uuid,
    );
  }

  /// 查找组
  KdbxGroup? findGroupByUuid(String uuid) {
    return kdbxFile.body.rootGroup.getAllGroups().firstWhereOrNull(
      (group) => group.uuid.uuid == uuid,
    );
  }

  KdbxGroup? findGroupByName(String name) {
    return rootGroup.getAllGroups().firstWhereOrNull((group) {
      final res = group.name.get() == name;
      return res;
    });
  }

  /// - [entry]: 要操作的entry
  /// - [strEntry]: entry下要移动的item
  Future<void> moveUp(
    KdbxEntry entry,
    MapEntry<KdbxKey, StringValue?> strEntry,
  ) async {
    final entries = entry.stringEntries.toList();
    final index = entries.indexWhere((e) => e.key == strEntry.key);
    if (index <= 0 || index >= entries.length) return;

    final current = entries[index];
    final prev = entries[index - 1];
    final affectedRange = entries.sublist(index - 1); // 从 prev 开始

    // 构建新的顺序
    final reordered = <MapEntry<KdbxKey, StringValue?>>[];
    for (var item in affectedRange) {
      if (item.key == prev.key) {
        reordered.add(current);
      } else if (item.key == current.key) {
        reordered.add(prev);
      } else {
        reordered.add(item);
      }
    }

    for (var item in affectedRange) {
      entry.removeString(item.key);
    }
    for (var item in reordered) {
      entry.setString(item.key, item.value);
    }
  }

  Future<void> moveDown(
    KdbxEntry entry,
    MapEntry<KdbxKey, StringValue?> strEntry,
  ) async {
    final entries = entry.stringEntries.toList();
    final index = entries.indexWhere((e) => e.key == strEntry.key);
    if (index == -1 || index >= entries.length - 1) return;

    final current = entries[index];
    final next = entries[index + 1];
    final affectedRange = entries.sublist(index); // 从 current 开始

    final reordered = <MapEntry<KdbxKey, StringValue?>>[];
    for (var item in affectedRange) {
      if (item.key == current.key) {
        reordered.add(next);
      } else if (item.key == next.key) {
        reordered.add(current);
      } else {
        reordered.add(item);
      }
    }

    for (var item in affectedRange) {
      entry.removeString(item.key);
    }
    for (var item in reordered) {
      entry.setString(item.key, item.value);
    }
  }

  void close() {
    // 使用 KdbxFile的 dispose 再次打开会报错
    // _kdbxWrapper?.kdbxFile.dispose();
    _kdbxWrapper = null;
    credentials = null;
  }
}
