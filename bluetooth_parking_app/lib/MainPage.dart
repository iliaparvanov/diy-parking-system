import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPage extends StatefulWidget {
  final BluetoothDevice device;

  const MainPage({this.device});

  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothConnection connection;

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  String data = "Waiting for measurements...";

  @override
  void initState() {
    super.initState();

    // Establish connection to BT device
    BluetoothConnection.toAddress(widget.device.address).then((_connection) {
      print('Established connection');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Once connection has been dropped either by the BT device or the local device
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Failed to establish connection');
      print(error);
    });
  }

  @override
  void dispose() {
    // Drop connection to avoid mem leak
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Helper',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Parking Helper'),
        ),
        body: Center(
          child: Text(this.data),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
      setState(() {
        this.data = String.fromCharCodes(data);
      });
  }
}