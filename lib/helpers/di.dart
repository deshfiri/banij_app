import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';


import '../providers/todo_provider.dart';

final locator = GetIt.instance;
final appData = locator.get<GetStorage>();

Future<void> diSetUp() async {
  locator.registerSingleton<GetStorage>(GetStorage());
  await Hive.initFlutter();
  await Hive.openBox('auth_box');
}
