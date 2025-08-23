import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StorageRepository {
  static StorageRepository? _service;

  static SharedPreferences? _pref;
  StorageRepository._();

  static Future<StorageRepository> setup() async {
    if (_service == null) {
      /* If service is not initialized */
      final service =
          StorageRepository._(); //Creates a local instance of service

      /* Creates an instance of Shared Preferences*/
      await service._getInstance();

      _service = service;
    }

    /* If service is already created return that */
    return _service!;
  }

  Future<void> _getInstance() async {
    _pref = await SharedPreferences.getInstance();
  }

  ///通过泛型来获取数据
  static T? get<T>(key) {
    var result = _pref?.get(key);
    if (result != null) {
      return result as T;
    }
    return null;
  }

  ///获取JSON
  static Map<String, dynamic>? getJson(key) {
    String? result = _pref?.getString(key);
    if (result != null && result.isNotEmpty) {
      return jsonDecode(result);
    }
    return null;
  }

  ///设置String类型的
  static void setString(key, value) {
    _pref?.setString(key, value);
  }

  ///设置setStringList类型的
  static void setStringList(key, value) {
    _pref?.setStringList(key, value);
  }

  ///设置setBool类型的
  static void setBool(key, value) {
    _pref?.setBool(key, value);
  }

  ///设置setDouble类型的
  static void setDouble(key, value) {
    _pref?.setDouble(key, value);
  }

  ///设置setInt类型的
  static void setInt(key, value) {
    _pref?.setInt(key, value);
  }

  ///存储Json类型的
  static void setJson(key, value) {
    value = jsonEncode(value);
    _pref?.setString(key, value);
  }

  ///清除全部
  static void clean() {
    _pref?.clear();
  }

  ///移除某一个
  static void remove(key) {
    _pref?.remove(key);
  }
}
