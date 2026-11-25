// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_checkbox_tile.dart';
import '../../../../common_widget/custom_dropdown_field.dart';
import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/custom_password_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../common_widget/or_divider.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/navigation_service.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/sign_up_provider.dart';
import '../widgets/auth_components.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// User sign-up: required details, optional profile fields, terms, create account.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late final SignUpProvider _formProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Looked up once here: providers cannot be read from a disposed context.
    _formProvider = context.read<SignUpProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _formProvider.resetSignUpForm());
  }

  @override
  void dispose() {
    // Reset after this frame: notifying listeners while the tree is being
    // torn down would throw.
    final provider = _formProvider;
    WidgetsBinding.instance.addPostFrameCallback((_) => provider.resetSignUpForm());
    super.dispose();
  }

  Future<void> _selectDateOfBirth(BuildContext context, SignUpProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final scheme = isDark
            ? ColorScheme.dark(
                primary: primaryOrange,
                onPrimary: Colors.white,
                surface: AppColorsTheme.cardBg(context),
                onSurface: darkTextMain,
              )
            : const ColorScheme.light(
                primary: primaryOrange,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: textMain,
              );
        return Theme(data: Theme.of(context).copyWith(colorScheme: scheme), child: child!);
      },
    );
    if (picked != null) {
      provider.setDateOfBirth(picked);
    }
  }

  Future<void> _createAccount(SignUpProvider provider) async {
    final success = await provider.handleCreateAccount(context, _formKey);
    if (success && context.mounted) {
      final isActivated = provider.lastRegisterResponse?.user?.businessAccount?.isActivated ?? true;
      if (isActivated) {
        NavigationService.navigateToReplacementUntil(Routes.dashboardScreen);
      } else {
        NavigationService.navigateToReplacementUntil(Routes.kycVerificationScreen);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>();

    return AuthScaffold(
      heroHeight: 270,
      onBack: () => Navigator.pop(context),
      body: AuthScrollBody(
        children: [
          const AuthHeroIcon(icon: Icons.person_add_alt_1_rounded),
          UIHelper.verticalSpace(12.h),
          AuthHeroTitle(title: 'create_account'.tr, subtitle: 'enter_details_account'.tr),
          UIHelper.verticalSpace(22.h),
          AuthFormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._requiredFields(provider),
                  UIHelper.verticalSpace(22.h),
                  OrDivider(label: 'optional_later'.tr.toUpperCase()),
                  UIHelper.verticalSpace(18.h),
                  ..._optionalFields(provider),
                  UIHelper.verticalSpace(18.h),
                  CustomCheckboxTile(
                    value: provider.acceptTerms,
                    onChanged: provider.setAcceptTerms,
                    label: 'accept_terms'.tr,
                  ),
                  UIHelper.verticalSpace(10.h),
                  CustomCheckboxTile(
                    value: provider.acceptPrivacy,
                    onChanged: provider.setAcceptPrivacy,
                    label: 'accept_privacy'.tr,
                  ),
                  UIHelper.verticalSpace(24.h),
                  GradientButton(
                    label: 'create_account'.tr,
                    trailingIcon: Icons.arrow_forward_rounded,
                    isLoading: provider.isLoading,
                    onPressed: () => _createAccount(provider),
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(22.h),
          AuthLinkPrompt(
            prompt: 'Already have an account?'.tr,
            actionLabel: 'sign_in'.tr,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _requiredFields(SignUpProvider provider) => [
        CustomFieldLabel(label: 'name'.tr),
        CustomFormField(
          controller: provider.nameController,
          hintText: 'full_name'.tr,
          validator: (value) => AuthValidators.required(value, 'err_enter_name'),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'email_address'.tr),
        CustomFormField(
          controller: provider.emailController,
          inputType: TextInputType.emailAddress,
          hintText: 'email@example.com',
          validator: AuthValidators.email,
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'mobile_number'.tr),
        CustomFormField(
          controller: provider.phoneController,
          inputType: TextInputType.phone,
          hintText: '+8801XXXXXXXXX',
          validator: (value) => AuthValidators.required(value, 'err_enter_phone'),
        ),
        UIHelper.verticalSpace(6.h),
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 13.sp, color: AppColorsTheme.textMutedColor(context)),
            UIHelper.horizontalSpace(4.w),
            Expanded(
              child: Text(
                'verification_code_sent_hint'.tr,
                style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
              ),
            ),
          ],
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'password'.tr),
        CustomPasswordField(
          controller: provider.passwordController,
          hintText: 'password'.tr,
          isObscure: provider.obscurePassword,
          onToggleObscure: provider.toggleObscurePassword,
          validator: AuthValidators.strongPassword,
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'confirm_password'.tr),
        CustomPasswordField(
          controller: provider.confirmPasswordController,
          hintText: 'confirm_password'.tr,
          isObscure: provider.obscureConfirmPassword,
          onToggleObscure: provider.toggleObscureConfirmPassword,
          validator: (value) => AuthValidators.confirmPassword(value, provider.passwordController.text),
        ),
      ];

  List<Widget> _optionalFields(SignUpProvider provider) => [
        CustomFieldLabel(label: 'date_of_birth'.tr),
        CustomFormField(
          controller: provider.dobController,
          isRead: true,
          hintText: 'mm/dd/yyyy',
          onTap: () => _selectDateOfBirth(context, provider),
          suffixIcon: IconButton(
            icon: Icon(Icons.calendar_today_outlined, color: primaryOrange, size: 18.sp),
            onPressed: () => _selectDateOfBirth(context, provider),
          ),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'gender'.tr),
        CustomDropdownField<String>(
          value: provider.selectedGender,
          items: provider.genderOptions,
          itemLabelBuilder: (gender) => gender,
          onChanged: provider.setSelectedGender,
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'country'.tr),
        CustomDropdownField<String>(
          value: provider.selectedCountry,
          items: provider.countryOptions,
          itemLabelBuilder: (country) => country,
          onChanged: provider.setSelectedCountry,
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'nationality'.tr),
        CustomFormField(controller: provider.nationalityController, hintText: 'Bangladeshi'),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'partner_code'.tr),
        CustomFormField(controller: provider.partnerCodeController, hintText: 'optional_later'.tr),
      ];
}
