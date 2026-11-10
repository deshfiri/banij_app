import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class KycVerificationProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  String? _nidFrontFileName;
  String? _nidFrontFilePath;
  String? _nidBackFileName;
  String? _nidBackFilePath;
  String? _passportBioFileName;
  String? _passportBioFilePath;
  String? _dlFrontFileName;
  String? _dlFrontFilePath;
  String? _dlBackFileName;
  String? _dlBackFilePath;

  bool _isConfirmed = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  String? get nidFrontFileName => _nidFrontFileName;
  String? get nidBackFileName => _nidBackFileName;
  String? get passportBioFileName => _passportBioFileName;
  String? get dlFrontFileName => _dlFrontFileName;
  String? get dlBackFileName => _dlBackFileName;

  bool get isConfirmed => _isConfirmed;
  bool get isSubmitting => _isSubmitting;
  bool get isSubmitted => _isSubmitted;

  int get nidCount =>
      (_nidFrontFileName != null ? 1 : 0) + (_nidBackFileName != null ? 1 : 0);
  int get passportCount => _passportBioFileName != null ? 1 : 0;
  int get licenseCount =>
      (_dlFrontFileName != null ? 1 : 0) + (_dlBackFileName != null ? 1 : 0);

  int get totalUploadedItems => nidCount + passportCount + licenseCount;

  int get completedGroupsCount {
    int count = 0;
    if (nidCount == 2) count++;
    if (passportCount == 1) count++;
    if (licenseCount == 2) count++;
    return count > 2 ? 2 : count;
  }

  double get progressRatio => totalUploadedItems / 5.0;

  String get overallStatusKey {
    if (totalUploadedItems == 0) return 'not_started';
    if (totalUploadedItems == 5) return 'complete';
    return 'in_progress';
  }

  List<Map<String, String>> get stillNeededList {
    List<Map<String, String>> list = [];
    if (_nidFrontFileName == null) {
      list.add({
        'key': 'nidFront',
        'text': 'Personal Information Verification — NID Verification: Front Side Verification'
      });
    }
    if (_nidBackFileName == null) {
      list.add({
        'key': 'nidBack',
        'text': 'Personal Information Verification — NID Verification: Back Side Verification'
      });
    }
    if (_passportBioFileName == null) {
      list.add({
        'key': 'passportBio',
        'text': 'Personal Information Verification — Passport Verification: Passport Bio-data Page'
      });
    }
    if (_dlFrontFileName == null) {
      list.add({
        'key': 'dlFront',
        'text': 'Personal Information Verification — Driving License Verification: Driving License Front Side'
      });
    }
    if (_dlBackFileName == null) {
      list.add({
        'key': 'dlBack',
        'text': 'Personal Information Verification — Driving License Verification: Driving License Back Side'
      });
    }
    return list;
  }

  Future<void> pickFile(String docKey) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _assignFile(docKey, image.name, image.path);
      }
    } catch (e) {
      _assignFile(docKey, '${docKey}_document.png', null);
    }
    notifyListeners();
  }

  void _assignFile(String docKey, String name, String? path) {
    switch (docKey) {
      case 'nidFront':
        _nidFrontFileName = name;
        _nidFrontFilePath = path;
        break;
      case 'nidBack':
        _nidBackFileName = name;
        _nidBackFilePath = path;
        break;
      case 'passportBio':
        _passportBioFileName = name;
        _passportBioFilePath = path;
        break;
      case 'dlFront':
        _dlFrontFileName = name;
        _dlFrontFilePath = path;
        break;
      case 'dlBack':
        _dlBackFileName = name;
        _dlBackFilePath = path;
        break;
    }
  }

  void toggleConfirmation(bool? val) {
    _isConfirmed = val ?? false;
    notifyListeners();
  }

  Future<void> submitVerification(BuildContext context) async {
    if (!_isConfirmed || _isSubmitting || _isSubmitted) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      if (_nidFrontFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'national_id_front',
          fileBytesOrPath: _nidFrontFilePath,
          fileName: _nidFrontFileName,
        ).waitingForSucess();
      }
      if (_nidBackFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'national_id_back',
          fileBytesOrPath: _nidBackFilePath,
          fileName: _nidBackFileName,
        ).waitingForSucess();
      }
      if (_passportBioFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'passport',
          fileBytesOrPath: _passportBioFilePath,
          fileName: _passportBioFileName,
        ).waitingForSucess();
      }
      if (_dlFrontFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'driving_license_front',
          fileBytesOrPath: _dlFrontFilePath,
          fileName: _dlFrontFileName,
        ).waitingForSucess();
      }
      if (_dlBackFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'driving_license_back',
          fileBytesOrPath: _dlBackFilePath,
          fileName: _dlBackFileName,
        ).waitingForSucess();
      }

      _isSubmitting = false;
      _isSubmitted = true;
      notifyListeners();
      ToastUtil.showSuccessMessage('KYC documents submitted successfully!');
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('Failure')) {
        errorMsg = 'Failed to submit KYC documents. Please try again.';
      }
      ToastUtil.showErrorMessage(errorMsg);
    }
  }

  void resetKycForm() {
    _nidFrontFileName = null;
    _nidFrontFilePath = null;
    _nidBackFileName = null;
    _nidBackFilePath = null;
    _passportBioFileName = null;
    _passportBioFilePath = null;
    _dlFrontFileName = null;
    _dlFrontFilePath = null;
    _dlBackFileName = null;
    _dlBackFilePath = null;
    _isConfirmed = false;
    _isSubmitting = false;
    _isSubmitted = false;
    notifyListeners();
  }
}
