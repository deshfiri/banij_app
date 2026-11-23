import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../helpers/error_message.dart';
import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class KycVerificationProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  String? _nationalIdFileName;
  String? _nationalIdFilePath;
  String? _proofOfAddressFileName;
  String? _proofOfAddressFilePath;
  String? _tradeLicenceFileName;
  String? _tradeLicenceFilePath;
  final TextEditingController tinController = TextEditingController();

  bool _isConfirmed = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  String? get nationalIdFileName => _nationalIdFileName;
  String? get proofOfAddressFileName => _proofOfAddressFileName;
  String? get tradeLicenceFileName => _tradeLicenceFileName;

  bool get isConfirmed => _isConfirmed;
  bool get isSubmitting => _isSubmitting;
  bool get isSubmitted => _isSubmitted;

  int get uploadedRequiredCount =>
      (_nationalIdFileName != null ? 1 : 0) +
      (_proofOfAddressFileName != null ? 1 : 0) +
      (_tradeLicenceFileName != null ? 1 : 0);

  double get progressRatio => uploadedRequiredCount / 3.0;

  String get overallStatusKey {
    if (uploadedRequiredCount == 0) return 'not_started';
    if (uploadedRequiredCount == 3) return 'complete';
    return 'in_progress';
  }

  List<Map<String, String>> get stillNeededList {
    List<Map<String, String>> list = [];
    if (_nationalIdFileName == null) {
      list.add({
        'key': 'national_id',
        'text': 'National ID — Upload both sides in color with four corners visible'
      });
    }
    if (_proofOfAddressFileName == null) {
      list.add({
        'key': 'proof_of_address',
        'text': 'Proof of address — Utility bill or bank statement from last 3 months'
      });
    }
    if (_tradeLicenceFileName == null) {
      list.add({
        'key': 'trade_licence',
        'text': 'Trade licence — Current year trade licence issued by city corporation'
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
      case 'national_id':
        _nationalIdFileName = name;
        _nationalIdFilePath = path;
        break;
      case 'proof_of_address':
        _proofOfAddressFileName = name;
        _proofOfAddressFilePath = path;
        break;
      case 'trade_licence':
        _tradeLicenceFileName = name;
        _tradeLicenceFilePath = path;
        break;
    }
  }

  void toggleConfirmation(bool? val) {
    _isConfirmed = val ?? false;
    notifyListeners();
  }

  Future<void> submitVerification(BuildContext context) async {
    if (!_isConfirmed || _isSubmitting || _isSubmitted) return;

    if (uploadedRequiredCount < 3) {
      ToastUtil.showErrorMessage('Please upload all required KYC documents');
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    try {
      if (_nationalIdFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'national_id',
          fileBytesOrPath: _nationalIdFilePath,
          fileName: _nationalIdFileName,
        ).waitingForSucess();
      }
      if (_proofOfAddressFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'proof_of_address',
          fileBytesOrPath: _proofOfAddressFilePath,
          fileName: _proofOfAddressFileName,
        ).waitingForSucess();
      }
      if (_tradeLicenceFileName != null) {
        await kycRxObj.submitDoc(
          documentType: 'trade_licence',
          fileBytesOrPath: _tradeLicenceFilePath,
          fileName: _tradeLicenceFileName,
        ).waitingForSucess();
      }
      if (tinController.text.trim().isNotEmpty) {
        await kycRxObj.submitDoc(
          documentType: 'tin',
          value: tinController.text.trim(),
        ).waitingForSucess();
      }

      _isSubmitting = false;
      _isSubmitted = true;
      notifyListeners();
      ToastUtil.showSuccessMessage('KYC documents submitted successfully!');
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _isSubmitting = false;
      notifyListeners();
      String errorMsg = e.apiErrorMessage;
      ToastUtil.showErrorMessage(errorMsg.isNotEmpty ? errorMsg : 'Failed to submit KYC documents');
    }
  }

  @override
  void dispose() {
    tinController.dispose();
    super.dispose();
  }
}
