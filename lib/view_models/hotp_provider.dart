import 'package:flutter/material.dart';

import '../data/models/otp_model.dart';

class HotpProvider extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey();

  final accountController = TextEditingController();
  final issuerController = TextEditingController();
  final secretController = TextEditingController();
  final counterController = TextEditingController(text: '0');

  Uri? get uri => _model.buildUri();

  OtpModel _model = OtpModel.empty(OtpType.hotp);
  OtpModel get model => _model;
  set model(OtpModel model) {
    model.type = OtpType.hotp;
    _model = model;
    _syncHotpFormModel();
    notifyListeners();
  }

  HotpProvider() {
    // 监听用户手动编辑字段
    accountController.addListener(_changeAccount);
    issuerController.addListener(_changeIssuer);
    secretController.addListener(_changeSecret);
    counterController.addListener(_changeCounter);
  }

  void _changeAccount() {
    _model.account = accountController.text;
  }

  void _changeIssuer() {
    _model.issuer = issuerController.text;
  }

  void _changeSecret() {
    _model.secret = secretController.text;
  }

  void _changeCounter() {
    if (counterController.text.isNotEmpty) {
      _model.counter = int.parse(counterController.text);
    }
  }

  void _syncHotpFormModel() {
    accountController.text = _model.account ?? '';
    issuerController.text = _model.issuer;
    secretController.text = _model.secret;
    counterController.text = _model.counter.toString();
  }

  void clearFormModel() {
    accountController.clear();
    issuerController.clear();
    secretController.clear();
    counterController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    accountController.dispose();
    issuerController.dispose();
    secretController.dispose();
    counterController.dispose();
  }
}
