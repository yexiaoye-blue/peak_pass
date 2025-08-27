import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:peak_pass/common/exceptions/business_exception.dart';
import 'package:peak_pass/data/services/storage_service_utils.dart';
import 'package:peak_pass/utils/common_utils.dart';

class LocaleProvider extends ChangeNotifier {
  LocaleProvider() {
    _locale = getDefaultLocale();
  }

  late Locale _locale;
  Locale get locale => _locale;

  Locale get en => AppLocalizations.supportedLocales.singleWhere(
    (locale) => locale.languageCode == 'en',
  );

  Locale getDefaultLocale() {
    // 1. 尝试获取用户之前存储过的
    final locale = StorageServiceUtils.getLocale();
    if (locale != null && isSupport(locale)) {
      return locale;
    }

    // 2. 使用系统默认值
    final systemLocale = PlatformDispatcher.instance.locale;
    logger.d(systemLocale);
    return isSupport(systemLocale) ? systemLocale : en;
  }

  bool isSupport(Locale locale) {
    final res =
        AppLocalizations.supportedLocales
            .where((supported) => supported.languageCode == locale.languageCode)
            .firstOrNull;

    return res != null;
  }

  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  void setLocale(Locale locale) {
    if (!isSupport(locale)) {
      throw BusinessException(message: 'Unsupported local: $locale');
    }
    _locale = locale;
    StorageServiceUtils.setLocale(_locale);
    notifyListeners();
  }
}
