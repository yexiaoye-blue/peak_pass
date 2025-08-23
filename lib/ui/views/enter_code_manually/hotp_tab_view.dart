import 'package:flutter/material.dart';
import 'package:otp/otp.dart';
import 'package:peak_pass/ui/widgets/counter_field.dart';
import 'package:peak_pass/ui/widgets/p_text_form_field.dart';
import 'package:peak_pass/utils/validate_utils.dart';
import 'package:peak_pass/utils/loc.dart';
import 'package:peak_pass/view_models/hotp_provider.dart';
import 'package:provider/provider.dart';

import '../../../common/constants/otp_parameters.dart';
import '../../widgets/p_dropdown_menu.dart';
import '../../widgets/horizontal_radio_field.dart';

class HotpTabView extends StatefulWidget {
  const HotpTabView({super.key});

  @override
  State<HotpTabView> createState() => _HotpTabViewState();
}

class _HotpTabViewState extends State<HotpTabView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer<HotpProvider>(
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
                      (val) => ValidateUtils.notEmpty(
                        val,
                        loc(context).cannotBeEmpty,
                      ),
                ),
                PTextFormField(
                  controller: provider.secretController,
                  label: Text(loc(context).secret),
                  validator: (val) => ValidateUtils.base32(val),
                ),
                CounterField(
                  controller: provider.counterController,
                  label: Text(loc(context).counter),
                ),
                HorizontalRadioField<int>(
                  label: Text(loc(context).otpDigits),
                  data: OtpParameters.digits,
                  errorPlaceholder: true,
                  onSelected: (val) {
                    provider.model.digits = val;
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
