// import 'package:flutter/material.dart';
// class FavoriteThingsProvider extends ChangeNotifier {
//   String? selectedColor;
//   String flower = '';
//   String food = '';
//   String place = '';
//   List<String> others = [];

//   void setColor(String? value) {
//     selectedColor = value;
//     notifyListeners();
//   }

//   void setFlower(String value) {
//     flower = value;
//     notifyListeners();
//   }

//   void setFood(String value) {
//     food = value;
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

//   bool get isAllFilled {
//     return selectedColor != null &&
//         flower.trim().isNotEmpty &&
//         food.trim().isNotEmpty &&
//         place.trim().isNotEmpty &&
//         others.every((element) => element.trim().isNotEmpty);
//   }
// }
