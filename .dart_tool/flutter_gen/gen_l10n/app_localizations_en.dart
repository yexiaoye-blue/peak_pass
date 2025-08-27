// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Peak Pass';

  @override
  String get zh => 'Simplified Chinese';

  @override
  String get zhHant => 'Traditional Chinese';

  @override
  String get en => 'English';

  @override
  String get recycleBin => 'Recycle Bin';

  @override
  String get databases => 'Databases';

  @override
  String get checkAll => 'Select All';

  @override
  String get create => 'Create';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get createNew => 'Create';

  @override
  String get openExists => 'Open Existing';

  @override
  String get delete => 'Delete';

  @override
  String get deleteConfirm => 'Delete item?';

  @override
  String get deleteContent => 'Move selected items to the recycle bin';

  @override
  String get deleteFromRecycleBinConfirm => 'Delete from recycle bin?';

  @override
  String get deleteFromRecycleBinContent =>
      'This action will permanently delete the selected items';

  @override
  String get recovery => 'Restore';

  @override
  String get recoveryConfirm => 'Restore selected items?';

  @override
  String get recoveryContent =>
      'These items will be restored from the recycle bin to normal items.';

  @override
  String get createDatabase => 'Create Database';

  @override
  String get databaseName => 'Database Name';

  @override
  String get enterDatabaseName => 'Enter database name';

  @override
  String get masterPassword => 'Master Password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get keyfile => 'Key File';

  @override
  String get clickToSelectOrGen => 'Click to select or create new';

  @override
  String get biometrics => 'Biometrics';

  @override
  String get biometricHWUnavailable =>
      'Your hardware does not support biometric authentication';

  @override
  String get biometricNotEnrolled =>
      'No biometric information or device credentials (e.g., lock screen password) enrolled';

  @override
  String get biometricNoHardware =>
      'This device has no suitable biometric hardware (e.g., biometric sensor or lock screen protection)';

  @override
  String get biometricStatusUnknown =>
      'Unable to determine whether biometric authentication is supported';

  @override
  String get biometricNotSupported =>
      'Biometric authentication is not supported';

  @override
  String get chooseAtLeastOneUnlockingMethod =>
      'Choose at least one unlocking method';

  @override
  String get keyfileProtectionTips => 'Key File Security Tips';

  @override
  String get keyfileProtectionContent =>
      'A key file is part of the master key and contains no database data. If lost or modified, the database becomes inaccessible. Back it up securely.';

  @override
  String get enterKeyfileName => 'Enter key file name';

  @override
  String get select => 'Select';

  @override
  String get pleaseEnterKeyfileName => 'Please enter the key file name';

  @override
  String get generate => 'Generate';

  @override
  String get unlockDatabase => 'Unlock Database';

  @override
  String get password => 'Password';

  @override
  String get unlock => 'Unlock';

  @override
  String get path => 'Path';

  @override
  String get size => 'Size';

  @override
  String get createdAt => 'Created At';

  @override
  String get accessedAt => 'Accessed At';

  @override
  String get modifiedAt => 'Modified At';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String unlockFailed(String reason) {
    return 'Unlock failed: $reason';
  }

  @override
  String get invalidKey => 'Incorrect password or key file';

  @override
  String get biometricStorageEmpty => 'Biometric storage is empty';

  @override
  String get passwordGenerator => 'Password Generator';

  @override
  String get exportOrImport => 'Import / Export';

  @override
  String get export => 'Export';

  @override
  String get backupOrRestore => 'Backup / Restore';

  @override
  String get languages => 'Languages';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get rateApp => 'Rate App';

  @override
  String get safeExit => 'Safe Exit';

  @override
  String get copy => 'Copy';

  @override
  String passwordLength(int length) {
    return 'Password Length: $length';
  }

  @override
  String get parameters => 'Parameters';

  @override
  String get alphabetsLowercase => 'Lowercase Letters';

  @override
  String get alphabetsLowercaseContent =>
      'Use lowercase letters \'a\' to \'z\'';

  @override
  String get alphabetsUppercase => 'Uppercase Letters';

  @override
  String get alphabetsUppercaseContent =>
      'Use uppercase letters \'A\' to \'Z\'';

  @override
  String get digits => 'Digits';

  @override
  String get digitsContent => 'Use digits \'0\' to \'9\'';

  @override
  String get specialCharacters => 'Special Characters';

  @override
  String get specialCharactersContent => 'Use special characters !@#\$%^*_-';

  @override
  String get withoutConfusion => 'Exclude Confusing Characters';

  @override
  String get withoutConfusionContent =>
      'Remove easily confused characters \'IOilo01\'';

  @override
  String get passwordList => 'Password List';

  @override
  String get groups => 'Groups';

  @override
  String get group => 'Group';

  @override
  String get lists => 'Lists';

  @override
  String get newEntry => 'New Entry';

  @override
  String get details => 'Details';

  @override
  String get createGroup => 'Create Category';

  @override
  String get title => 'Title';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get notes => 'Notes';

  @override
  String get url => 'URL';

  @override
  String get uri => 'URI';

  @override
  String get datetime => 'Datetime';

  @override
  String get number => 'Number';

  @override
  String get phone => 'Phone';

  @override
  String get otpAuth => 'OTPAuth';

  @override
  String get chooseFileType => 'Choose Field Type';

  @override
  String get moveUp => 'Move Up';

  @override
  String get moveDown => 'Move Down';

  @override
  String get remove => 'Remove';

  @override
  String get otpScanner => 'OTP Scanner';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get album => 'Album';

  @override
  String get account => 'Account Name';

  @override
  String get issuer => 'Issuer';

  @override
  String get secret => 'Secret';

  @override
  String get otpDigits => 'Length';

  @override
  String get algorithm => 'Algorithm';

  @override
  String get period => 'Period';

  @override
  String get counter => 'Counter';

  @override
  String get otpUri => 'OTP URI';

  @override
  String get enterOTPUri => 'Enter OTP URI';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get addField => 'Add Field';

  @override
  String get barcodeFindMultiple =>
      'Multiple codes detected, the first one will be used by default';

  @override
  String get clear => 'Clear';

  @override
  String get search => 'Search';

  @override
  String get theme => 'Theme';

  @override
  String get cannotBeEmpty => 'Cannot be empty.';

  @override
  String get passwordInconsistentTwice => 'The password is inconsistent twice';

  @override
  String get pleaseOpenUseKeyfileUnlockDatabase =>
      'Please use the key file to unlock the database';

  @override
  String get containsInvalidCharacters => 'Contains invalid characters.';

  @override
  String get scan => 'Scan';

  @override
  String successfully(String mode, String name) {
    return '$mode $name successfully!';
  }

  @override
  String failed(String mode, String name) {
    return 'Failed to $mode $name!';
  }

  @override
  String get recycleBinIsEmpty => 'Recycle Bin is empty.';

  @override
  String get noDatabaseAvailable => 'No Database Available.';

  @override
  String get all => 'All';

  @override
  String get unknown => 'Unknown';

  @override
  String get personal => 'Personal';

  @override
  String get work => 'Work';

  @override
  String get finance => 'Finance';

  @override
  String get shopping => 'Shopping';

  @override
  String get social => 'Social';

  @override
  String get other => 'Other';

  @override
  String get up => 'Up';

  @override
  String get down => 'Down';

  @override
  String get modify => 'Modify';

  @override
  String get emptyResult => 'Empty Result';
}
