import 'package:peak_pass/common/exceptions/business_exception.dart';

/// 认证相关异常类
/// 用于处理登录失败、权限验证失败等认证相关操作异常
class AuthenticationException extends BusinessException {
  AuthenticationException({required super.message, super.code, super.details});

  @override
  String toString() {
    if (code != null) {
      return 'AuthenticationException: [$code] $message';
    }
    return 'AuthenticationException: $message';
  }
}
