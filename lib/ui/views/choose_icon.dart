import 'dart:io';

import 'package:flutter/material.dart';
import 'package:peak_pass/common/global.dart';
import 'package:peak_pass/data/models/icon_model.dart';
import 'package:peak_pass/utils/image_utils.dart';
import 'package:provider/provider.dart';

import '../../view_models/icon_provider.dart';
import '../widgets/p_app_bar_search.dart';

/// 图标选择页面
class ChooseIconPage extends StatefulWidget {
  const ChooseIconPage({super.key, this.defaultIcon});

  static const String routeName = 'choose-icon';

  final IconModel? defaultIcon;

  @override
  State<ChooseIconPage> createState() => _ChooseIconPageState();
}

class _ChooseIconPageState extends State<ChooseIconPage> {
  late IconModel _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon =
        widget.defaultIcon ?? context.read<IconProvider>().defaultIcon;
  }

  Future<void> _addCustomIcon(IconProvider provider) async {
    final file = await ImageUtils.pickImage();
    if (file != null) {
      await provider.addCustomIcon(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IconProvider>();
    return Scaffold(
      appBar: PAppBarSearch(
        onUpdateSearchQuery: (val) {
          // logger.d(val);
        },
        normalTitle: const Text(
          'Choose Icon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed:
                () async => await _addCustomIcon(context.read<IconProvider>()),
            icon: Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await provider.refreshIcons(),
        child: Scrollbar(
          radius: Radius.circular(8),
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 100),
            itemCount: provider.icons.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIcon = provider.icons[index];
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _selectedIcon == provider.icons[index]
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: getOriginalIcon(provider.icons[index]),
                  ),
                  // TODO: 是否显示icon name, github icon : github
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final navigator = Navigator.of(context);
          // 那么在这里需要将对应的IconModel 读取bytes
          if (_selectedIcon.type == IconModelType.userCustom &&
              _selectedIcon.bytes == null) {
            final bytes = await File(_selectedIcon.path!).readAsBytes();
            _selectedIcon.bytes = bytes;
          }

          navigator.pop<IconModel?>(_selectedIcon);
        },
        child: Icon(Icons.done),
      ),
    );
  }
}
