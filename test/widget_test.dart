// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bbnij/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Load bd_locations.json test', (WidgetTester tester) async {
    final jsonString = await rootBundle.loadString('assets/json/bd_locations.json');
    final data = json.decode(jsonString);
    expect(data, isA<Map>());
    expect(data['divisions'], isA<List>());
    expect((data['divisions'] as List).isNotEmpty, true);
    debugPrint('Successfully loaded ${ (data['divisions'] as List).length } divisions from bd_locations.json');
  });
}

