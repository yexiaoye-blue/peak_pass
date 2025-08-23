import 'package:flutter/material.dart';

import '../data/models/otp_model.dart';

class TotpProvider extends ChangeNotifier {
  // TODO: initial value实际上是要给到 controller的
  final accountController = TextEditingController();
  final issuerController = TextEditingController();
  final secretController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey();

  Uri? get uri => _model.buildUri();

  OtpModel _model = OtpModel.empty(OtpType.totp);
  OtpModel get model => _model;
  set model(OtpModel model) {
    model.type = OtpType.totp;
    _model = model;
    _syncTotpFormModel();
    notifyListeners();
  }

  TotpProvider() {
    // 监听用户手动编辑字段
    accountController.addListener(_changeAccount);
    issuerController.addListener(_changeIssuer);
    secretController.addListener(_changeSecret);
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

  void _syncTotpFormModel() {
    accountController.text = _model.account ?? '';
    issuerController.text = _model.issuer;
    secretController.text = _model.secret;
    // accountController.value = TextEditingValue(text: _model.account ?? '');
    // issuerController.value = TextEditingValue(text: _model.issuer);
    // secretController.value = TextEditingValue(text: _model.secret);
  }

  void clearFormModel() {
    accountController.clear();
    issuerController.clear();
    secretController.clear();
  }

  @override
  void dispose() {
    super.dispose();
    accountController.dispose();
    issuerController.dispose();
    secretController.dispose();
  }
}
