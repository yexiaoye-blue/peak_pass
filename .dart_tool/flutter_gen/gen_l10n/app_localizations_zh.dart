// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Peak Pass';

  @override
  String get zh => '简体中文';

  @override
  String get zhHant => '繁体中文';

  @override
  String get en => '英文';

  @override
  String get recycleBin => '回收站';

  @override
  String get databases => '数据库';

  @override
  String get checkAll => '全选';

  @override
  String get create => '创建';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get createNew => '创建';

  @override
  String get openExists => '打开已存在';

  @override
  String get delete => '删除';

  @override
  String get deleteConfirm => '删除项目?';

  @override
  String get deleteContent => '移除选中项目至回收站';

  @override
  String get deleteFromRecycleBinConfirm => '从回收站中删除?';

  @override
  String get deleteFromRecycleBinContent => '该操作将会永久删除选中的项目';

  @override
  String get recovery => '恢复';

  @override
  String get recoveryConfirm => '恢复选中的项目?';

  @override
  String get recoveryContent => '这些项目会从回收站恢复到普通项目中.';

  @override
  String get createDatabase => '创建数据库';

  @override
  String get databaseName => '数据库名称';

  @override
  String get enterDatabaseName => '输入数据库名称';

  @override
  String get masterPassword => '主密码';

  @override
  String get enterPassword => '输入密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get keyfile => '密钥文件';

  @override
  String get clickToSelectOrGen => '点击以选择或新建';

  @override
  String get biometrics => '生物识别';

  @override
  String get biometricHWUnavailable => '您的硬件不支持生物识别功能';

  @override
  String get biometricNotEnrolled => '尚未录入任何生物识别信息或设备凭证（如锁屏密码）';

  @override
  String get biometricNoHardware => '设备没有合适的生物识别硬件（如生物识别传感器或锁屏保护）';

  @override
  String get biometricStatusUnknown => '无法确定是否支持生物识别功能';

  @override
  String get biometricNotSupported => '不支持生物识别功能';

  @override
  String get chooseAtLeastOneUnlockingMethod => '至少选择一种解锁方式';

  @override
  String get keyfileProtectionTips => '密钥文件安全提示';

  @override
  String get keyfileProtectionContent =>
      '密钥文件是主密钥的一部分，不包含任何数据库数据。如果丢失或被修改，数据库将无法访问。请妥善备份并安全保存。';

  @override
  String get enterKeyfileName => '输入数据库名称';

  @override
  String get select => '选择';

  @override
  String get pleaseEnterKeyfileName => '请输入密钥文件名称';

  @override
  String get generate => '生成';

  @override
  String get unlockDatabase => '解锁数据库';

  @override
  String get password => '密码';

  @override
  String get unlock => '解锁';

  @override
  String get path => '路径';

  @override
  String get size => '大小';

  @override
  String get createdAt => '创建日期';

  @override
  String get accessedAt => '访问日期';

  @override
  String get modifiedAt => '修改日期';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String unlockFailed(String reason) {
    return '解锁失败: $reason';
  }

  @override
  String get invalidKey => '错误的密码或密钥文件';

  @override
  String get biometricStorageEmpty => '生物识别存储为空';

  @override
  String get passwordGenerator => '密码生成器';

  @override
  String get exportOrImport => '导入/导出';

  @override
  String get export => '导出';

  @override
  String get backupOrRestore => '备份/恢复';

  @override
  String get languages => '语言';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get rateApp => '给应用评分';

  @override
  String get safeExit => '安全退出';

  @override
  String get copy => '复制';

  @override
  String passwordLength(int length) {
    return '密码长度: $length';
  }

  @override
  String get parameters => '参数';

  @override
  String get alphabetsLowercase => '小写字符';

  @override
  String get alphabetsLowercaseContent => '使用小写字符\'a\'到\'z\'';

  @override
  String get alphabetsUppercase => '大写字符';

  @override
  String get alphabetsUppercaseContent => '使用大写字符\'A\'到\'Z\'';

  @override
  String get digits => '数字';

  @override
  String get digitsContent => '使用数字\'0\'到\'9\'';

  @override
  String get specialCharacters => '特殊字符';

  @override
  String get specialCharactersContent => '使用特殊字符!@#\$%^*_-';

  @override
  String get withoutConfusion => '无易混淆字符';

  @override
  String get withoutConfusionContent => '去除易混淆字符 \'IOilo01\'';

  @override
  String get passwordList => '密码列表';

  @override
  String get groups => '分组';

  @override
  String get group => '分组';

  @override
  String get lists => '列表';

  @override
  String get newEntry => '新建条目';

  @override
  String get details => '详情';

  @override
  String get createGroup => '创建分组';

  @override
  String get title => '标题';

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get notes => '笔记';

  @override
  String get url => 'URL';

  @override
  String get uri => 'URI';

  @override
  String get datetime => '日期';

  @override
  String get number => '数字';

  @override
  String get phone => '电话';

  @override
  String get otpAuth => 'OTPAuth';

  @override
  String get chooseFileType => '选择字段类型';

  @override
  String get moveUp => '向上移动';

  @override
  String get moveDown => '向下移动';

  @override
  String get remove => '移除';

  @override
  String get otpScanner => 'OTP扫描';

  @override
  String get enterManually => '手动输入';

  @override
  String get album => '相册';

  @override
  String get account => '账户名';

  @override
  String get issuer => '发布者';

  @override
  String get secret => '密钥';

  @override
  String get otpDigits => '长度';

  @override
  String get algorithm => '算法';

  @override
  String get period => '周期';

  @override
  String get counter => '计数器';

  @override
  String get otpUri => 'OTP URI';

  @override
  String get enterOTPUri => '输入OTP URI';

  @override
  String get save => '保存';

  @override
  String get edit => '编辑';

  @override
  String get addField => '添加字段';

  @override
  String get barcodeFindMultiple => '扫描到多个,默认使用第一个';

  @override
  String get clear => '清空';

  @override
  String get search => '搜索';

  @override
  String get theme => '主题';

  @override
  String get cannotBeEmpty => '不能为空';

  @override
  String get passwordInconsistentTwice => '两次密码不一致';

  @override
  String get pleaseOpenUseKeyfileUnlockDatabase => '请先开启使用密钥文件解锁数据库';

  @override
  String get containsInvalidCharacters => '包含非法字符';

  @override
  String get scan => '扫描';

  @override
  String successfully(String mode, String name) {
    return '$mode$name成功!';
  }

  @override
  String failed(String mode, String name) {
    return '$mode$name失败!';
  }

  @override
  String get recycleBinIsEmpty => '回收站为空';

  @override
  String get noDatabaseAvailable => '没有可用的数据库';

  @override
  String get all => '所有';

  @override
  String get unknown => '未知';

  @override
  String get personal => '个人';

  @override
  String get work => '工作';

  @override
  String get finance => '财务';

  @override
  String get shopping => '购物';

  @override
  String get social => '社交';

  @override
  String get other => '其他';

  @override
  String get up => '向上';

  @override
  String get down => '向下';

  @override
  String get modify => '修改';

  @override
  String get emptyResult => '无结果';
}
