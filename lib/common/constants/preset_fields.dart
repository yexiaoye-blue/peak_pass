import 'package:flutter/material.dart';
import 'package:kdbx/kdbx.dart';
import 'package:peak_pass/common/constants/kdbx_key_common_ext.dart';

class FieldType {
  final KdbxKey key;
  final IconData icon;
  final TextInputType inputType;
  final int maxLines;

  const FieldType(this.key, this.icon, this.inputType, [this.maxLines = 1]);
}

/// All preset fields type.
/// TODO: 用户添加自定义字段
class PresetFields {
  static final List<FieldType> types = [
    FieldType(
      KdbxKeyCommonExt.title,
      Icons.text_fields_rounded,
      TextInputType.text,
    ),
    FieldType(KdbxKeyCommonExt.username, Icons.person, TextInputType.name),
    FieldType(
      KdbxKeyCommonExt.password,
      Icons.lock,
      TextInputType.visiblePassword,
    ),
    FieldType(KdbxKeyCommonExt.email, Icons.email, TextInputType.emailAddress),
    FieldType(
      KdbxKeyCommonExt.notes,
      Icons.article,
      TextInputType.multiline,
      4,
    ),
    FieldType(KdbxKeyCommonExt.url, Icons.language, TextInputType.url),
    FieldType(
      KdbxKeyCommonExt.datetime,
      Icons.date_range,
      TextInputType.datetime,
    ),
    FieldType(KdbxKeyCommonExt.number, Icons.onetwothree, TextInputType.number),
    FieldType(KdbxKeyCommonExt.phone, Icons.phone, TextInputType.phone),
    FieldType(KdbxKeyCommonExt.otp, Icons.key, TextInputType.number),
  ];

  /// Find [FieldType] by String key.
  static FieldType fromStrKey(String key) => types.singleWhere(
    (field) => field.key.key.toLowerCase() == key.toLowerCase(),
  );

  /// Find [FieldType] by [KdbxKey].
  static FieldType fromKdbxKey(KdbxKey key) =>
      types.singleWhere((field) => field.key == key);

  /// Get [KdbxKey] by String key. The Standard define is in [FieldKey] class.
  static KdbxKey getKdbxKeyByStr(String key) =>
      types.singleWhere((item) => item.key.key == key).key;
}
