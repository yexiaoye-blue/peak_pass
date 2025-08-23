import '../enums/enums.dart';

class CharacterSet {
  const CharacterSet._();
  static final String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static final String uppercaseNoConfusion = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static final String lowercase = 'abcdefghijklmnopqrstuvwxyz';
  static final String lowercaseNoConfusion = 'abcdefghjkmnpqrstuvwxyz';
  static final String digits = '0123456789';
  static final String digitsNoConfusion = '23456789';
  static final String specialCharacter = r'!@#$%^&*_-';
}

class CharTypeSegment {
  final CharacterType type;
  final String value;

  CharTypeSegment(this.type, this.value);

  @override
  String toString() => '$type: $value';
}
