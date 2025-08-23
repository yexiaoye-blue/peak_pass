import 'package:flutter/material.dart';

import '../../common/enums/enums.dart';
import '../../utils/character_utils.dart';

class PasswordRichText extends StatelessWidget {
  const PasswordRichText({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 24, fontFamily: 'MonaArgon'),
        children:
            CharacterUtils.splitByCharacterType(text).map((item) {
              switch (item.type) {
                case CharacterType.uppercase || CharacterType.lowercase || CharacterType.unknown:
                  return TextSpan(text: item.value, style: TextStyle(color: Theme.of(context).colorScheme.onSurface));
                case CharacterType.digits:
                  return TextSpan(text: item.value, style: TextStyle(color: Colors.blue));
                case CharacterType.specialCharacter:
                  return TextSpan(text: item.value, style: TextStyle(color: Colors.pink.shade400));
              }
            }).toList(),
      ),
    );
  }
}
