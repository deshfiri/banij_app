// ignore_for_file: file_names
// import 'package:flutter/material.dart';

// class AddSpecialMomentsProvider extends ChangeNotifier {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController dateController = TextEditingController();
//   final TextEditingController noteController = TextEditingController();
//   final List<TextEditingController> _otherControllers = [];

//   List<TextEditingController> get otherControllers => _otherControllers;

//   AddSpecialMomentsProvider() {
//     titleController.addListener(_onChanged);
//     dateController.addListener(_onChanged);
//     noteController.addListener(_onChanged);
//   }

//   void addOtherController() {
//     final controller = TextEditingController();
//     controller.addListener(_onChanged);
//     _otherControllers.add(controller);
//     notifyListeners();
//   }

//   void removeOtherController(int index) {
//     _otherControllers[index].removeListener(_onChanged);
//     _otherControllers[index].dispose();
//     _otherControllers.removeAt(index);
//     notifyListeners();
//   }

//   void _onChanged() {
//     notifyListeners();
//   }

//   bool get isFormValid {
//     return titleController.text.trim().isNotEmpty &&
//         dateController.text.trim().isNotEmpty &&
//         noteController.text.trim().isNotEmpty &&
//         _otherControllers.every((c) => c.text.trim().isNotEmpty);
//   }

//   void disposeAll() {
//     titleController.dispose();
//     dateController.dispose();
//     noteController.dispose();
//     for (var c in _otherControllers) {
//       c.dispose();
//     }
//   }
// }
