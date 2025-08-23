import 'dart:math';

import '../common/constants/char_set.dart';

/// [Random Password Generator]

class PasswordUtils {
  /// 生成密码
  ///
  /// [digits] 指定密码总长度，
  /// [includeUppercase] 是否必须包含大写字母，
  /// [includeLowercase] 是否必须包含小写字母，
  /// [includeNumbers] 是否必须包含数字，
  /// [includeSymbols] 是否必须包含特殊字符。
  ///
  /// 如果所有的选项都未开启，则默认使用 char_set.dart 中定义的 customCharSet 生成密码。
  static String randomPassword2({
    double passwordLength = 8,
    bool letters = true,
    bool uppercase = false,
    bool numbers = false,
    bool specialChar = false,
    bool withoutConfusion = false,
  }) {
    // 保存所有可用的字符
    List<String> availableChars = [];
    // 用于保存每个必须包含的字符
    List<String> mandatoryChars = [];

    final rand = Random.secure();

    if (letters == false && uppercase == false && specialChar == false && numbers == false) {
      letters = true;
    }

    // 如果选择包含小写字母
    if (letters) {
      final tmp = withoutConfusion ? CharacterSet.lowercaseNoConfusion : CharacterSet.lowercase;
      availableChars.addAll(tmp.split(''));
      mandatoryChars.add(tmp[rand.nextInt(tmp.length)]);
    }

    // 如果选择包含大写字母，则从大写字符集中随机选一个添加到必选列表，并加入整体字符集中
    if (uppercase) {
      final tmp = withoutConfusion ? CharacterSet.uppercaseNoConfusion : CharacterSet.uppercase;
      availableChars.addAll(tmp.split(''));
      mandatoryChars.add(tmp[rand.nextInt(tmp.length)]);
    }

    // 如果选择包含数字
    if (numbers) {
      final tmp = withoutConfusion ? CharacterSet.digitsNoConfusion : CharacterSet.digits;
      availableChars.addAll(tmp.split(''));
      mandatoryChars.add(tmp[rand.nextInt(tmp.length)]);
    }

    // 如果选择包含特殊符号
    if (specialChar) {
      availableChars.addAll(CharacterSet.specialCharacter.split(''));
      mandatoryChars.add(
        CharacterSet.specialCharacter[rand.nextInt(CharacterSet.specialCharacter.length)],
      );
    }

    // 检查长度是否足够，至少需要满足 mandatoryChars 的数量
    if (passwordLength < mandatoryChars.length) {
      throw ArgumentError(
        'The password length cannot be less than the number of required character categories (${mandatoryChars.length})',
      );
    }

    // 初始化密码字符列表，先加入必选字符
    List<String> passwordChars = List.from(mandatoryChars);

    // 剩余的字符随机选自全部可用字符
    for (int i = mandatoryChars.length; i < passwordLength; i++) {
      passwordChars.add(availableChars[rand.nextInt(availableChars.length)]);
    }

    // 随机打乱密码字符顺序，避免必选字符总是在前几个位置
    passwordChars.shuffle(rand);

    return passwordChars.join('');
  }

  /// check password strong and return double value [0-1] input string [password]
  /// From random_password_generator: ^0.2.1
  static double checkPassword({required String password}) {
    /// if [password] is empty return 0.0
    if (password.isEmpty) return 0.0;

    double bonus;
    if (RegExp(r'^[a-z]*$').hasMatch(password)) {
      bonus = 1.0;
    } else if (RegExp(r'^[a-z0-9]*$').hasMatch(password)) {
      bonus = 1.2;
    } else if (RegExp(r'^[a-zA-Z]*$').hasMatch(password)) {
      bonus = 1.3;
    } else if (RegExp(r'^[a-z\-_!?]*$').hasMatch(password)) {
      bonus = 1.3;
    } else if (RegExp(r'^[a-zA-Z0-9]*$').hasMatch(password)) {
      bonus = 1.5;
    } else {
      bonus = 1.8;
    }

    /// return double value [0-1]
    logistic(double x) => 1.0 / (1.0 + exp(-x));

    /// return double value [0-1]
    curve(double x) => logistic((x / 3.0) - 4.0);

    /// return double value [0-1]
    return curve(password.length * bonus);
  }
}
