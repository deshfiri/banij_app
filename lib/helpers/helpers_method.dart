import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import 'di.dart';

/// First-launch defaults and the device id, stored in [appData].
Future<void> setInitValue() async {
  await appData.writeIfNull(kKeyIsLoggedIn, false);
  await appData.writeIfNull(kKeyIsFirstTime, true);
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    appData.writeIfNull(kKeyDeviceID, iosDeviceInfo.identifierForVendor);
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    appData.writeIfNull(kKeyDeviceID, androidDeviceInfo.id);
  }
  await Future.delayed(const Duration(seconds: 2));
}

/// Transparent status bar with dark icons; portrait-only orientation.
void rotation() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

String? _deviceLabel;

/// A readable name for this phone ("Samsung SM-A515F · Android 13",
/// "iPhone15,2 · iOS 17.2"), sent as `device_name` on login so the person
/// can recognise it in their signed-in devices list.
Future<String> deviceLabel() async {
  if (_deviceLabel != null) return _deviceLabel!;
  var label = 'Mobile device';
  try {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      final brand = android.brand.isEmpty ? '' : '${android.brand[0].toUpperCase()}${android.brand.substring(1)} ';
      label = '$brand${android.model} · Android ${android.version.release}';
    } else if (Platform.isIOS) {
      final ios = await info.iosInfo;
      label = '${ios.utsname.machine} · iOS ${ios.systemVersion}';
    }
  } catch (_) {
    // Keep the generic label.
  }
  return _deviceLabel = label.length > 100 ? label.substring(0, 100) : label;
}
