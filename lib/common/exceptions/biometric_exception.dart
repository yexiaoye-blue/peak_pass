import 'package:biometric_storage/biometric_storage.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';

class BiometricException extends BusinessException {
  BiometricException({required this.response}) : super(message: "");
  final CanAuthenticateResponse response;

  @override
  String toString() => 'BiometricException(response: $response)';
}
