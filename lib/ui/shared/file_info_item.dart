import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/view_models/locale_provider.dart';
import 'package:provider/provider.dart';

class FileInfoItem<T> extends StatelessWidget {
  const FileInfoItem({
    super.key,
    required this.title,
    this.content,
    this.futureContent,
    this.formatter,
    this.formatType = ItemFormatType.custom,
  });

  final String title;
  final T? content;
  final Future<T>? futureContent;
  final String Function(T)? formatter;
  final ItemFormatType formatType;

  @override
  Widget build(BuildContext context) {
    final locale = context.read<LocaleProvider>().locale;

    Widget buildContent(T? data) {
      if (data == null) {
        return const Text('N/A');
      }

      // 如果提供了自定义格式化函数，则使用它
      if (formatter != null) {
        return Text(
          formatter!(data),
          softWrap: true,
          overflow: TextOverflow.visible,
        );
      }

      // 根据 formatType 进行格式化
      String text;
      switch (formatType) {
        case ItemFormatType.dateTimeDefault:
          if (data is DateTime) {
            text = DateFormat.yMMMMd(
              locale.toString(),
            ).add_Hms().addPattern('SSS').format(data);
          } else {
            text = data.toString();
          }
          break;

        case ItemFormatType.dateTimeWithMilliseconds:
          if (data is DateTime) {
            text = DateFormat.yMMMMd(
              locale.toString(),
            ).add_Hms().addPattern("SSS").format(data);
          } else {
            text = data.toString();
          }
          break;

        case ItemFormatType.fileSize:
          if (data is int) {
            text = _formatFileSize(data);
          } else {
            text = data.toString();
          }
          break;

        case ItemFormatType.integer:
          text = data.toString();
          break;

        case ItemFormatType.doubleTwoDecimals:
          if (data is double) {
            text = data.toStringAsFixed(2);
          } else {
            text = data.toString();
          }
          break;

        default:
          text = data.toString();
      }

      return Text(text, softWrap: true, overflow: TextOverflow.visible);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child:
              futureContent != null
                  ? FutureBuilder<T>(
                    future: futureContent,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return buildContent(snapshot.data);
                      } else if (snapshot.hasError) {
                        return const Text('Error');
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  )
                  : buildContent(content),
        ),
      ],
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
