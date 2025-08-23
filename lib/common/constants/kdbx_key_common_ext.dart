import 'package:kdbx/kdbx.dart';

/// 对 [KdbxKeyCommon]中预设key的增加
/// 请直接使用该类作为预设key
class KdbxKeyCommonExt {
  const KdbxKeyCommonExt._();

  static const keyTitle = KdbxKeyCommon.KEY_TITLE;
  static const keyUrl = KdbxKeyCommon.KEY_URL;
  static const keyUsername = KdbxKeyCommon.KEY_USER_NAME;
  static const keyPassword = KdbxKeyCommon.KEY_PASSWORD;
  static const keyOtp = KdbxKeyCommon.KEY_OTP;

  static const String keyEmail = 'Email';
  static const String keyNotes = 'Notes';
  static const String keyDatetime = 'DateTime';
  static const String keyNumber = 'Number';
  static const String keyPhone = 'Phone';

  static const KdbxKey title = KdbxKeyCommon.TITLE;
  static const KdbxKey url = KdbxKeyCommon.URL;
  static const KdbxKey username = KdbxKeyCommon.USER_NAME;
  static const KdbxKey password = KdbxKeyCommon.PASSWORD;
  static const KdbxKey otp = KdbxKeyCommon.OTP;

  static final KdbxKey email = KdbxKey(keyEmail);
  static final KdbxKey notes = KdbxKey(keyNotes);
  static final KdbxKey datetime = KdbxKey(keyDatetime);
  static final KdbxKey number = KdbxKey(keyNumber);
  static final KdbxKey phone = KdbxKey(keyPhone);
}
