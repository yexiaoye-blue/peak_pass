import 'package:otp/otp.dart';

class OtpParameters {
  const OtpParameters._();

  static const String prefix = 'otpauth';

  /// 支持的算法
  static const List<Algorithm> algorithms = Algorithm.values;

  ///  code刷新间隔
  static const List<int> intervals = [15, 30, 60, 120, 300];

  /// 生成code的长度
  static const List<int> digits = [6, 8];
}
