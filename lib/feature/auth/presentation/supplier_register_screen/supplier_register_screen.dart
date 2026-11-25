import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/custom_password_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/supplier_register_provider.dart';
import '../widgets/auth_components.dart';
import '../widgets/auth_form_card.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_validators.dart';

/// Three-step supplier registration: business → contact & documents → security.
class SupplierRegisterScreen extends StatefulWidget {
  const SupplierRegisterScreen({super.key});

  @override
  State<SupplierRegisterScreen> createState() => _SupplierRegisterScreenState();
}

/// Icon, title key and subtitle key for each step's section header.
class _SupplierStep {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;

  const _SupplierStep(this.icon, this.titleKey, this.subtitleKey);

  static const List<_SupplierStep> all = [
    _SupplierStep(Icons.business_rounded, 'business_information', 'business_info_subtitle'),
    _SupplierStep(Icons.email_outlined, 'contact_and_documents', 'contact_and_documents_subtitle'),
    _SupplierStep(Icons.lock_outline_rounded, 'account_security', 'account_security_subtitle'),
  ];
}

class _SupplierRegisterScreenState extends State<SupplierRegisterScreen> {
  late final SupplierRegisterProvider _formProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Looked up once here: providers cannot be read from a disposed context.
    _formProvider = context.read<SupplierRegisterProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _formProvider.resetSupplierForm());
  }

  @override
  void dispose() {
    // Reset after this frame: notifying listeners while the tree is being
    // torn down would throw.
    final provider = _formProvider;
    WidgetsBinding.instance.addPostFrameCallback((_) => provider.resetSupplierForm());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierRegisterProvider>();
    final step = _SupplierStep.all[(provider.currentStep - 1).clamp(0, _SupplierStep.all.length - 1)];

    return AuthScaffold(
      heroHeight: 260,
      onBack: () => provider.handleBack(context),
      body: AuthScrollBody(
        children: [
          AuthHeroTag(label: 'supplier_registration'.tr.toUpperCase()),
          UIHelper.verticalSpace(12.h),
          AuthHeroTitle(title: 'become_a_supplier'.tr, subtitle: 'supplier_subtitle'.tr),
          UIHelper.verticalSpace(22.h),
          AuthFormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthStepIndicator(
                    titles: ['step_business'.tr, 'step_contact'.tr, 'step_security'.tr],
                    currentStep: provider.currentStep,
                  ),
                  UIHelper.verticalSpace(18.h),
                  Divider(color: AppColorsTheme.borderColor(context), height: 1),
                  UIHelper.verticalSpace(18.h),
                  AuthSectionHeader(icon: step.icon, title: step.titleKey.tr, subtitle: step.subtitleKey.tr),
                  UIHelper.verticalSpace(20.h),
                  if (provider.currentStep == 1) ..._businessFields(provider),
                  if (provider.currentStep == 2) ..._contactFields(provider),
                  if (provider.currentStep == 3) ..._securityFields(provider),
                  UIHelper.verticalSpace(26.h),
                  Row(
                    children: [
                      Expanded(
                        child: AuthOutlinedButton(
                          label: 'back'.tr,
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => provider.handleBack(context),
                        ),
                      ),
                      UIHelper.horizontalSpace(12.w),
                      Expanded(
                        flex: 2,
                        child: GradientButton(
                          label: provider.currentStep == 3 ? 'create_supplier_account'.tr : 'continue'.tr,
                          isLoading: provider.isLoading,
                          onPressed: () => provider.handleContinue(context, _formKey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(22.h),
          AuthLinkPrompt(
            prompt: 'already_supplier'.tr,
            actionLabel: 'sign_in'.tr,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _businessFields(SupplierRegisterProvider provider) => [
        CustomFieldLabel(label: 'business_name'.tr, isRequired: true),
        CustomFormField(
          controller: provider.businessNameController,
          hintText: 'enter_business_name'.tr,
          validator: (val) => AuthValidators.required(val, 'err_enter_business_name'),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'contact_person'.tr, isRequired: true),
        CustomFormField(
          controller: provider.contactPersonController,
          hintText: 'enter_contact_person'.tr,
          validator: (val) => AuthValidators.required(val, 'err_enter_contact_person'),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'business_address'.tr, isRequired: true),
        CustomFormField(
          controller: provider.businessAddressController,
          maxline: 4,
          hintText: 'enter_business_address'.tr,
          validator: (val) => AuthValidators.required(val, 'err_enter_business_address'),
        ),
      ];

  List<Widget> _contactFields(SupplierRegisterProvider provider) => [
        CustomFieldLabel(label: 'email_address'.tr, isRequired: true),
        CustomFormField(
          controller: provider.emailController,
          inputType: TextInputType.emailAddress,
          hintText: 'email@example.com',
          validator: AuthValidators.email,
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'phone_number'.tr, isRequired: true),
        CustomFormField(
          controller: provider.phoneController,
          inputType: TextInputType.phone,
          hintText: '+8801XXXXXXXXX',
          validator: (val) => AuthValidators.required(val, 'err_enter_phone'),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'trade_licence_optional'.tr, isRequired: false),
        CustomFormField(controller: provider.tradeLicenceController, hintText: 'Trade licence number'.tr),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'tin_optional'.tr, isRequired: false),
        CustomFormField(controller: provider.tinController, hintText: 'Tax identification number'.tr),
      ];

  List<Widget> _securityFields(SupplierRegisterProvider provider) => [
        CustomFieldLabel(label: 'password'.tr, isRequired: true),
        CustomPasswordField(
          controller: provider.passwordController,
          hintText: 'create_password'.tr,
          isObscure: provider.obscurePassword,
          onToggleObscure: provider.toggleObscurePassword,
          validator: AuthValidators.strongPassword,
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'confirm_password'.tr, isRequired: true),
        CustomPasswordField(
          controller: provider.confirmPasswordController,
          hintText: 'confirm_password'.tr,
          isObscure: provider.obscureConfirmPassword,
          onToggleObscure: provider.toggleObscureConfirmPassword,
          validator: (val) => AuthValidators.confirmPassword(val, provider.passwordController.text),
        ),
      ];
}
