import 'dart:math';
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
  List<int> distances = List<int>.filled(4, 300);
  List<int> previousDistances = List<int>.filled(4, 300);

  bool isReadingDistances = false;

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

  Widget _buildDistanceMarker(int distance, double angle) {
    if (distance > 200) {
      return Column(
        children: <Widget>[
          Transform.rotate(
            angle: angle,
            child: Image(
              image: AssetImage('assets/DistanceMarkerFarthest.png'),
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    } else if (distance > 140) {
      return Transform.rotate(
        angle: angle,
        child: Image(
          image: AssetImage('assets/DistanceMarkerFar.png'),
          fit: BoxFit.contain,
        ),
      );
    } else if (distance > 80) {
      return Transform.rotate(
        angle: angle,
        child: Image(
          image: AssetImage('assets/DistanceMarkerClose.png'),
          fit: BoxFit.contain,
        ),
      );
    } else if (distance <= 80) {
      return Column(
        children: <Widget>[
          Transform.rotate(
            angle: angle,
            child: Image(
              image: AssetImage('assets/DistanceMarkerClosest.png'),
              fit: BoxFit.contain,
            ),
          ),
          Text(distance.toString() + " cm")
        ],
      );
    }
  }

  Widget _buildLeftDistanceMarker() {
    return _buildDistanceMarker(distances[0], 0);
  }

  Widget _buildCenterLeftDistanceMarker() {
    return _buildDistanceMarker(distances[1], 0);
  }
  Widget _buildCenterRightDistanceMarker() {
    return _buildDistanceMarker(distances[2], 0);
  }
  Widget _buildRightDistanceMarker() {
    return _buildDistanceMarker(distances[3], 0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Helper',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Parking Helper'),
        ),
        body: Container(
            margin: const EdgeInsets.only(top: 100.0),
          alignment: Alignment.center,
          child:
              Column(
                children: <Widget> [
                  Row(
                      children: <Widget>[
                        Expanded(
                            child: Transform.rotate(
                              angle: pi/2,
                              child: Image(
                                image: NetworkImage("https://clipartsworld.com/images/aerial-view-of-car-clipart-39.png"),
                                fit: BoxFit.contain,
                              ),
                            )
                        )

                    ],
                  ),
                  SizedBox(height: 110),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget> [
                      Expanded(
                        child: _buildLeftDistanceMarker()
                      ),
                      Expanded(
                        child: _buildCenterLeftDistanceMarker()
                      ),
                      Expanded(
                        child: _buildCenterRightDistanceMarker()
                      ),
                      Expanded(
                        child: _buildRightDistanceMarker()
                      )
                    ]
                  )
                  ,]
             )
        )
      ),
    );
  }

  void extractNewDistances() {
    previousDistances = new List<int>.from(distances);
    distances[0] = int.parse(this.data.substring(this.data.indexOf("l")+1, this.data.indexOf("cu"))); // left
    distances[1] = int.parse(this.data.substring(this.data.indexOf("cu")+2, this.data.indexOf("cd"))); // center left
    distances[2] = int.parse(this.data.substring(this.data.indexOf("cd")+2, this.data.indexOf("r"))); // center right
    distances[3] = int.parse(this.data.substring(this.data.indexOf("r")+1, this.data.length)); // right
    setState(() {
    });
    this.data = "";
  }

  void _onDataReceived(Uint8List data) {
      setState(() {
        String currentData = String.fromCharCodes(data).trim();
        if (currentData.contains('l') && !isReadingDistances) {
          this.data = currentData.substring(currentData.indexOf("l"), currentData.length);
          isReadingDistances = true;
        } else if (currentData.contains('l') && isReadingDistances) {
          extractNewDistances();
          this.data = currentData.substring(currentData.indexOf("l"), currentData.length);
        } else {
          this.data += String.fromCharCodes(data).trim();
        }
      });
  }
}