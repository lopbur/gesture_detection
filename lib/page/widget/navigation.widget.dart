import 'package:flutter/material.dart';
import 'package:gesture_detection/page/camera.page.dart';
import 'package:gesture_detection/page/gesture_train.page.dart';

class App2 extends StatefulWidget {
  const App2({Key? key}) : super(key: key);

  @override
  State<App2> createState() => _App2State();
}

class _App2State extends State<App2> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.back_hand),
            label: 'GestureTrainPage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'CameraPage',
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
    );
  }

  List _widgetOptions = [
    const GestureTrainPage(),
    const CameraPage(),
  ];
}
