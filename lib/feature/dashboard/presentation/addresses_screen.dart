import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/address_model.dart';
import 'widgets/commerce/address_form_widgets.dart';
import 'widgets/commerce/address_widgets.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  AddressResponseModel? _addressResponseModel;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _dummyAddresses = [
    {
      'name': 'Md Hira',
      'type': 'BUSINESS',
      'phone': '+88019005831',
      'address': 'dadad, Bokshiganj, Jamalpur, Mymensingh, 1207',
      'isDefault': false,
    },
    {
      'name': 'MD Hira',
      'type': 'BUSINESS',
      'phone': '+8801619005831',
      'address': 'eqeqeqeqe, Rajapur, Jhalakathi, Barisal, aeaeae',
      'isDefault': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
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
      _fetchAddresses();
    });
  }

  /// Card for an address returned by the API.
  Widget _apiAddressCard(AddressItemModel item) {
    return AddressCard(
      name: item.contactName ?? item.recipientName,
      type: item.type ?? 'BUSINESS',
      phone: item.contactMobile ?? item.phone,
      fullAddress: item.fullAddressFormatted,
      isDefault: item.isDefault == true,
      onEdit: () => _navigateToAddAddress(item),
      onSetDefault: () => ToastUtil.showSuccessMessage('Address set as default'),
      onArchive: () => ToastUtil.showSuccessMessage('Address archived'),
    );
  }

  /// Card for a built-in sample address (shown when the API returned none).
  Widget _sampleAddressCard(int index) {
    final item = _dummyAddresses[index];
    return AddressCard(
      name: item['name'],
      type: item['type'],
      phone: item['phone'],
      fullAddress: item['address'],
      isDefault: item['isDefault'] == true,
      onEdit: () => _navigateToAddAddress(),
      onSetDefault: () {
        setState(() {
          for (var a in _dummyAddresses) {
            a['isDefault'] = false;
          }
          item['isDefault'] = true;
        });
        ToastUtil.showSuccessMessage('Address set as default');
      },
      onArchive: () {
        setState(() {
          _dummyAddresses.removeAt(index);
        });
        ToastUtil.showSuccessMessage('Address archived');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiAddresses = _addressResponseModel?.data ?? [];
    final hasApiAddresses = apiAddresses.isNotEmpty;
    final count = hasApiAddresses ? apiAddresses.length : _dummyAddresses.length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Addresses',
              subtitle: 'Your business and operational addresses.',
              trailing: HeroIconButton(
                icon: Icons.add_location_alt_rounded,
                onTap: () => _navigateToAddAddress(),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const AddressListShimmer()
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
                      child: AddressContentFrame(
                        maxWidth: 1000,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AddressCountHeader(count: count),
                            UIHelper.verticalSpace(12.h),
                            ResponsiveCardGrid(
                              children: [
                                for (var index = 0; index < count; index++)
                                  hasApiAddresses ? _apiAddressCard(apiAddresses[index]) : _sampleAddressCard(index),
                              ],
                            ),
                          ],
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
