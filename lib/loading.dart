import 'dart:developer';



import 'package:bbnij/feature/auth/presentation/login_screen/loginScreen.dart';
import 'package:bbnij/splash_screen.dart';
import 'package:flutter/material.dart';

import 'constants/app_constants.dart';
import 'helpers/di.dart';
import 'helpers/helpers_method.dart';
import 'networks/dio/dio.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    loadInitialData();
    super.initState();
  }

  bool _isLoading = true;

  Future<void> loadInitialData() async {
    await setInitValue();
    bool data = appData.read(kKeyIsLoggedIn) ?? false;
    if (data) {
      String token = appData.read(kKeyAccessToken);
      log("Token is ===========> $token");
      log("FCM Token is ===========> ${appData.read(kKeyFCMToken)}");
      DioSingleton.instance.update(token);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen();
    } else {
      return LoginScreen();
      // return appData.read(kKeyIsLoggedIn)
      //     ? NavigationScreen()
      //     : WelcomeScreen();
    }
  }
}
