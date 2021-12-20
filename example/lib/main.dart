import 'package:example/on_off_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'control_system examples',
      theme: ThemeData.light(),
      home: const OnOffControllerExample(),
    );
  }
}
