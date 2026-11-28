import 'dart:developer';
import 'dart:io';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'constants/app_translations.dart';
import 'constants/color.dart';
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

  runApp(const MyApp());
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

  /// Light and dark themes share everything except the brightness-specific
  /// colours. Dark mode uses the navy-charcoal palette from `color.dart`
  /// for every Material surface (dialogs, sheets, menus, dividers…) so
  /// nothing falls back to Material's default greys.
  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? darkBackground : const Color(0xFFFAFAFA);
    final surface = isDark ? darkSurface : const Color(0xFFFFFFFF);
    final raised = isDark ? darkSurfaceRaised : const Color(0xFFF1F5F9);
    final border = isDark ? darkCardBorderColor : cardBorderColor;
    final mainText = isDark ? darkTextMain : textMain;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryOrange,
      primary: primaryOrange,
      brightness: brightness,
    ).copyWith(
      primary: primaryOrange,
      secondary: secondaryOrange,
      surface: surface,
      onSurface: mainText,
      surfaceContainerLowest: background,
      surfaceContainerLow: surface,
      surfaceContainer: surface,
      surfaceContainerHigh: isDark ? raised : surface,
      surfaceContainerHighest: raised,
      outline: border,
      outlineVariant: border,
    );

    final controls = _controls(isDark, surface: surface, raised: raised, border: border, mainText: mainText);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.poppinsTextTheme(isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
      fontFamilyFallback: [
        'LiAdor',
        GoogleFonts.hindSiliguri().fontFamily!,
        GoogleFonts.anekBangla().fontFamily!,
        GoogleFonts.notoSansBengali().fontFamily!,
      ],
      primaryColor: primaryOrange,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: border,
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      cardTheme: CardThemeData(color: surface, surfaceTintColor: Colors.transparent),
      dialogTheme: DialogThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(color: surface, surfaceTintColor: Colors.transparent),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: mainText,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: primaryOrange),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.allPrimaryColor,
      ),
      switchTheme: controls.switchTheme,
      checkboxTheme: controls.checkboxTheme,
      radioTheme: controls.radioTheme,
      elevatedButtonTheme: controls.elevatedButtonTheme,
      filledButtonTheme: controls.filledButtonTheme,
      outlinedButtonTheme: controls.outlinedButtonTheme,
      textButtonTheme: controls.textButtonTheme,
      floatingActionButtonTheme: controls.floatingActionButtonTheme,
      chipTheme: controls.chipTheme,
      tabBarTheme: controls.tabBarTheme,
      datePickerTheme: controls.datePickerTheme,
    );
  }

  /// Brand colours for Material controls and buttons that rely on theme
  /// defaults, so they match after switching light ↔ dark: solid orange
  /// "on" states with white marks, and clearly visible "off" states.
  static ({
    SwitchThemeData switchTheme,
    CheckboxThemeData checkboxTheme,
    RadioThemeData radioTheme,
    ElevatedButtonThemeData elevatedButtonTheme,
    FilledButtonThemeData filledButtonTheme,
    OutlinedButtonThemeData outlinedButtonTheme,
    TextButtonThemeData textButtonTheme,
    FloatingActionButtonThemeData floatingActionButtonTheme,
    ChipThemeData chipTheme,
    TabBarThemeData tabBarTheme,
    DatePickerThemeData datePickerTheme,
  }) _controls(bool isDark, {required Color surface, required Color raised, required Color border, required Color mainText}) {
    final outline = isDark ? darkControlOutline : lightControlOutline;
    final muted = isDark ? darkTextMuted : textMuted;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
    WidgetStateProperty<T> selected<T>(T on, T off) =>
        WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? on : off);

    return (
      switchTheme: SwitchThemeData(
        thumbColor: selected(Colors.white, isDark ? darkSwitchThumbOff : Colors.white),
        trackColor: selected(primaryOrange, isDark ? darkSwitchTrackOff : const Color(0xFFE2E8F0)),
        trackOutlineColor: selected(Colors.transparent, outline),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: selected(primaryOrange, Colors.transparent),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: outline, width: 1.6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(fillColor: selected(primaryOrange, outline)),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryOrange.withValues(alpha: 0.45),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
          elevation: 0,
          shape: shape,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(backgroundColor: primaryOrange, foregroundColor: Colors.white, shape: shape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: BorderSide(color: primaryOrange.withValues(alpha: 0.5)),
          shape: shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: primaryOrange)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: raised,
        selectedColor: primaryOrange.withValues(alpha: isDark ? 0.25 : 0.14),
        side: BorderSide(color: border),
        labelStyle: TextStyle(color: mainText),
        checkmarkColor: primaryOrange,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primaryOrange,
        unselectedLabelColor: muted,
        indicatorColor: primaryOrange,
        dividerColor: Colors.transparent,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: primaryOrange,
        headerForegroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isBn = appData.read('isBengali') ?? false;
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Banij',
          translations: AppTranslations(),
          locale: Get.locale ?? (isBn ? const Locale('bn', 'BD') : const Locale('en', 'US')),
          fallbackLocale: const Locale('en', 'US'),
          themeMode: themeProvider.themeMode,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
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
