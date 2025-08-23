import 'package:peak_pass/common/exceptions/business_exception.dart';

/// Entry操作异常类
/// 用于处理Entry相关的操作失败异常，如创建、更新、删除Entry等操作
class EntryOperationException extends BusinessException {
  EntryOperationException({
    required super.message,
    required super.code,
    required super.details,
  });

  @override
  String toString() {
    if (code != null) {
      return 'EntryOperationException: [$code] $message';
    }
    return 'EntryOperationException: $message';
  }
}
