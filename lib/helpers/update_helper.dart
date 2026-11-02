// ignore_for_file: must_be_immutable

import 'package:bbnij/helpers/ui_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../gen/colors.gen.dart';

class CustomRejectDialog extends StatelessWidget {
  Color? icon;
  IconData? iconData;
  String? title;
  String? subttile;
  String? btnName;
  Color? btnColor;
  String? ammount;
  String? btnName1;
  String text;
  VoidCallback? rejectbtn;

  CustomRejectDialog({
    super.key,
    this.title,
    this.subttile,
    this.iconData,
    this.icon,
    this.ammount,
    this.btnColor,
    this.btnName,
    required this.text,
    this.btnName1,
    this.rejectbtn,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ❌ ICON
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: icon ?? Color(0xFFE74C3C),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData ?? Icons.close,
                color: Colors.white,
                size: 36,
              ),
            ),

            UIHelper.verticalSpace(8.h),
            // 🔴 TITLE
            Text(
              title ?? "Request Rejected",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            UIHelper.verticalSpace(8.h),

            // 📝 DESCRIPTION
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.c000000),
            ),

            const SizedBox(height: 20),

            // 🔘 BUTTONS
            Row(
              children: [
                // Go Back
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Center(
                        child: Text(
                          btnName1 ?? "Go Back",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Reject Button
                Expanded(
                  child: GestureDetector(
                    onTap: rejectbtn,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: btnColor ?? const Color(0xFFE74C3C),
                      ),
                      child: Center(
                        child: Text(
                          btnName ?? "Reject",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: must_be_immutable

class CustomStatusDialog extends StatelessWidget {
  final Color? iconColor;
  final IconData? iconData;
  final String? title;
  final Color? titleColor;
  final Color? subTitleColor;
  final String? message;
  final String? amount;

  /// First Button (Optional)
  final String? firstButtonText;
  final VoidCallback? firstButtonTap;

  /// Second Button (Optional)
  final String? secondButtonText;
  final VoidCallback? secondButtonTap;

  /// Main Button Color
  final List<Color>? gradientColors;

  const CustomStatusDialog({
    super.key,
    this.iconColor,
    this.iconData,
    this.title,
    this.titleColor,
    this.subTitleColor,
    this.message,
    this.amount,
    this.firstButtonText,
    this.firstButtonTap,
    this.secondButtonText,
    this.secondButtonTap,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTwoButtons =
        firstButtonText != null && secondButtonText != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// TOP ICON
            Container(
              height: 90.w,
              width: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 5,
                  color: iconColor ?? const Color(0xff5B4DFF),
                ),
              ),
              child: Icon(
                iconData ?? Icons.check,
                size: 42.sp,
                color: iconColor ?? const Color(0xff5B4DFF),
              ),
            ),

            UIHelper.verticalSpace(22.h),

            /// TITLE
            Text(
              title ?? "Congratulations!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
                color: titleColor ?? Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            /// MESSAGE
            Text(
              message.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color: subTitleColor ?? Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 28),

            /// BUTTON SECTION
            hasTwoButtons
                ? Row(
                    children: [
                      /// First Button
                      Expanded(
                        child: _buildOutlinedButton(
                          text: firstButtonText!,
                          onTap: firstButtonTap ?? () => Navigator.pop(context),
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// Second Button
                      Expanded(
                        child: _buildGradientButton(
                          text: secondButtonText!,
                          onTap:
                              secondButtonTap ?? () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  )
                : SizedBox(
                    width: double.infinity,
                    child: _buildGradientButton(
                      text: secondButtonText ?? "Done",
                      onTap: secondButtonTap ?? () => Navigator.pop(context),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  /// Gradient Button
  Widget _buildGradientButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors:
                gradientColors ?? const [Color(0xff3D3BFF), Color(0xffD94CFF)],
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  /// Outlined Button
  Widget _buildOutlinedButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

void showEditAmountDialog(
  BuildContext context,
  String rowId,
  String reqNo,
  String crNo,
) {
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<void> updateAmount() async {
    if (!formKey.currentState!.validate()) return;

    /// close input dialog
    Navigator.pop(context);

    /// API call
    // final response = await editAmountRxObj.updateAmount(
    //   rowId,
    //   reqNo,
    //   crNo,
    //   amountController.text.trim(),
    // );

    /// safety check
    if (!context.mounted) return;

    /// show result dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CustomStatusDialog(
        // iconData: response.success == true
        //     ? Icons.check_circle
        //     : Icons.error_outline,
        // title: response.success == true ? "Success" : "Failed",
        // message: response.message,
        // iconColor: response.success == true ? Colors.green : Colors.red,
        // secondButtonText: "Done",
        // secondButtonTap: () {
        //   Navigator.pop(context);
        // },


      )


      ,
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_outlined, size: 35, color: Colors.black54),
              const SizedBox(height: 10),

              const Text(
                "Edit Amount",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixText: "৳ ",
                  hintText: "Enter Amount",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Please enter amount";
                  }

                  if (double.tryParse(value.trim()) == null) {
                    return "Enter valid amount";
                  }

                  if (double.parse(value.trim()) <= 0) {
                    return "Amount must be greater than 0";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: updateAmount,
                      child: const Text("Approve"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
