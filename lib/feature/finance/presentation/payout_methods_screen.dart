import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../dashboard/model/location_division_model.dart';
import '../../dashboard/model/payment_model.dart';
import '../model/bank_model.dart';
import 'widgets/payout_methods/payout_method_form_sheet.dart';
import 'widgets/payout_methods/payout_method_tile.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  static const String _intro =
      'Where your withdrawals are paid. Only the last four digits are ever shown again after saving.';

  List<BankItemModel> _loadedBanks = [];
  List<DivisionData> _loadedDivisions = [];
  final PayoutFormCache _formCache = PayoutFormCache();
  PaymentMethodResponseModel? _paymentResponseModel;

  /// Shown until the API returns methods/types. Kept as maps: the form
  /// sheet's edit mode reads `id`, `title` and `isDefault` from them.
  final List<Map<String, dynamic>> _payoutMethods = [
    {
      'id': '01M77QBDG2C1RCV76J97VCXNY8',
      'title': 'bKash Personal',
      'detail': 'Mohammad Ashraf (****5832)',
      'isDefault': true,
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': '01M77QBDG2C1RCV76J97VCXNY9',
      'title': 'City Bank Account',
      'detail': 'Mohammad Ashraf (****4912)',
      'isDefault': false,
      'icon': Icons.account_balance_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBanks();
    _fetchPaymentMethods();
    _fetchDivisions();
  }

  Future<void> _fetchBanks() async {
    try {
      final res = await bankRxObj.fetchBankList();
      if (res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() => _loadedBanks = res.data!);
      }
    } catch (_) {}
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final res = await paymentRxObj.fetchPaymentMethods();
      if (mounted) setState(() => _paymentResponseModel = res);
    } catch (_) {}
  }

  Future<void> _fetchDivisions() async {
    try {
      final res = await locationDivisionRxObj.fetchDivisions();
      if (res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() => _loadedDivisions = res.data!);
      }
    } catch (_) {}
  }

  void _showAddMethodModal({dynamic existingMethod}) {
    PayoutMethodFormSheet.show(
      context,
      existingMethod: existingMethod,
      banks: () => _loadedBanks,
      divisions: () => _loadedDivisions,
      cache: _formCache,
      onSaved: _fetchPaymentMethods,
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [primaryOrange, secondaryOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button, White Logo & Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  Image.asset(
                    whiteLogo,
                    width: 105.w,
                    height: 34.h,
                    fit: BoxFit.contain,
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddMethodModal,
                    icon: Icon(Icons.add_circle_outline_rounded, size: 14.sp, color: primaryOrange),
                    label: Text('Add', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              // Title & Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payout methods'.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      _intro.tr,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiMethods = _paymentResponseModel?.data ?? [];
    final apiTypes = _paymentResponseModel?.types ?? [];
    final hasApiMethods = apiMethods.isNotEmpty || apiTypes.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hasApiMethods
                        ? (apiMethods.isNotEmpty ? apiMethods.length : apiTypes.length)
                        : _payoutMethods.length,
                    itemBuilder: (context, index) => hasApiMethods
                        ? _buildApiTile(apiMethods, apiTypes, index)
                        : _buildLocalTile(index),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Saved methods from the API, or (when none) the available method types.
  Widget _buildApiTile(List<PaymentMethodModel> apiMethods, List<PaymentTypeModel> apiTypes, int index) {
    final fromMethods = apiMethods.isNotEmpty;
    final item = fromMethods ? apiMethods[index] : null;

    return PayoutMethodTile(
      icon: Icons.account_balance_wallet_rounded,
      title: fromMethods
          ? (apiMethods[index].name ?? 'Payout Method')
          : (apiTypes[index].label ?? apiTypes[index].value ?? 'Payout Method'),
      subtitle: fromMethods
          ? (apiMethods[index].description ?? 'Configured account')
          : 'Fields: ${apiTypes[index].fields?.join(", ") ?? ""}',
      redArchiveLabel: true,
      onEdit: () => _showAddMethodModal(existingMethod: item),
      onArchive: () => ToastUtil.showSuccessMessage('Payout method archived'),
    );
  }

  /// Built-in placeholder methods (archive removes them locally).
  Widget _buildLocalTile(int index) {
    final item = _payoutMethods[index];

    return PayoutMethodTile(
      icon: item['icon'],
      title: item['title'],
      subtitle: item['detail'],
      isDefault: item['isDefault'] == true,
      titleInRow: true,
      onEdit: () => _showAddMethodModal(existingMethod: item),
      onArchive: () {
        setState(() => _payoutMethods.removeAt(index));
        ToastUtil.showSuccessMessage('Payout method archived');
      },
    );
  }
}
