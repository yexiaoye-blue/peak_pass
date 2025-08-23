import 'package:otp/otp.dart';
import 'package:peak_pass/utils/otp_utils.dart';

enum OtpType {
  totp,
  hotp;

  const OtpType();
  static OtpType fromString(String value) => OtpType.values.singleWhere(
    (item) => item.name.toUpperCase() == value.toUpperCase(),
  );
}

class OtpModel {
  String issuer;
  String secret;
  String? account;
  OtpType type;
  Algorithm algorithm;
  int digits;

  int? period;
  int? counter;

  OtpModel({
    required this.issuer,
    required this.secret,
    this.account,
    this.type = OtpType.totp,
    this.algorithm = Algorithm.SHA1,

    this.digits = 6,
    this.period,
    this.counter,
  });

  factory OtpModel.fromUriStr(String uri) =>
      OtpUtils.parseUri(uri) ?? OtpModel.empty();

  factory OtpModel.empty([OtpType? type]) =>
      OtpModel(issuer: '', secret: '', type: type ?? OtpType.totp);

  /// 生成标准 otpauth URI
  /// otpauth://totp/Passkou?secret=6shyg3uens2sh5slhey3dmh47skvgq5y&issuer=Test&algorithm=SHA256&digits=8&period=60
  Uri buildUri() {
    final label =
        (account != null && account!.isNotEmpty) ? '$issuer:$account' : issuer;

    final Map<String, String> queryParams = {
      'secret': secret,
      'issuer': issuer,
      'algorithm': algorithm.name.toUpperCase(),
      'digits': digits.toString(),
    };

    if (type == OtpType.hotp) {
      queryParams['counter'] = counter != null ? counter.toString() : '0';
    } else if (type == OtpType.totp) {
      queryParams['period'] = period != null ? period.toString() : '30';
    }

    return Uri(
      scheme: 'otpauth',
      host: type.name, // totp / hotp
      path: '/$label',
      queryParameters: queryParams,
    );
  }

  @override
  String toString() {
    return 'OtpModel{issuer: $issuer, secret: $secret, account: $account, type: $type, algorithm: $algorithm, digits: $digits, period: $period, counter: $counter}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpModel &&
          runtimeType == other.runtimeType &&
          issuer == other.issuer &&
          secret == other.secret &&
          account == other.account &&
          type == other.type &&
          algorithm == other.algorithm &&
          digits == other.digits &&
          period == other.period &&
          counter == other.counter;

  @override
  int get hashCode => Object.hash(
    issuer,
    secret,
    account,
    type,
    algorithm,
    digits,
    period,
    counter,
  );
}
