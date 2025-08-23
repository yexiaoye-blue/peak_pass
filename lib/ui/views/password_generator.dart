import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/ui/widgets/headline.dart';
import 'package:peak_pass/ui/widgets/p_button.dart';
import 'package:peak_pass/ui/widgets/p_card_container.dart';
import 'package:peak_pass/ui/widgets/p_list_tile_style1.dart';
import 'package:peak_pass/ui/widgets/password_rich_text.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/utils/password_utils.dart';

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key, this.isPopResult = false});

  static const String routeName = 'password-generator';
  static const int maxPasswordLength = 32;
  static const int minPasswordLength = 3;

  /// 这个用于在直接进入密码生成器页面时 FAB显示为copy,
  /// 请在路由 extra 中传入
  final bool isPopResult;

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  bool _uppercase = true;
  bool _lowercase = true;
  bool _digits = true;
  bool _specialCharacters = true;
  bool _withoutConfusion = false;
  int _passwordLength = 12;

  String _password = '';
  @override
  void initState() {
    super.initState();
    _password = PasswordUtils.randomPassword2(
      letters: _lowercase,
      uppercase: _uppercase,
      numbers: _digits,
      specialChar: _specialCharacters,
      passwordLength: _passwordLength.toDouble(),
      withoutConfusion: _withoutConfusion,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(loc(context).passwordGenerator)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // generator
            PCardContainer(
              child: Column(
                children: [
                  // password
                  SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Center(child: PasswordRichText(text: _password)),
                  ),

                  Divider(),

                  Row(
                    spacing: 12,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PButton(
                        onPressed: () {
                          try {
                            setState(() {
                              _password = PasswordUtils.randomPassword2(
                                letters: _lowercase,
                                uppercase: _uppercase,
                                numbers: _digits,
                                specialChar: _specialCharacters,
                                passwordLength: _passwordLength.toDouble(),
                                withoutConfusion: _withoutConfusion,
                              );
                            });
                          } on ArgumentError catch (err) {
                            showToastBottom(err.message);
                          } catch (err) {
                            logger.e(err);
                          }
                        },
                        icon: Icon(Icons.casino),

                        child: Text(loc(context).generate),
                      ),
                      // copy button
                      FilledButton.tonalIcon(
                        onPressed: () async {},
                        label: Text(loc(context).copy),
                        icon: Icon(Icons.copy),
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Password length
            Gap.vertical(16),
            Headline(loc(context).passwordLength(_passwordLength)),
            Gap.vertical(8),
            PCardContainer(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_passwordLength ==
                          PasswordGeneratorPage.minPasswordLength) {
                        return;
                      }
                      setState(() {
                        _passwordLength--;
                      });
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Slider(
                      value: _passwordLength.toDouble(),
                      min: PasswordGeneratorPage.minPasswordLength.toDouble(),
                      max: PasswordGeneratorPage.maxPasswordLength.toDouble(),
                      label: _passwordLength.toString(),
                      onChanged: (val) {
                        setState(() {
                          _passwordLength = val.truncate();
                        });
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_passwordLength ==
                          PasswordGeneratorPage.maxPasswordLength) {
                        return;
                      }
                      setState(() {
                        _passwordLength++;
                      });
                    },
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
            ),

            Gap.vertical(16),
            // Include following
            Headline(loc(context).parameters),
            Gap.vertical(8),
            PCardContainer(
              child: Column(
                children: [
                  PListTileStyle1(
                    title: loc(context).alphabetsLowercase,
                    subtitle: loc(context).alphabetsLowercaseContent,
                    trailing: Switch(
                      value: _lowercase,
                      onChanged: (val) {
                        setState(() {
                          _lowercase = val;
                        });
                      },
                    ),
                  ),
                  PListTileStyle1(
                    title: loc(context).alphabetsUppercase,
                    subtitle: loc(context).alphabetsUppercaseContent,
                    trailing: Switch(
                      value: _uppercase,
                      onChanged: (val) {
                        setState(() {
                          _uppercase = val;
                        });
                      },
                    ),
                  ),
                  PListTileStyle1(
                    title: loc(context).digits,
                    subtitle: loc(context).digitsContent,
                    trailing: Switch(
                      value: _digits,
                      onChanged: (val) {
                        setState(() {
                          _digits = val;
                        });
                      },
                    ),
                  ),

                  PListTileStyle1(
                    onTap: () {},
                    title: loc(context).specialCharacters,
                    // TODO: 使用预定义特殊字符
                    subtitle: loc(context).specialCharactersContent,
                    trailing: Switch(
                      value: _specialCharacters,
                      onChanged: (val) {
                        setState(() {
                          _specialCharacters = val;
                        });
                      },
                    ),
                  ),
                  PListTileStyle1(
                    onTap: () {},
                    title: loc(context).withoutConfusion,
                    subtitle: loc(context).withoutConfusionContent,
                    showDivider: false,
                    trailing: Switch(
                      value: _withoutConfusion,
                      onChanged: (val) {
                        setState(() {
                          _withoutConfusion = val;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final appLoc = loc(context);
          if (widget.isPopResult) {
            context.pop(_password);
          } else {
            copyToClipboard(_password)
                .then((res) {
                  showToastBottom(appLoc.successfully(appLoc.copy, ''));
                })
                .catchError((err) {
                  showToastBottom(appLoc.successfully(appLoc.copy, ''));
                  logger.e(err);
                });
          }
        },
        child: Icon(widget.isPopResult ? Icons.done : Icons.copy),
      ),
    );
  }
}
