import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:peak_pass/common/constants/path_key.dart';
import 'package:peak_pass/data/models/file_model.dart';
import 'package:peak_pass/data/services/kdbx_service.dart';
import 'package:peak_pass/ui/widgets/gap.dart';
import 'package:peak_pass/ui/widgets/p_button.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

class KeyfileBottomSheet extends StatefulWidget {
  const KeyfileBottomSheet({super.key});

  @override
  State<KeyfileBottomSheet> createState() => _KeyfileBottomSheetState();

  /// 返回创建或选择文件的全路径
  static Future<FileModel?> show(BuildContext context) {
    return showModalBottomSheet<FileModel?>(
      context: context,
      sheetAnimationStyle: const AnimationStyle(duration: Durations.short3),
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => const KeyfileBottomSheet(),
    );
  }
}

class _KeyfileBottomSheetState extends State<KeyfileBottomSheet> {
  String _keyfileName = '';
  String? _userCustomKeyfileDir;

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        MediaQuery.of(context).viewInsets.bottom + 42,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc(context).keyfileProtectionTips,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(loc(context).keyfileProtectionContent),
          Gap.vertical(12),
          PTextFormField(
            hintText: loc(context).enterKeyfileName,
            onChanged: (val) {
              setState(() {
                _keyfileName = val;
              });
            },
          ),
          Gap.vertical(12),
          Row(
            spacing: 12,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: PButton(
                  isTonal: true,
                  onPressed: () async {
                    // 用户选择已存在的keyfile作为新建的数据库解锁凭证
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      navigator.pop<FileModel>(
                        FileModel(result.files.single.path!),
                      );
                    }
                  },
                  child: Text(loc(context).select),
                ),
              ),
              Expanded(
                child: PButton(
                  onPressed: () async {
                    if (_keyfileName.trim().isEmpty) {
                      return showToastBottom(
                        loc(context).pleaseEnterKeyfileName,
                      );
                    }
                    final appLoc = loc(context);
                    final kdbxService = Provider.of<KdbxService>(
                      context,
                      listen: false,
                    );
                    // 1. 创建凭证
                    final bytes =
                        kdbxService.createKeyFileCredentials().getBinary();
                    // 2. 用户选择存储路径
                    _userCustomKeyfileDir =
                        await FilePicker.platform.getDirectoryPath();
                    if (_userCustomKeyfileDir == null) {
                      return showToastBottom(
                        appLoc.failed(appLoc.create, appLoc.keyfile),
                      );
                    }

                    // 3. 保存
                    final keyfilePath = p.setExtension(
                      p.join(_userCustomKeyfileDir!, _keyfileName),
                      PathKey.keyfileExtension,
                    );
                    final res = FileModel(keyfilePath);
                    await kdbxService.saveKeyfile(res, bytes);

                    showToastBottom(
                      appLoc.successfully(appLoc.create, appLoc.keyfile),
                    );
                    navigator.pop<FileModel>(res);
                  },
                  child: Text(loc(context).generate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
