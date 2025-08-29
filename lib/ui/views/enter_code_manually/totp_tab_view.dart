import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:peak_pass/common/constants/otp_parameters.dart';
import 'package:peak_pass/ui/widgets/horizontal_radio_field.dart';
import 'package:peak_pass/ui/widgets/p_dropdown_menu.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/validate_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/totp_provider.dart';
import 'package:provider/provider.dart';

class TotpTabView extends StatefulWidget {
  const TotpTabView({super.key});
  @override
  State<TotpTabView> createState() => _TotpTabViewState();
}

class _TotpTabViewState extends State<TotpTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<TotpProvider>(
        builder: (context, provider, child) {
          return Form(
            key: provider.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PTextFormField(
                  controller: provider.accountController,
                  label: Text(loc(context).account),
                  validator:
                      (val) => ValidateUtils.notEmpty(
                        val,
                        loc(context).cannotBeEmpty,
                      ),
                ),
                PTextFormField(
                  controller: provider.issuerController,
                  label: Text(loc(context).issuer),
                  validator:
                      (val) => ValidateUtils.validUriComponent(
                        val,
                        loc(context).containsInvalidCharacters,
                      ),
                ),
                PTextFormField(
                  controller: provider.secretController,
                  label: Text(loc(context).secret),
                  validator: (val) => ValidateUtils.base32(val),
                ),
                HorizontalRadioField<int>(
                  label: Text(loc(context).otpDigits),
                  data: OtpParameters.digits,
                  errorPlaceholder: true,
                  onSelected: (val) {
                    provider.model.counter = val;
                  },
                ),
                PDropdownMenu<Algorithm>(
                  label: Text(loc(context).algorithm),
                  data: OtpParameters.algorithms,
                  entryBuilder: (
                    BuildContext context,
                    Algorithm item,
                    int index,
                  ) {
                    return PDropdownMenuEntry(value: item, label: item.name);
                  },
                  onSelected: (algorithm) {
                    if (algorithm != null) {
                      provider.model.algorithm = algorithm;
                    }
                  },
                ),

                PDropdownMenu(
                  label: Text(loc(context).period),
                  data: OtpParameters.intervals,
                  entryBuilder: (BuildContext context, int item, int index) {
                    return PDropdownMenuEntry(
                      value: item,
                      label: item.toString(),
                    );
                  },
                  onSelected: (value) {
                    if (value != null) {
                      provider.model.period = value;
                    }
                  },
                ),

                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
