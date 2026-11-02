

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

var providers = [
  ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),


    
];
