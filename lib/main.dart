import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// for develop
// ignore: unused_import
import 'package:gesture_detection/page/camera.page.dart';
// ignore: unused_import
import 'package:gesture_detection/page/gesture_train.page.dart';

// import 'page/camera.page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  final bool isDebug = true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Gesture_detection',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const GestureTrainPage(),
    );
  }
}
