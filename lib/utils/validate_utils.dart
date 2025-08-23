/// 校验工具
/// 应用中只对: 非空, base32校验,其余不校验
class ValidateUtils {
  const ValidateUtils._();

  static String? notEmpty(
    String? val, [
    String helperText = 'Cannot be empty.',
  ]) {
    if (val == null || val.isEmpty) return helperText;
    return null;
  }

  ///  A TOTP URI is specified with the following ABNF:
  ///  totp-uri = "otpauth" "://" "totp/" label "?secret=" secret
  ///             "&issuer=" issuer
  ///    label = issuer (":" / "%3A") identity
  ///    identity = 1*CHAR ; URI-encoded SASL identity
  ///    secret = 40 * HEXCHAR ; Base32 (hex) encoded secret with no padding.
  ///    issuer = 1*CHAR ; Issuer name.
  /// https://datatracker.ietf.org/doc/html/draft-melnikov-scram-2fa-03#section-5
  ///
  /// Example: otpauth://totp/GitHub:jack?secret=xxxx&issuer=GitHub
  static String? otp(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Enter URI";
    }
    Uri? uri;
    try {
      uri = Uri.parse(val.trim());
    } catch (e) {
      return "URI format error";
    }
    if (uri.scheme != "otpauth") {
      return "URI must start with 'otpauth://'";
    }
    if (uri.host != "totp" && uri.host != "hotp") {
      return "URI type must be 'totp' or 'hotp'";
    }
    // label
    if (uri.pathSegments.isEmpty || uri.pathSegments.first.isEmpty) {
      return "Missing parameters 'label'";
    }
    if (!uri.queryParameters.containsKey("secret") ||
        uri.queryParameters["secret"]!.isEmpty) {
      return "Missing parameter 'secret'";
    }
    if (!uri.queryParameters.containsKey("issuer") ||
        uri.queryParameters["issuer"]!.isEmpty) {
      return "Missing parameter 'issuer'";
    }
    if (uri.host == 'hotp') {
      if (!uri.queryParameters.containsKey("counter") ||
          uri.queryParameters["counter"]!.isEmpty) {
        return "The schema 'htop' must contain parameter 'counter'";
      }
    }

    // 如果有需要，也可以对 secret 进行 base32 或长度的校验
    return null;
  }

  /// Validates if the given string is a valid Base32 encoded string.
  /// Base32 encoding uses the characters A-Z and 2-7.
  /// See RFC 4648 for more details.
  static String? base32(
    String? val, [
    String helperText = 'Invalid Base32 string.',
  ]) {
    if (notEmpty(val) != null) return notEmpty(val);

    // Base32 alphabet: A-Z and 2-7
    final RegExp base32Regex = RegExp(r'^[A-Z2-7]+$');

    if (!base32Regex.hasMatch(val!.toUpperCase())) {
      return helperText;
    }

    return null;
  }

  /// Validates if the given string contains only valid URI characters for
  /// TOTP account names, issuer names, and other label components.
  ///
  /// According to RFC 3986, the unreserved characters are:
  /// A-Z a-z 0-9 - . _ ~
  ///
  /// Additionally, since these values will be used in TOTP URIs, we should
  /// avoid characters that would need special encoding or could cause issues.
  static String? validUriComponent(
    String? val, [
    String helperText = 'Contains invalid characters.',
  ]) {
    if (val == null || val.isEmpty) return null; // Allow empty values

    // Valid characters for URI components (RFC 3986 unreserved characters)
    // A-Z a-z 0-9 - . _ ~
    final RegExp validChars = RegExp(r'^[A-Za-z0-9._~\-]*$');

    if (!validChars.hasMatch(val)) {
      return helperText;
    }

    return null;
  }
}
