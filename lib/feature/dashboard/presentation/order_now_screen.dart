import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/cart_provider.dart';
import '../model/my_product_model.dart';

class OrderNowScreen extends StatefulWidget {
  final ProductItemModel? product;

  const OrderNowScreen({
    super.key,
    this.product,
  });

  @override
  State<OrderNowScreen> createState() => _OrderNowScreenState();
}

class _OrderNowScreenState extends State<OrderNowScreen> {
  final TextEditingController _nameController = TextEditingController(text: 'MD. Rahim Uddin');
  final TextEditingController _phoneController = TextEditingController(text: '+880 1712-345678');
  final TextEditingController _addressController = TextEditingController(text: 'House # 42, Road # 11, Banani, Dhaka');
  final TextEditingController _notesController = TextEditingController();

  String _selectedPaymentMethod = 'Cash on Delivery';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _placeOrder(CartProvider cartProvider) {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ToastUtil.showErrorMessage('Please fill in all required delivery details');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        cartProvider.clearCart();
        _showSuccessDialog(context);
      }
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 54.sp,
                  color: const Color(0xFF10B981),
                ),
              ),
              UIHelper.verticalSpace(20.h),
              Text(
                'Order Placed Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(8.h),
              Text(
                'Your wholesale order has been placed successfully and is now being processed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColorsTheme.textMutedColor(context),
                  height: 1.4,
                ),
              ),
              UIHelper.verticalSpace(24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.dashboardScreen,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Back to Dashboard',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    final cartProvider = context.watch<CartProvider>();
    final isDirectProduct = widget.product != null;

    final subtotal = isDirectProduct ? 150.0 : cartProvider.subtotal;
    final deliveryFee = isDirectProduct ? 60.0 : cartProvider.deliveryFee;
    final grandTotal = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColorsTheme.textMainColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Checkout'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Delivery Address Section
              Text(
                'DELIVERY INFORMATION',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMutedColor(context),
                  letterSpacing: 0.8,
                ),
              ),
              UIHelper.verticalSpace(10.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      context: context,
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                    ),
                    UIHelper.verticalSpace(12.h),
                    _buildTextField(
                      context: context,
                      label: 'Phone Number',
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    UIHelper.verticalSpace(12.h),
                    _buildTextField(
                      context: context,
                      label: 'Delivery Address',
                      controller: _addressController,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    UIHelper.verticalSpace(12.h),
                    _buildTextField(
                      context: context,
                      label: 'Delivery Notes (Optional)',
                      controller: _notesController,
                      icon: Icons.note_alt_outlined,
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(20.h),

              // 2. Payment Method Section
              Text(
                'PAYMENT METHOD',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMutedColor(context),
                  letterSpacing: 0.8,
                ),
              ),
              UIHelper.verticalSpace(10.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Column(
                  children: [
                    _buildPaymentTile(
                      context: context,
                      title: 'Cash on Delivery',
                      subtitle: 'Pay with cash upon delivery receipt',
                      icon: Icons.money_rounded,
                      value: 'Cash on Delivery',
                    ),
                    Divider(height: 1, color: AppColorsTheme.borderColor(context)),
                    _buildPaymentTile(
                      context: context,
                      title: 'bKash / Nagad Mobile Wallet',
                      subtitle: 'Instant mobile financial payment',
                      icon: Icons.phone_android_rounded,
                      value: 'Mobile Wallet',
                    ),
                    Divider(height: 1, color: AppColorsTheme.borderColor(context)),
                    _buildPaymentTile(
                      context: context,
                      title: 'Credit / Debit Card',
                      subtitle: 'Visa, MasterCard, or Amex',
                      icon: Icons.credit_card_rounded,
                      value: 'Card',
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(20.h),

              // 3. Order Summary Section
              Text(
                'ORDER SUMMARY',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorsTheme.textMutedColor(context),
                  letterSpacing: 0.8,
                ),
              ),
              UIHelper.verticalSpace(10.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isDirectProduct ? 'Product Subtotal' : 'Items Subtotal (${cartProvider.totalItemsCount})',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                        Text(
                          '৳ ${subtotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Delivery Fee',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                        Text(
                          '৳ ${deliveryFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(12.h),
                    Divider(color: AppColorsTheme.borderColor(context)),
                    UIHelper.verticalSpace(10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        Text(
                          '৳ ${grandTotal.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(24.h),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _placeOrder(cartProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Place Order Now (৳ ${grandTotal.toStringAsFixed(2)})',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
        UIHelper.verticalSpace(6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.background(context),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
          ),
          child: Row(
            crossAxisAlignment: maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: maxLines > 1 ? 12.h : 0),
                child: Icon(icon, size: 18.sp, color: primaryOrange),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isSelected ? primaryOrange.withValues(alpha: 0.15) : AppColorsTheme.background(context),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: isSelected ? primaryOrange : AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              activeColor: primaryOrange,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedPaymentMethod = val;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
