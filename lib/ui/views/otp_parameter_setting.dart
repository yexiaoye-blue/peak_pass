import 'dart:collection';

import 'package:flutter/material.dart';

class OtpSettingPage extends StatefulWidget {
  const OtpSettingPage({super.key});
  static const String routeName = 'otp-setting';
  static const List<String> list = <String>['SHA1', 'SHA256', 'SHA512'];

  @override
  State<OtpSettingPage> createState() => _OtpSettingPageState();
}

typedef MenuEntry = DropdownMenuEntry<String>;

class _OtpSettingPageState extends State<OtpSettingPage> {
  final List<MenuEntry> menuEntries = UnmodifiableListView<MenuEntry>(
    OtpSettingPage.list.map<MenuEntry>(
      (String name) => MenuEntry(
        value: name,
        label: name,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ),
  );
  String dropdownValue = OtpSettingPage.list.first;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final menuWidth = screenWidth * 0.4;

    // menu anchor 的偏移
    final Offset menuOffset = Offset(screenWidth - menuWidth - 32, 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OTP Parameters',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Algorithm', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            DropdownMenu<String>(
              width: double.infinity,
              initialSelection: dropdownValue,
              menuStyle: MenuStyle(
                fixedSize: WidgetStatePropertyAll(Size.fromWidth(menuWidth)),
                padding: WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                ),
              ),
              alignmentOffset: menuOffset,
              inputDecorationTheme: InputDecorationTheme(
                border: WidgetStateInputBorder.resolveWith((states) {
                  if (states.contains(WidgetState.error)) {
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    );
                  }

                  if (states.contains(WidgetState.focused)) {
                    return OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    );
                  }

                  return OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          DividerTheme.of(context).color ??
                          Colors.grey.shade300,
                    ),
                  );
                }),
              ),

              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  dropdownValue = value!;
                });
              },
              dropdownMenuEntries: menuEntries,
            ),
          ],
        ),
      ),
    );
  }
}
