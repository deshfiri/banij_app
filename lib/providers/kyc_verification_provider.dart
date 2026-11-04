import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class KycVerificationProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  String? _nidFrontFileName;
  String? _nidBackFileName;
  String? _passportBioFileName;
  String? _dlFrontFileName;
  String? _dlBackFileName;

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
        final name = image.name;
        _assignFileName(docKey, name);
      }
    } catch (e) {
      // Fallback sample file name if picking fails or simulator does not provide file
      _assignFileName(docKey, '${docKey}_document.png');
    }
    notifyListeners();
  }

  void _assignFileName(String docKey, String name) {
    switch (docKey) {
      case 'nidFront':
        _nidFrontFileName = name;
        break;
      case 'nidBack':
        _nidBackFileName = name;
        break;
      case 'passportBio':
        _passportBioFileName = name;
        break;
      case 'dlFront':
        _dlFrontFileName = name;
        break;
      case 'dlBack':
        _dlBackFileName = name;
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

    await Future.delayed(const Duration(milliseconds: 1200));

    _isSubmitting = false;
    _isSubmitted = true;
    notifyListeners();
  }

  void resetKycForm() {
    _nidFrontFileName = null;
    _nidBackFileName = null;
    _passportBioFileName = null;
    _dlFrontFileName = null;
    _dlBackFileName = null;
    _isConfirmed = false;
    _isSubmitting = false;
    _isSubmitted = false;
    notifyListeners();
  }
}
