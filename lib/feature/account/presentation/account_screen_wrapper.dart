import 'package:flutter/material.dart';

import '../../../constants/color.dart';
import 'account_screen.dart';

class AccountScreen extends StatelessWidget {
  final String? initialTab;

  const AccountScreen({super.key, this.initialTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: AccountScreenBody(initialTab: initialTab),
      ),
    );
  }
}
