import 'dart:io';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:peak_pass/common/enums/enums.dart';
import 'package:peak_pass/common/exceptions/biometric_exception.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/utils/common_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorHandlerService {
  static final Logger _logger = Logger();

  /// 处理业务异常并显示给用户
  static void handleBusinessException(
    AppLocalizations appLoc,
    BusinessException exception,
  ) {
    _logger.e(
      'Business Exception: ${exception.message}',
      time: DateTime.now(),
      error: exception.details,
      stackTrace: exception.stackTrace,
    );

    if (exception.code == BizErrorCode.biometricStorageEmpty) {
      showToastBottom(appLoc.unlockFailed(appLoc.biometricStorageEmpty));
      return;
    }

    showToastBottom(exception.message);
  }

  /// 处理通用异常
  static void handleException(
    BuildContext context,
    Object exception, [
    StackTrace? stackTrace,
  ]) {
    _logger.e('Unhandled Exception: $exception', stackTrace: stackTrace);

    String message;
    if (exception is FileSystemException) {
      message = 'File operation failed: ${exception.message}';
    } else {
      message = 'An unexpected error occurred: ${exception.toString()}';
    }
    showToastBottom(message);
  }

  /// 显示成功消息
  static void showSuccessMessage(BuildContext context, String message) {
    _logger.i('Success: $message');
    showToastBottom(message);
  }

  /// 显示信息消息
  static void showInfoMessage(BuildContext context, String message) {
    _logger.i('Info: $message');
    showToastBottom(message);
  }

  /// 处理生物识别异常
  static void handleBiometricException(
    AppLocalizations appLoc,
    BiometricException exception,
  ) {
    _logger.e(
      'Biometric Exception: ${exception.response}',
      time: DateTime.now(),
    );

    String message;

    switch (exception.response) {
      case CanAuthenticateResponse.errorNoHardware:
        message = appLoc.biometricHWUnavailable;
        break;
      case CanAuthenticateResponse.errorHwUnavailable:
        message = appLoc.biometricHWUnavailable;
        break;
      case CanAuthenticateResponse.errorNoBiometricEnrolled ||
          CanAuthenticateResponse.errorPasscodeNotSet:
        message = appLoc.biometricNotEnrolled;
        break;
      case CanAuthenticateResponse.statusUnknown:
        message = appLoc.biometricStatusUnknown;
        break;
      case CanAuthenticateResponse.unsupported:
        message = appLoc.biometricNotSupported;
        break;
      default:
        message = appLoc.biometricNotSupported;
    }

    showToastBottom(message);
  }
}
