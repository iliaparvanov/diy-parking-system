import 'package:flutter/material.dart';

import './SelectDevicePage.dart';

void main() => runApp(new BluetoothParkingApp());

class BluetoothParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SelectDevicePage());
  }
}