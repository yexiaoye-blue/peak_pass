import 'dart:io';

import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';

class FileOperationException extends BusinessException {
  final String operation;
  final String? filePath;
  final FileSystemException? originalException;

  FileOperationException({
    required this.operation,
    this.filePath,
    this.originalException,
    String? message,
  }) : super(
         message:
             message ??
             _generateMessage(operation, filePath, originalException),
         code: BizErrorCode.fileOperationError,
         details: {
           'operation': operation,
           'filePath': filePath,
           'originalException': originalException?.toString(),
           'osError': originalException?.osError?.toString(),
         },
       );

  static String _generateMessage(
    String operation,
    String? filePath,
    FileSystemException? originalException,
  ) {
    final buffer = StringBuffer();
    buffer.write('Failed to $operation file');

    if (filePath != null) {
      buffer.write(' "$filePath"');
    }

    if (originalException != null) {
      buffer.write(': ${originalException.message}');

      if (originalException.osError != null) {
        final osError = originalException.osError!;
        buffer.write(
          ' (OS Error: ${osError.message}, errno = ${osError.errorCode})',
        );

        // 提供更友好的错误信息
        switch (osError.errorCode) {
          case 13:
            buffer.write(
              '. Please check if the file is in use or if you have sufficient permissions.',
            );
            break;
          case 2:
            buffer.write('. The file does not exist.');
            break;
          case 17:
            buffer.write('. The destination file already exists.');
            break;
          case 18:
            buffer.write(
              '. Cannot move file across different storage devices.',
            );
            break;
          case 21:
            buffer.write('. The path refers to a directory, not a file.');
            break;
        }
      }
    }

    return buffer.toString();
  }
}
