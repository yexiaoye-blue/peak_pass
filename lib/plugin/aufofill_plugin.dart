import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/constants/kdbx_key_common_ext.dart';
import 'package:peak_pass/data/services/biometric_service.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/str_utils.dart';

class AutofillService {
  static const MethodChannel autofillChannel = MethodChannel(
    'peak_pass_autofill',
  );

  void setupAutofillChannel(
    KdbxService kdbxService,
    BiometricService biometricService,
  ) {
    autofillChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'getAutoFillData':
          final args = call.arguments as Map?;
          logger.d("arguments: $args");
          return getAutofillData(arguments: args, kdbxService: kdbxService);
        case 'isDatabaseUnlocked':
          return checkDatabaseStatus(kdbxService);
      }
    });
  }

  Future<bool> checkDatabaseStatus(KdbxService kdbxService) async {
    logger.d("checkDatabaseStatus: ${kdbxService.initialized}");
    return kdbxService.initialized;
  }

  Future<String> getAutofillData({
    required Map? arguments,
    required KdbxService kdbxService,
  }) async {
    if (!kdbxService.initialized || arguments == null || arguments.isEmpty) {
      logger.d("KdbxService not initialized || arguments is null or empty");
      return "";
    }

    final domain = arguments['domain'] as String?;
    final fullPackageName = arguments['packageName'] as String?;

    String packageName = '';
    if (fullPackageName != null && fullPackageName.contains(".")) {
      packageName = fullPackageName.split(".").last;
    }

    Map<String, String> res = {};

    // 遍历所有条目寻找匹配项
    for (final entry in kdbxService.allEntries) {
      if (entry.stringEntries.isEmpty) continue;
      if (entry.isDirty) continue;

      final titleStr = entry.getString(KdbxKeyCommonExt.title)?.getText();
      final urlStr = entry.getString(KdbxKeyCommonExt.url)?.getText();

      // 只匹配一条
      bool isMatched = false;

      // 1. 先通过 title 与  domain和packageName进行匹配
      if (titleStr != null && titleStr.isNotEmpty) {
        if (domain != null && domain.isNotEmpty) {
          isMatched = await StrUtils.isMatch(titleStr, domain);
        }

        if (!isMatched && packageName.isNotEmpty) {
          isMatched = await StrUtils.isMatch(titleStr, packageName);
        }
      }

      // 2. 如果 title 不匹配，再比较 url 字段
      if (!isMatched && urlStr != null && urlStr.isNotEmpty) {
        if (domain != null && domain.isNotEmpty && !isMatched) {
          isMatched = await StrUtils.isMatch(domain, urlStr);
        }

        if (!isMatched && packageName.isNotEmpty) {
          isMatched = await StrUtils.isMatch(packageName, urlStr);
        }
      }

      // 如果找到匹配项，赋值并终止查询
      if (isMatched) {
        res = genData(entry);
        break;
      }
    }

    final data = JsonEncoder().convert(res);
    logger.d("found entry: $data");
    return data;
  }

  Map<String, String> genData(KdbxEntry entry) {
    return {
      "username": entry.getString(KdbxKeyCommonExt.username)?.getText() ?? '',
      "password": entry.getString(KdbxKeyCommonExt.password)?.getText() ?? '',
      "email": entry.getString(KdbxKeyCommonExt.email)?.getText() ?? '',
    };
  }
}
