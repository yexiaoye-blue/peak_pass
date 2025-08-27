import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Peak Pass'**
  String get appName;

  /// No description provided for @zh.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get zh;

  /// No description provided for @zhHant.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get zhHant;

  /// No description provided for @en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get en;

  /// Label for recycle bin section
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin'**
  String get recycleBin;

  /// Label for databases section
  ///
  /// In en, this message translates to:
  /// **'Databases'**
  String get databases;

  /// Label for check all action
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get checkAll;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @createNew.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createNew;

  /// No description provided for @openExists.
  ///
  /// In en, this message translates to:
  /// **'Open Existing'**
  String get openExists;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get deleteConfirm;

  /// No description provided for @deleteContent.
  ///
  /// In en, this message translates to:
  /// **'Move selected items to the recycle bin'**
  String get deleteContent;

  /// No description provided for @deleteFromRecycleBinConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete from recycle bin?'**
  String get deleteFromRecycleBinConfirm;

  /// No description provided for @deleteFromRecycleBinContent.
  ///
  /// In en, this message translates to:
  /// **'This action will permanently delete the selected items'**
  String get deleteFromRecycleBinContent;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get recovery;

  /// No description provided for @recoveryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Restore selected items?'**
  String get recoveryConfirm;

  /// No description provided for @recoveryContent.
  ///
  /// In en, this message translates to:
  /// **'These items will be restored from the recycle bin to normal items.'**
  String get recoveryContent;

  /// No description provided for @createDatabase.
  ///
  /// In en, this message translates to:
  /// **'Create Database'**
  String get createDatabase;

  /// No description provided for @databaseName.
  ///
  /// In en, this message translates to:
  /// **'Database Name'**
  String get databaseName;

  /// No description provided for @enterDatabaseName.
  ///
  /// In en, this message translates to:
  /// **'Enter database name'**
  String get enterDatabaseName;

  /// No description provided for @masterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get masterPassword;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @keyfile.
  ///
  /// In en, this message translates to:
  /// **'Key File'**
  String get keyfile;

  /// No description provided for @clickToSelectOrGen.
  ///
  /// In en, this message translates to:
  /// **'Click to select or create new'**
  String get clickToSelectOrGen;

  /// No description provided for @biometrics.
  ///
  /// In en, this message translates to:
  /// **'Biometrics'**
  String get biometrics;

  /// No description provided for @biometricHWUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Your hardware does not support biometric authentication'**
  String get biometricHWUnavailable;

  /// Same behavior as errorPasscodeNotSet: Passcode is not set (iOS/MacOS) or no user credentials (on macOS).
  ///
  /// In en, this message translates to:
  /// **'No biometric information or device credentials (e.g., lock screen password) enrolled'**
  String get biometricNotEnrolled;

  /// No description provided for @biometricNoHardware.
  ///
  /// In en, this message translates to:
  /// **'This device has no suitable biometric hardware (e.g., biometric sensor or lock screen protection)'**
  String get biometricNoHardware;

  /// No description provided for @biometricStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unable to determine whether biometric authentication is supported'**
  String get biometricStatusUnknown;

  /// No description provided for @biometricNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not supported'**
  String get biometricNotSupported;

  /// No description provided for @chooseAtLeastOneUnlockingMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one unlocking method'**
  String get chooseAtLeastOneUnlockingMethod;

  /// No description provided for @keyfileProtectionTips.
  ///
  /// In en, this message translates to:
  /// **'Key File Security Tips'**
  String get keyfileProtectionTips;

  /// No description provided for @keyfileProtectionContent.
  ///
  /// In en, this message translates to:
  /// **'A key file is part of the master key and contains no database data. If lost or modified, the database becomes inaccessible. Back it up securely.'**
  String get keyfileProtectionContent;

  /// No description provided for @enterKeyfileName.
  ///
  /// In en, this message translates to:
  /// **'Enter key file name'**
  String get enterKeyfileName;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @pleaseEnterKeyfileName.
  ///
  /// In en, this message translates to:
  /// **'Please enter the key file name'**
  String get pleaseEnterKeyfileName;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @unlockDatabase.
  ///
  /// In en, this message translates to:
  /// **'Unlock Database'**
  String get unlockDatabase;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @path.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get path;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @accessedAt.
  ///
  /// In en, this message translates to:
  /// **'Accessed At'**
  String get accessedAt;

  /// No description provided for @modifiedAt.
  ///
  /// In en, this message translates to:
  /// **'Modified At'**
  String get modifiedAt;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @unlockFailed.
  ///
  /// In en, this message translates to:
  /// **'Unlock failed: {reason}'**
  String unlockFailed(String reason);

  /// No description provided for @invalidKey.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password or key file'**
  String get invalidKey;

  /// No description provided for @biometricStorageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Biometric storage is empty'**
  String get biometricStorageEmpty;

  /// No description provided for @passwordGenerator.
  ///
  /// In en, this message translates to:
  /// **'Password Generator'**
  String get passwordGenerator;

  /// No description provided for @exportOrImport.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get exportOrImport;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @backupOrRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup / Restore'**
  String get backupOrRestore;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @safeExit.
  ///
  /// In en, this message translates to:
  /// **'Safe Exit'**
  String get safeExit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Password Length description
  ///
  /// In en, this message translates to:
  /// **'Password Length: {length}'**
  String passwordLength(int length);

  /// No description provided for @parameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get parameters;

  /// No description provided for @alphabetsLowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase Letters'**
  String get alphabetsLowercase;

  /// No description provided for @alphabetsLowercaseContent.
  ///
  /// In en, this message translates to:
  /// **'Use lowercase letters \'a\' to \'z\''**
  String get alphabetsLowercaseContent;

  /// No description provided for @alphabetsUppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase Letters'**
  String get alphabetsUppercase;

  /// No description provided for @alphabetsUppercaseContent.
  ///
  /// In en, this message translates to:
  /// **'Use uppercase letters \'A\' to \'Z\''**
  String get alphabetsUppercaseContent;

  /// No description provided for @digits.
  ///
  /// In en, this message translates to:
  /// **'Digits'**
  String get digits;

  /// No description provided for @digitsContent.
  ///
  /// In en, this message translates to:
  /// **'Use digits \'0\' to \'9\''**
  String get digitsContent;

  /// No description provided for @specialCharacters.
  ///
  /// In en, this message translates to:
  /// **'Special Characters'**
  String get specialCharacters;

  /// No description provided for @specialCharactersContent.
  ///
  /// In en, this message translates to:
  /// **'Use special characters !@#\$%^*_-'**
  String get specialCharactersContent;

  /// No description provided for @withoutConfusion.
  ///
  /// In en, this message translates to:
  /// **'Exclude Confusing Characters'**
  String get withoutConfusion;

  /// No description provided for @withoutConfusionContent.
  ///
  /// In en, this message translates to:
  /// **'Remove easily confused characters \'IOilo01\''**
  String get withoutConfusionContent;

  /// No description provided for @passwordList.
  ///
  /// In en, this message translates to:
  /// **'Password List'**
  String get passwordList;

  /// Originally designed as categories
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// Seems like intl can handle negative numbers?
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @lists.
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get lists;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New Entry'**
  String get newEntry;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createGroup;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @url.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @uri.
  ///
  /// In en, this message translates to:
  /// **'URI'**
  String get uri;

  /// No description provided for @datetime.
  ///
  /// In en, this message translates to:
  /// **'Datetime'**
  String get datetime;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @otpAuth.
  ///
  /// In en, this message translates to:
  /// **'OTPAuth'**
  String get otpAuth;

  /// No description provided for @chooseFileType.
  ///
  /// In en, this message translates to:
  /// **'Choose Field Type'**
  String get chooseFileType;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move Up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move Down'**
  String get moveDown;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// OTP auth QR code recognition
  ///
  /// In en, this message translates to:
  /// **'OTP Scanner'**
  String get otpScanner;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManually;

  /// Import image from album to recognize OTPAuth, etc.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get album;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get account;

  /// No description provided for @issuer.
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// No description provided for @secret.
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get secret;

  /// Length of the OTP code generated
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get otpDigits;

  /// No description provided for @algorithm.
  ///
  /// In en, this message translates to:
  /// **'Algorithm'**
  String get algorithm;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @counter.
  ///
  /// In en, this message translates to:
  /// **'Counter'**
  String get counter;

  /// URI string for OTP authentication
  ///
  /// In en, this message translates to:
  /// **'OTP URI'**
  String get otpUri;

  /// No description provided for @enterOTPUri.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP URI'**
  String get enterOTPUri;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @addField.
  ///
  /// In en, this message translates to:
  /// **'Add Field'**
  String get addField;

  /// No description provided for @barcodeFindMultiple.
  ///
  /// In en, this message translates to:
  /// **'Multiple codes detected, the first one will be used by default'**
  String get barcodeFindMultiple;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @cannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty.'**
  String get cannotBeEmpty;

  /// No description provided for @passwordInconsistentTwice.
  ///
  /// In en, this message translates to:
  /// **'The password is inconsistent twice'**
  String get passwordInconsistentTwice;

  /// No description provided for @pleaseOpenUseKeyfileUnlockDatabase.
  ///
  /// In en, this message translates to:
  /// **'Please use the key file to unlock the database'**
  String get pleaseOpenUseKeyfileUnlockDatabase;

  /// No description provided for @containsInvalidCharacters.
  ///
  /// In en, this message translates to:
  /// **'Contains invalid characters.'**
  String get containsInvalidCharacters;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Create database successfully!
  ///
  /// In en, this message translates to:
  /// **'{mode} {name} successfully!'**
  String successfully(String mode, String name);

  /// Failed to Create database!
  ///
  /// In en, this message translates to:
  /// **'Failed to {mode} {name}!'**
  String failed(String mode, String name);

  /// No description provided for @recycleBinIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Recycle Bin is empty.'**
  String get recycleBinIsEmpty;

  /// No description provided for @noDatabaseAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Database Available.'**
  String get noDatabaseAvailable;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @work.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @up.
  ///
  /// In en, this message translates to:
  /// **'Up'**
  String get up;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'Down'**
  String get down;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @emptyResult.
  ///
  /// In en, this message translates to:
  /// **'Empty Result'**
  String get emptyResult;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
