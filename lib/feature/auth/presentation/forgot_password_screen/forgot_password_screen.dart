import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/forgot_password_provider.dart';
import '../widgets/auth_components.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// Request a password reset link, in the shared auth style.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<ForgotPasswordProvider>().resetForm();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      context.read<ForgotPasswordProvider>().resetForm();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ForgotPasswordProvider>();

    return AuthScaffold(
      heroHeight: 290,
      onBack: () => Navigator.pop(context),
      body: AuthScrollBody(
        children: [
          const AuthHeroIcon(icon: Icons.lock_reset_rounded),
          UIHelper.verticalSpace(12.h),
          AuthHeroTitle(title: 'forgot_password_title'.tr, subtitle: 'forgot_password_subtitle'.tr),
          UIHelper.verticalSpace(22.h),
          AuthFormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomFieldLabel(label: 'email_address'.tr),
                  CustomFormField(
                    controller: provider.emailController,
                    inputType: TextInputType.emailAddress,
                    hintText: 'enter_email'.tr,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) => AuthValidators.email(
                      value,
                      emptyKey: 'please_enter_email',
                      invalidKey: 'valid_email_address',
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),
                  GradientButton(
                    label: 'send_reset_instructions'.tr,
                    isLoading: provider.isLoading,
                    onPressed: () async {
                      await provider.sendResetLink(context, _formKey);
                    },
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(14.h),
          AuthTextLink(
            label: 'back_to_sign_in'.tr,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
