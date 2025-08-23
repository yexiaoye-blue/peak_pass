import 'package:peak_pass/common/enums/enums.dart';

class BusinessException implements Exception {
  final String message;
  final BizErrorCode? code;
  final dynamic details;
  final StackTrace? stackTrace;

  BusinessException({
    required this.message,
    this.code,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'BusinessException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}
