import 'package:flutter/material.dart';

class CustomBackgorundImageContainer extends StatelessWidget {
  final Widget child;
  const CustomBackgorundImageContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(""),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
