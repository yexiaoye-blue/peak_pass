import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/models/unlock_type_model.dart';
import 'package:peak_pass/data/services/impl/local_file_service_impl.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';

import '../utils/common_utils.dart';

/// 所有本地kdbx文件的管理
/// 主要页面包含 WelcomePage, UnlockDatabasePage
class FileProvider extends ChangeNotifier {
  FileProvider._(this._fileService, this._models);

  static Future<FileProvider> create(LocalFileServiceImpl service) async {
    final models = await service.findAll();
    final recycleBinModels = await service.findAll(true);
    final provider = FileProvider._(service, models);
    provider._recycleModels = recycleBinModels;

    // 加载已存在的用户自定义存储路径
    await provider._reloadUserCustomModels();
    return provider;
  }

  final LocalFileServiceImpl _fileService;

  /// 文件列表
  final List<FileModel> _models;
  List<FileModel> get models => UnmodifiableListView(_models);

  final List<FileModel> _userCustomModels = [];

  /// 回收站文件列表
  List<FileModel> _recycleModels = [];
  List<FileModel> get recycleModels => UnmodifiableListView(_recycleModels);
  set recycleModels(List<FileModel> models) {
    _recycleModels = models;
    notifyListeners();
  }

  List<FileModel> getSoftwareModels() => [...models, ...recycleModels];

  /// 回收站页面显示状态
  bool _isRecycleBinPage = false;
  bool get isRecycleBinPage => _isRecycleBinPage;
  set isRecycleBinPage(bool value) {
    _isRecycleBinPage = value;
    // 清空前一个页面的选中状态
    _selectedModels.clear();
    notifyListeners();
  }

  /// 当前选中的文件列表, 以 path为key
  final Set<FileModel> _selectedModels = {};
  Set<FileModel> get selectedModels => _selectedModels;

  /// 目标文件是否被选中
  bool isSelected(FileModel model) => _selectedModels.contains(model);

  /// 当前选中文件的文件名 无后缀
  String get selectedBasenameWithoutExtensions =>
      _selectedModels.map((item) => item.basenameWithoutExtension).join(',');

  /// 切换选中状态
  /// 如果传入models则 切换传入的model的选中状态
  void toggleSelects([List<FileModel>? models]) {
    // 1. 如果 models有值, 则切换 _selectedPaths 中的内容
    if (models != null) {
      for (var model in models) {
        if (_selectedModels.contains(model)) {
          _selectedModels.remove(model);
        } else {
          _selectedModels.add(model);
        }
      }
      notifyListeners();
      return;
    }

    final targetModels = _isRecycleBinPage ? _recycleModels : _models;
    if (_selectedModels.isEmpty) {
      // 2. 如果当前选中为空 则全选
      _selectedModels.addAll(targetModels);
    } else if (_selectedModels.length != targetModels.length) {
      // 3. 添加未选中的
      _selectedModels.addAll(
        targetModels.where((element) => !_selectedModels.contains(element)),
      );
    } else {
      // 3. 取消全选
      _selectedModels.clear();
    }
    notifyListeners();
  }

  /// 清空选中的models
  void clearSelects() {
    _selectedModels.clear();
    notifyListeners();
  }

  Future<void> removeSelectedFile() async {
    if (_selectedModels.isEmpty) return;
    final targetModels = _isRecycleBinPage ? _recycleModels : _models;

    if (_isRecycleBinPage) {
      await _fileService.removeFromRecycleBin(List.of(_selectedModels));
    } else {
      await _fileService.remove(List.of(_selectedModels));
      // 直接尝试移除
      StorageServiceUtils.removeCustomDbModels(List.of(_selectedModels));
    }

    targetModels.removeWhere((model) => _selectedModels.contains(model));
    // 更新回收站项目
    await _reloadRecycleModels();
    notifyListeners();
  }

  UnlockTypeModel? getUnlockType(FileModel model) =>
      _fileService.getDatabaseUnlockMethod(model);

  Future<void> reload() async {
    await _reloadModels();
    await _reloadRecycleModels();
    notifyListeners();
  }

  Future<void> _reloadRecycleModels() async {
    final newRecycleModels = await _fileService.findAll(true);

    if (ListEquality<FileModel>().equals(_recycleModels, newRecycleModels)) {
      return;
    }

    _recycleModels.clear();
    _recycleModels.addAll(newRecycleModels);
  }

  Future<void> _reloadModels() async {
    final newModels = await _fileService.findAll();

    // 添加到 models中
    await _reloadUserCustomModels();
    newModels.addAll(_userCustomModels);

    if (ListEquality<FileModel>().equals(_models, newModels)) {
      return;
    }

    _models.clear();
    _models.addAll(newModels);
  }

  /// 重新加载 存储在share_pre中的用户自定义文件路径
  /// 如果database和recycle bin中包含该项目则判断文件大小是否一致,以确定是否为同一个文件
  Future<void> _reloadUserCustomModels() async {
    _userCustomModels.clear();

    final userCustomModels = StorageServiceUtils.getCustomDbModels();
    if (userCustomModels == null || userCustomModels.isEmpty) {
      return;
    }
    for (var model in userCustomModels) {
      final exists = await _checkUserCustomExists(model);
      if (!exists) {
        _userCustomModels.add(model);
      }
    }
  }

  Future<bool> _checkUserCustomExists(FileModel model) async {
    if (getSoftwareModels().contains(model)) {
      final userCustomStat = await model.file.stat();
      final existsStat =
          await getSoftwareModels()
              .firstWhere((ele) => ele == model)
              .file
              .stat();

      // 判断文件大小是否一致,以确定是否为同一个文件
      return userCustomStat.size != existsStat.size;
    }
    return false;
  }

  /// 从回收恢复数据文件
  /// - models 为null则恢复所有选中的
  /// - models 不为null 恢复传入的
  Future<void> recoverModels([List<FileModel>? models]) async {
    // 虽然已经清空,这里还是做一下是否为回收站项目判断

    // 1. 不在回收站页面则返回
    if (!_isRecycleBinPage) return;
    // 2. 判断是否为回收站项目
    final targetModels = models ?? List.from(_selectedModels);
    for (var model in targetModels) {
      // 任何一个不是回收站项目则抛出异常
      if (!_recycleModels.contains(model)) {
        throw Exception('Not a recycle bin model');
      }
    }

    try {
      final res = await _fileService.recover(targetModels);
      // check 如果已存在是否要报错???
      _models.addAll(res);
      // 从_recycleModels中移除
      _recycleModels.removeWhere((model) => targetModels.contains(model));

      // TODO: 后期重构 如果回收站为空则 取消操作状态, 将 animationController 提到provider中
      if (_recycleModels.isEmpty) {}
      notifyListeners();
    } catch (err) {
      logger.e(err);
      throw BusinessException(message: 'Recover failed.');
    }
  }

  void addUserCustomModelsIfNotExists(List<FileModel> models) {
    for (var model in models) {
      if (!_userCustomModels.contains(model) && !_models.contains(model)) {
        StorageServiceUtils.setCustomDbIfNotExists(model);
        _userCustomModels.add(model);
      }
    }
  }

  void add(FileModel model) {
    _models.add(model);
    notifyListeners();
  }

  void remove(FileModel model) {
    _models.remove(model);
    notifyListeners();
  }

  void update(FileModel model) {
    final index = _models.indexWhere((e) => e == model);
    if (index == -1) return;
    _models[index] = model;
    notifyListeners();
  }

  void clear() {
    _models.clear();
    notifyListeners();
  }
}
