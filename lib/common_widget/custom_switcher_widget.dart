// import 'package:colten_app/gen/colors.gen.dart';
// import 'package:flutter/material.dart';

// class CustomSwitcher extends StatefulWidget {
//   final bool initialValue;
//   final ValueChanged<bool> onChanged;

//   const CustomSwitcher({
//     super.key,
//     this.initialValue = false,
//     required this.onChanged,
//   });

//   @override
//    CustomSwitcherState createState() => CustomSwitcherState();
// }

// class CustomSwitcherState extends State<CustomSwitcher> {
//   bool isOn = false;

//   @override
//   void initState() {
//     super.initState();
//     isOn = widget.initialValue;
//   }

//   void _handleChanged(bool newValue) {
//     setState(() => isOn = newValue);
//     widget.onChanged(newValue);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Theme(
//       data: ThemeData(useMaterial3: true),
//       child: Transform.scale(
//         scale: 0.8,
//         child: Switch(
//           value: isOn,
//           inactiveThumbColor: AppColors.cFFFFFF,
//           inactiveTrackColor: AppColors.cADADAD,
//           activeTrackColor: AppColors.allPrimaryColor,
//           onChanged: _handleChanged,
//         ),
//       ),
//     );
//   }
// }
