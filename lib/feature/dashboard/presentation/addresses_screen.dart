import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/address_model.dart';
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
    final mainColor = AppColorsTheme.textMainColor(context);

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.background(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Addresses',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: mainColor),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToAddAddress(),
                icon: Icon(Icons.add_rounded, size: 16.sp),
                label: Text('Add address', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const AddressListShimmer()
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Addresses',
                    style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: mainColor),
                  ),
                  UIHelper.verticalSpace(4.h),
                  Text(
                    'Your business and operational addresses.',
                    style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                  ),
                  UIHelper.verticalSpace(16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToAddAddress(),
                      icon: Icon(Icons.add_location_alt_rounded, size: 18.sp),
                      label: Text('Add address', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: hasApiAddresses ? apiAddresses.length : _dummyAddresses.length,
                    itemBuilder: (context, index) =>
                        hasApiAddresses ? _apiAddressCard(apiAddresses[index]) : _sampleAddressCard(index),
                  ),
                ],
              ),
            ),
    );
  }
}
