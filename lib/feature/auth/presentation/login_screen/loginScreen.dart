// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_checkbox_tile.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/custom_password_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../common_widget/or_divider.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/auth_provider.dart';
import '../widgets/auth_components.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';
import 'widgets/login_footer.dart';
import 'widgets/passkey_button.dart';

/// Sign-in screen in the dashboard style: hero gradient with the white logo,
/// theme/language toggles and welcome text, a floating form card, and the
/// sign-up prompt + supplier mode switch below.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<AuthProvider>().resetLoginForm();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      context.read<AuthProvider>().resetLoginForm();
    } catch (_) {}
    super.dispose();
  }

  void _openForgotPassword(AuthProvider authProvider) {
    authProvider.resetLoginForm();
    Navigator.pushNamed(context, Routes.forgotPasswordScreen);
  }

  void _openSignUp(AuthProvider provider) {
    final isSupplier = provider.isSupplierRegister;
    provider.resetLoginForm();
    Navigator.pushNamed(context, isSupplier ? Routes.supplierRegisterScreen : Routes.signupScreen);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return AuthScaffold(
      body: AuthScrollBody(
        children: [
          AuthHeroTitle(title: 'welcome_back'.tr, subtitle: 'sign_in_workspace'.tr),
          UIHelper.verticalSpace(22.h),
          AuthFormCard(child: _buildForm(authProvider)),
          UIHelper.verticalSpace(22.h),
          AuthLinkPrompt(
            prompt: authProvider.isSupplierRegister ? 'become_supplier_prompt'.tr : 'new_platform'.tr,
            actionLabel: authProvider.isSupplierRegister ? 'become_supplier'.tr : 'create_account'.tr,
            onTap: () => _openSignUp(authProvider),
          ),
          UIHelper.verticalSpace(14.h),
          SupplierModeSwitch(
            value: authProvider.isSupplierRegister,
            onChanged: authProvider.toggleSupplierRegister,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    final labelStyle = TextStyle(
      fontSize: 13.5.sp,
      fontWeight: FontWeight.w700,
      color: AppColorsTheme.textMainColor(context),
    );

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PasskeyButton(label: 'sign_in_passkey'.tr, onPressed: () {}),
            UIHelper.verticalSpace(18.h),
            OrDivider(label: 'or_email'.tr),
            UIHelper.verticalSpace(18.h),

            CustomFieldLabel(label: 'email_address'.tr, fontSize: 13.5.sp),
            CustomFormField(
              controller: authProvider.emailController,
              inputType: TextInputType.emailAddress,
              hintText: 'enter_email'.tr,
              autofillHints: const [AutofillHints.email],
              validator: AuthValidators.email,
            ),
            UIHelper.verticalSpace(16.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('password'.tr, style: labelStyle),
                GestureDetector(
                  onTap: () => _openForgotPassword(authProvider),
                  child: Text(
                    'forgot_password'.tr,
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: primaryOrange),
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(8.h),
            CustomPasswordField(
              controller: authProvider.passwordController,
              hintText: 'enter_password'.tr,
              isObscure: authProvider.obscurePassword,
              onToggleObscure: authProvider.toggleObscurePassword,
              autofillHints: const [AutofillHints.password],
              validator: AuthValidators.loginPassword,
            ),
            UIHelper.verticalSpace(12.h),

            CustomCheckboxTile(
              value: authProvider.rememberMe,
              onChanged: authProvider.toggleRememberMe,
              label: 'remember_me'.tr,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),

            GradientButton(
              label: 'sign_in'.tr,
              trailingIcon: Icons.arrow_forward_rounded,
              isLoading: authProvider.isLoading,
              onPressed: () => authProvider.handleSignIn(context, _formKey),
            ),
          ],
        ),
      ),
    );
  }
}
