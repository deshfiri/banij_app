// import 'dart:io';

// import 'package:colten_app/common_widget/custom_drop_down_widget_two.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class PartnerInfoProvider extends ChangeNotifier {
//   String _name = '';
//   String _dob = '';
//   String _anniversary = '';
//   int? _selectedIndex;
//   String food = '';
//   String restaturent = '';
//   String dreamVacation = '';
//   String musicGenre = '';
//   String color = '';
//   String hobby = '';
//   String favouriteActivity = '';
//   String favouriteWay = '';
//   String place = '';
//   String title = '';
//   String specialDate = '';
//   String note = '';
//   String archiveTitle = '';
//   String archiveDate = '';
//   String archiveNote = '';
//   String _gender = '';

//   List<String> others = [];

//   DropdownItemModel? _relation;
//   DropdownItemModel? _language;
//   DropdownItemModel? _proximity;
//   DropdownItemModel? get relation => _relation;
//   DropdownItemModel? get language => _language;
//   DropdownItemModel? get proximity => _proximity;

//   String get relationLabel => _relation?.label ?? '';
//   String get languageLabel => _language?.label ?? '';
//   String get proximityLabel => _proximity?.label ?? '';
//   String get name => _name;
//   String get dob => _dob;
//   String get anniversary => _anniversary;
//   int? get selectedIndex => _selectedIndex;
//   bool get isGenderSelected => _selectedIndex != null;
//   String get selectedGender => _gender;
//   File? partnerPhoto;
//   List<XFile> archiveImages = [];
//   List<XFile> specialMomentImages = [];
//   final List<TextEditingController> favouriteControllers = [];
//   final List<String> favouriteDescription = [];

//   // DropdownItemModel? get relation => _relation;
//   // DropdownItemModel? get language => _language;
//   // DropdownItemModel? get proximity => _proximity;
//   final TextEditingController partnerName = TextEditingController();
//   final TextEditingController dateofBirth = TextEditingController();
//   final TextEditingController dateofAnniverssary = TextEditingController();
//   final TextEditingController foodController = TextEditingController();
//   final TextEditingController placeController = TextEditingController();
//   final TextEditingController restaurantController = TextEditingController();
//   final TextEditingController dreamVacationController = TextEditingController();
//   final TextEditingController musicGenreController = TextEditingController();
//   final TextEditingController colorController = TextEditingController();
//   final TextEditingController hobbyController = TextEditingController();
//   final TextEditingController favouriteActivityController =
//       TextEditingController();
//   final TextEditingController favouriteWayController = TextEditingController();
//   //  final List<TextEditingController> titleController = [];
//   //  final List<TextEditingController> dateController = [];
//   //  final List<TextEditingController> noteController = [];
//   final TextEditingController archiveTitleController = TextEditingController();
//   final TextEditingController archiveDateController = TextEditingController();
//   final TextEditingController archiveNoteController = TextEditingController();

//   final List<TextEditingController> titleControllers = [];
//   final List<TextEditingController> dateControllers = [];
//   final List<TextEditingController> noteControllers = [];
// //   List<List<XFile>> momentImages = [];

// // void addNewMoment() {
// //   titleControllers.add(TextEditingController());
// //   dateControllers.add(TextEditingController());
// //   noteControllers.add(TextEditingController());
// //   momentImages.add([]); 
// //   notifyListeners();
// // }

// //  void removeMoment(int index) {
// //   titleControllers[index].dispose();
// //   dateControllers[index].dispose();
// //   noteControllers[index].dispose();

// //   titleControllers.removeAt(index);
// //   dateControllers.removeAt(index);
// //   noteControllers.removeAt(index);
// //   momentImages.removeAt(index); // Remove corresponding image list

// //   notifyListeners();
// // }


// // void addMomentImages(int index, List<XFile> images) {
// //   if (index >= 0 && index < momentImages.length) {
// //     momentImages[index].addAll(images);
// //     notifyListeners();
// //   }
// // }

// List<List<XFile>> _selectedImages = [];

// List<List<XFile>> get selectedImages => _selectedImages;

// void addNewMoment() {
//   titleControllers.add(TextEditingController());
//   dateControllers.add(TextEditingController());
//   noteControllers.add(TextEditingController());
//   _selectedImages.add([]);
//   notifyListeners();
// }

// void addImages(int index, List<XFile> images) {
//   if (index < _selectedImages.length) {
//     _selectedImages[index].addAll(images);
//     notifyListeners();
//   }
// }

// void removeImage(int index, int imageIndex) {
//   if (index < _selectedImages.length &&
//       imageIndex < _selectedImages[index].length) {
//     _selectedImages[index].removeAt(imageIndex);
//     notifyListeners();
//   }
// }

//   void clearAll() {
//     for (var controller in [
//       ...titleControllers,
//       ...dateControllers,
//       ...noteControllers,
//     ]) {
//       controller.dispose();
//     }
//     titleControllers.clear();
//     dateControllers.clear();
//     noteControllers.clear();
//     notifyListeners();
//   }

//   // }
//   // void addSpecialDayControllers() {
//   //   titleController.add(TextEditingController());
//   //   dateController.add(TextEditingController());
//   //   noteController.add(TextEditingController());
//   //   notifyListeners();
//   // }
//   void setName(String value) {
//     _name = value;
//     notifyListeners();
//   }

//   void setTitle(String value) {
//     title = value;
//     notifyListeners();
//   }

//   void setDate(String value) {
//     specialDate = value;
//     notifyListeners();
//   }

//   void setNote(String value) {
//     note = value;
//     notifyListeners();
//   }

//   void setDob(String value) {
//     _dob = value;
//     notifyListeners();
//   }

//   void setAnniversary(String value) {
//     _anniversary = value;
//     notifyListeners();
//   }

//   void setRelation(DropdownItemModel? value) {
//     _relation = value;
//     notifyListeners();
//   }

//   void setLanguage(DropdownItemModel? value) {
//     _language = value;
//     notifyListeners();
//   }

//   void setProximity(DropdownItemModel? value) {
//     _proximity = value;
//     notifyListeners();
//   }

//   void selectGender(int index, String gender) {
//     _selectedIndex = index;
//     _gender = gender;

//     notifyListeners();
//   }

//   void addArchiveImages(List<XFile> images) {
//     archiveImages.addAll(images);
//     notifyListeners();
//   }

//   void dataCLear() {
//     partnerName.clear();
//     dateofBirth.clear();
//     dateofAnniverssary.clear();
//     foodController.clear();
//     placeController.clear();
//     archiveTitleController.clear();
//     archiveDateController.clear();
//     archiveNoteController.clear();
//     titleControllers.clear();
//     dateControllers.clear();
//     noteControllers.clear();
//   }
//   void setFood(String value) {
//     food = value;
//     notifyListeners();
//   }
//   void setResturent(String value) {
//     restaturent = value;
//     notifyListeners();
//   }
//   void setHobby(String value) {
//     hobby = value;
//     notifyListeners();
//   }
//   void setFavouriteActivity(String value) {
//     favouriteActivity = value;
//     notifyListeners();
//   }
//   void setFavouriteWay(String value) {
//     favouriteWay = value;
//     notifyListeners();
//   }
//   void setDreamVacation(String value) {
//     dreamVacation = value;
//     notifyListeners();
//   }
//   void setMusicGenre(String value) {
//     musicGenre = value;
//     notifyListeners();
//   }
//   void setColor(String value) {
//     color = value;
//     notifyListeners();
//   }

//   void setPlace(String value) {
//     place = value;
//     notifyListeners();
//   }

//   void updateOther(int index, String value) {
//     if (index < others.length) {
//       others[index] = value;
//     }
//     notifyListeners();
//   }

//   void addOtherField() {
//     others.add('');
//     notifyListeners();
//   }

//   void addFavouriteField(TextEditingController controller) {
//     favouriteControllers.add(controller);
//     notifyListeners();
//   }

//   void updateFavouriteDescriptions() {
//     favouriteDescription
//       ..clear()
//       ..addAll(
//         favouriteControllers
//             .map((controller) => controller.text.trim())
//             .where((text) => text.isNotEmpty),
//       );
//   }

//   bool get isAllFilled {
//     return food.trim().isNotEmpty &&
//         restaturent.trim().isNotEmpty &&
//         dreamVacation.trim().isNotEmpty &&
//         musicGenre.trim().isNotEmpty &&
//         place.trim().isNotEmpty &&
//         color.trim().isNotEmpty &&
//         hobby.trim().isNotEmpty &&
//         favouriteActivity.trim().isNotEmpty &&
//         favouriteWay.trim().isNotEmpty &&
//         others.every((element) => element.trim().isNotEmpty);
//   }

//   bool get isFormValid =>
//       _name.isNotEmpty &&
//       _dob.isNotEmpty &&
//       _anniversary.isNotEmpty &&
//       _relation != null &&
//       _language != null &&
//       _proximity != null;


// bool get isSepcialFormValid {
//   for (int i = 0; i < titleControllers.length; i++) {
//     if (titleControllers[i].text.trim().isEmpty ||
//         dateControllers[i].text.trim().isEmpty ||
//         noteControllers[i].text.trim().isEmpty
//         // Optional: || _selectedImages[i].isEmpty
//     ) return false;
//   }
//   return true;
// }
// }