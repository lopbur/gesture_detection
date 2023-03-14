import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gesture_detection_rebuild/page/setting.page.dart';

import 'page/camera.page.dart';

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
      home: const CameraPage(),
    );
  }
}
