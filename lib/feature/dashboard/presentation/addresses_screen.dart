import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/address_model.dart';
import 'widgets/commerce/address_form_widgets.dart';
import 'widgets/commerce/address_widgets.dart';

/// Business tools › Addresses: the account's saved addresses (default one
/// highlighted) with Edit, and Add address.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  AddressResponseModel? _addressResponseModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  /// [showLoader] is false for pull-to-refresh, which keeps the list.
  Future<void> _fetchAddresses({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    try {
      final res = await addressRxObj.fetchAddresses();
      if (mounted) {
        setState(() {
          _addressResponseModel = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToAddAddress([AddressItemModel? address]) {
    Navigator.pushNamed(context, Routes.addAddressScreen, arguments: address).then((_) {
      if (mounted) _fetchAddresses(showLoader: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Default address first, then the API order.
    final addresses = [...?_addressResponseModel?.data]
      ..sort((a, b) => (b.isDefault == true ? 1 : 0) - (a.isDefault == true ? 1 : 0));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Addresses',
              subtitle: 'Your business, operational and shipping addresses.',
              trailing: HeroIconButton(
                icon: Icons.add_location_alt_rounded,
                onTap: () => _navigateToAddAddress(),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const AddressListShimmer()
                  : RefreshIndicator(
                      color: primaryOrange,
                      onRefresh: () => _fetchAddresses(showLoader: false),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                        child: AddressContentFrame(
                          maxWidth: 1000,
                          child: addresses.isEmpty
                              ? AddressEmptyState(onAdd: () => _navigateToAddAddress())
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AddressCountHeader(count: addresses.length),
                                    UIHelper.verticalSpace(12.h),
                                    ResponsiveCardGrid(
                                      children: [
                                        for (final item in addresses)
                                          AddressCard(
                                            name: item.contactName ?? item.recipientName,
                                            type: item.type ?? 'business',
                                            phone: item.contactMobile ?? item.phone,
                                            fullAddress: item.fullAddressFormatted,
                                            isDefault: item.isDefault == true,
                                            onEdit: () => _navigateToAddAddress(item),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: AddressBottomBar(
          label: 'Add address',
          icon: Icons.add_location_alt_rounded,
          onPressed: () => _navigateToAddAddress(),
        ),
      ),
    );
  }
}
