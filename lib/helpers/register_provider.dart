import 'package:provider/provider.dart';

import '../providers/account_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/change_pass_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/forgot_password_provider.dart';
import '../providers/kyc_verification_provider.dart';
import '../providers/sign_up_provider.dart';
import '../providers/supplier_dashboard_provider.dart';
import '../providers/supplier_register_provider.dart';
import '../providers/theme_provider.dart';

var providers = [
  ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ChangeNotifierProvider<ForgotPasswordProvider>(create: (_) => ForgotPasswordProvider()),
  ChangeNotifierProvider<SignUpProvider>(create: (_) => SignUpProvider()),
  ChangeNotifierProvider<SupplierRegisterProvider>(create: (_) => SupplierRegisterProvider()),
  ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
  ChangeNotifierProvider<SupplierDashboardProvider>(create: (_) => SupplierDashboardProvider()),
  ChangeNotifierProvider<AccountProvider>(create: (_) => AccountProvider()),
  ChangeNotifierProvider<KycVerificationProvider>(create: (_) => KycVerificationProvider()),
  ChangeNotifierProvider<ChangePassProvider>(create: (_) => ChangePassProvider()),
];
