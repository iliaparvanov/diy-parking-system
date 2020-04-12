import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import './BluetoothDeviceListEntry.dart';
import './MainPage.dart';

class SelectDevicePage extends StatefulWidget {
  const SelectDevicePage();

  @override
  _SelectDevicePage createState() => new _SelectDevicePage();
}

class _DeviceWithAvailability extends BluetoothDevice {
  BluetoothDevice device;
  bool availability;
  int rssi;

  _DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class _SelectDevicePage extends State<SelectDevicePage> {
  List<_DeviceWithAvailability> devices = List<_DeviceWithAvailability>();

  // Availability
  StreamSubscription<BluetoothDiscoveryResult> _discoveryStreamSubscription;
  bool _isDiscovering;

  _SelectDevicePage();

  @override
  void initState() {
    super.initState();

    _isDiscovering = true;
    _startDiscovery();

    // Get initial list of bonded devices
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      setState(() {
        devices = bondedDevices
            .map(
              (device) => _DeviceWithAvailability(
            device,
            false,
          ),
        ).toList();
      });
    });
  }

  void _restartDiscovery() {
    setState(() {
      _isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _discoveryStreamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
          setState(() {
            // Iterate over list of bonded devices to find the currently discovered one and update rssi/availability
            Iterator i = devices.iterator;
            while (i.moveNext()) {
              var _device = i.current;
              if (_device.device == r.device) {
                _device.availability = true;
                _device.rssi = r.rssi;
              }
            }
          });
        });

    _discoveryStreamSubscription.onDone(() {
      setState(() {
        _isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _discoveryStreamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<BluetoothDeviceListEntry> list = devices
        .map((_device) => BluetoothDeviceListEntry(
      device: _device.device,
      rssi: _device.rssi,
      enabled: _device.availability == true,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return MainPage(device: _device.device);
        }));
      },
    )).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Select device'),
        actions: <Widget>[
          _isDiscovering
              ? FittedBox(
            child: Container(
              margin: new EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white,
                ),
              ),
            ),
          )
              : IconButton(
            icon: Icon(Icons.replay),
            onPressed: _restartDiscovery,
          )
        ],
      ),
      body: ListView(children: list),
    );
  }
}
