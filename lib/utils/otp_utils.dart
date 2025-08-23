import 'package:otp/otp.dart';
import 'package:peak_pass/data/models/otp_model.dart';

class OtpUtils {
  const OtpUtils._();

  /// 从string中解析出对应的OtpModel
  static OtpModel? parseUri(String value) {
    final isOtpAuth = isOtpAuthUri(value);
    if (!isOtpAuth) return null;

    final uri = Uri.parse(_getUriString(value));
    if (uri.scheme != 'otpauth') {
      throw ArgumentError('Invalid URI scheme: ${uri.scheme}');
    }

    final typeString = uri.host;
    final OtpType type = OtpType.fromString(typeString);

    // Path 格式: /issuer[:account]
    final label = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
    String issuerFromPath = '';
    String? account;

    if (label.contains(':')) {
      final parts = label.split(':');
      issuerFromPath = parts[0];
      account = parts[1];
    } else {
      issuerFromPath = label;
    }

    final query = uri.queryParameters;

    final secret = query['secret'];
    if (secret == null || secret.isEmpty) {
      throw ArgumentError('Missing secret parameter');
    }

    // issuer 优先 query 中的值
    final issuer = query['issuer'] ?? issuerFromPath;

    final algorithm =
        query.containsKey('algorithm')
            ? fromString(query['algorithm']!)
            : Algorithm.SHA1;

    final digits = int.tryParse(query['digits'] ?? '') ?? 6;

    int? period;
    int? counter;

    if (type == OtpType.totp) {
      period = int.tryParse(query['period'] ?? '') ?? 30;
    } else if (type == OtpType.hotp) {
      counter = int.tryParse(query['counter'] ?? '') ?? 0;
    }

    return OtpModel(
      issuer: issuer,
      secret: secret,
      account: account,
      type: type,
      algorithm: algorithm,
      digits: digits,
      period: period,
      counter: counter,
    );
  }

  /// 检查字符串是否经过URL编码
  static bool isUrlEncoded(String value) {
    try {
      final decoded = Uri.decodeComponent(value);
      return decoded != value;
    } catch (e) {
      return false;
    }
  }

  /// 获取URI字符串，自动处理解码
  static String _getUriString(String value) {
    try {
      final decoded = Uri.decodeComponent(value);
      return decoded != value ? decoded : value;
    } catch (e) {
      return value;
    }
  }

  /// otp auth 校验
  static bool isOtpAuthUri(String value) {
    if (value.isEmpty) {
      return false;
    }

    try {
      final uri = Uri.parse(_getUriString(value));

      // 检查scheme是否为otpauth
      if (uri.scheme != 'otpauth') {
        return false;
      }

      // 检查是否有有效的类型 (totp 或 hotp)
      if (uri.host != 'totp' && uri.host != 'hotp') {
        return false;
      }

      // 检查路径是否存在
      // if (uri.pathSegments.isEmpty) {
      //   return false;
      // }

      // 检查是否有secret参数
      final query = uri.queryParameters;
      if (!query.containsKey('secret') || query['secret']!.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Algorithm fromString(String value) => Algorithm.values.firstWhere(
    (e) => e.name.toUpperCase() == value.toUpperCase(),
    orElse: () => Algorithm.SHA1,
  );

  static String generateCode(OtpModel model) {
    if (model.type == OtpType.totp) {
      // totp
      return OTP.generateTOTPCodeString(
        model.secret,
        DateTime.now().millisecondsSinceEpoch,
        length: model.digits,
        interval: model.period!,
        algorithm: model.algorithm,
        isGoogle: true,
      );
    } else {
      // hotp
      return OTP.generateHOTPCodeString(
        model.secret,
        model.counter!,
        length: model.digits,
        algorithm: model.algorithm,
        isGoogle: true,
      );
    }
  }
}
