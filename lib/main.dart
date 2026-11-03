import 'dart:developer';
import 'dart:io';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_translations.dart';
import 'gen/colors.gen.dart';
import 'helpers/all_routes.dart';
import 'helpers/di.dart';
import 'helpers/helpers_method.dart';
import 'helpers/navigation_service.dart';
import 'helpers/register_provider.dart';
import 'loading.dart';
import 'networks/dio/dio.dart';
import 'providers/theme_provider.dart';

// Future<void> backgroundHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  await GetStorage.init();
  // LocationService.requestPermissions();
  await diSetUp();

  // FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  // NotificationService().initNotification();

  // initInternetChecker();
  // Stripe.publishableKey =
  //     "pk_test_51QnNJXITQYYNEE7dkNiPLGoixfLTw6xSJnQ8SWwKiskfG9d094czJrtptBO9mN50Wt2F58PnPSnZQUX2f0zI12pK00y1gOTDqn";
  // await Stripe.instance.applySettings();

  DioSingleton.instance.create();
  try {
    if (Platform.isIOS) {
      // Check if running on a simulator
      if (Platform.environment.containsKey('SIMULATOR_DEVICE_NAME')) {
        log('Running on an iOS simulator. Skipping high refresh rate setting.');
        return;
      }
    }

    // Set high refresh rate for supported devices
    await FlutterDisplayMode.setHighRefreshRate();
    log('High refresh rate mode set successfully.');
  } catch (e) {
    log('Error setting high refresh rate: $e');
  }

  //  runApp(const MyApp());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    rotation();
    setInitValue();
    return MultiProvider(
      providers: providers,
      child: AnimateIfVisibleWrapper(
        showItemInterval: const Duration(milliseconds: 150),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (bool didPop, dynamic result) async {
            // showMaterialDialog(context);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return const UtillScreenMobile();
            },
          ),
        ),
      ),
    );
  }
}

class UtillScreenMobile extends StatelessWidget {
  const UtillScreenMobile({super.key});

  @override
  Widget build(BuildContext context) {
    bool isBn = appData.read('isBengali') ?? false;
    final themeProvider = context.watch<ThemeProvider>();
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Banij',
          translations: AppTranslations(),
          locale: isBn ? const Locale('bn', 'BD') : const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            fontFamilyFallback: [
              'LiAdor',
              GoogleFonts.hindSiliguri().fontFamily!,
              GoogleFonts.anekBangla().fontFamily!,
              GoogleFonts.notoSansBengali().fontFamily!,
            ],
            primaryColor: const Color(0xFFFD6B04),
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFD6B04),
              primary: const Color(0xFFFD6B04),
              surface: const Color(0xFFFFFFFF),
              brightness: Brightness.light,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppColors.allPrimaryColor,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            fontFamilyFallback: [
              'LiAdor',
              GoogleFonts.hindSiliguri().fontFamily!,
              GoogleFonts.anekBangla().fontFamily!,
              GoogleFonts.notoSansBengali().fontFamily!,
            ],
            primaryColor: const Color(0xFFFD6B04),
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFD6B04),
              primary: const Color(0xFFFD6B04),
              surface: const Color(0xFF1E1E1E),
              brightness: Brightness.dark,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: AppColors.allPrimaryColor,
            ),
          ),
          builder: (context, widget) {
            return MediaQuery(data: MediaQuery.of(context), child: widget!);
          },
          navigatorKey: NavigationService.navigatorKey,
          onGenerateRoute: RouteGenerator.generateRoute,
          home: Loading(),
        );
      },
    );
  }
}
