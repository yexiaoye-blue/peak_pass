import '../common/constants/char_set.dart';
import '../common/enums/enums.dart';

/// 字符工具，用于处理特定字符
class CharacterUtils {
  static final RegExp _uppercaseRegExp = RegExp('^[${CharacterSet.uppercase}]+\$');
  static final RegExp _lowercaseRegExp = RegExp('^[${CharacterSet.uppercase}]+\$');
  static final RegExp _digitsRegExp = RegExp('^[${CharacterSet.digits}]+\$');
  static final RegExp _specialCharRegExp = RegExp('^[${RegExp.escape(CharacterSet.specialCharacter)}]+\$');

  /// 判断字符类型
  static CharacterType getCharSequenceType(String charSequence) {
    if (charSequence.isEmpty) return CharacterType.unknown;

    if (_uppercaseRegExp.hasMatch(charSequence)) return CharacterType.uppercase;
    if (_lowercaseRegExp.hasMatch(charSequence)) return CharacterType.lowercase;
    if (_digitsRegExp.hasMatch(charSequence)) return CharacterType.digits;
    if (_specialCharRegExp.hasMatch(charSequence)) {
      return CharacterType.specialCharacter;
    }

    return CharacterType.unknown;
  }

  /// 按字符类型分割字符串，返回CharTypeSegment列表
  static List<CharTypeSegment> splitByCharacterType(String input) {
    // 这个会匹配到未定义的字符
    final matches = RegExp(
      '([${CharacterSet.uppercase}]+|[${CharacterSet.lowercase}]+|[${CharacterSet.digits}]+|[${RegExp.escape(CharacterSet.specialCharacter)}]+|.)',
      caseSensitive: true,
    ).allMatches(input);

    return matches.map((match) {
      final char = match.group(0)!;
      return CharTypeSegment(getCharSequenceType(char), char);
    }).toList();
  }
}
