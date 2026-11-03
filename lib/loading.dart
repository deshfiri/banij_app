import 'dart:developer';

import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'helpers/di.dart';
import 'helpers/helpers_method.dart';
import 'networks/dio/dio.dart';
import 'splash_screen.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    await setInitValue();
    bool data = appData.read(kKeyIsLoggedIn) ?? false;
    if (data) {
      String? token = appData.read(kKeyAccessToken);
      if (token != null) {
        log("Token is ===========> $token");
        DioSingleton.instance.update(token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
