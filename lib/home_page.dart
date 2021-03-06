import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:move/front/home.dart';

String gesture = "";
// ignore: non_constant_identifier_names
int gesture_num = 0;
final StreamController<int> streamController = StreamController<int>();

// ignore: non_constant_identifier_names
String gesture_name = "";

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  // ignore: deprecated_member_use

  final List<BluetoothDevice> devicesList = [];
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();
  final textController = TextEditingController();
  BluetoothDevice? connectedDevice;
  List<BluetoothService>? bluetoothServices;

  _showDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //screen vertically

    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _showDeviceTolist(device);
      }
    });
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _showDeviceTolist(result.device);
      }
    });
    flutterBlue.startScan();
  }

  @override
  void dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  ListView _buildListViewOfDevices() {
    // ignore: deprecated_member_use
    List<Container> containers = [];
    for (BluetoothDevice device in devicesList) {
      containers.add(
        Container(
          height: 50,
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(device.name == '' ? '(unknown device)' : device.name,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                          ),
                        ),
                        // Text(device.id.toString()),
                      ],
                    ),
                  ),
                  // ignore: deprecated_member_use
                  FlatButton(
                    child: Image.asset('connect.png', width: MediaQuery.of(context).size.width*0.35,),
                    onPressed: () async {
                      flutterBlue.stopScan();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Shake your controller!'),
                            duration: Duration(seconds: 5),
                          )
                      );
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          });
                      try {
                        await device.connect();
                      } catch (e) {
                        if (e != 'already_connected') {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          throw e;
                        }
                      } finally {
                        bluetoothServices = await device.discoverServices();
                      }
                      setState(() {
                        connectedDevice = device;
                      });
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                child: Divider(height: 1, color: Colors.white),
              )
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  void _bleRead(
      BluetoothCharacteristic characteristic) {
    if (characteristic.properties.notify) {
      characteristic.value.listen((value) {
        readValues[characteristic.uuid] = value;});
      characteristic.setNotifyValue(true);
    }

    if (characteristic.properties.read && characteristic.properties.notify)
      setnum(characteristic);
  }

  Future<void> setnum(characteristic) async {
    var sub = characteristic.value.listen((value) {
      setState(() {
        readValues[characteristic.uuid] = value;
        gesture = value.toString();
        gesture_num = int.parse(gesture[1]);
        print('GESTURE - ' + gesture);
        switch(gesture_num){
          case 1: gesture_name = "PUNCH"; break;
          case 2: gesture_name = "UPPERCUT"; break;
        }
      });
    });

    await characteristic.read();
    sub.cancel();
  }

  void _bleServices() {
    // ignore: deprecated_member_use
    for (BluetoothService service in bluetoothServices!) {
      // ignore: deprecated_member_use
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        _bleRead(characteristic);
      }
    }
  }

   Widget _buildView() {
    if (connectedDevice != null) {
      _bleServices();
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => Homepage(bluetoothServices: bluetoothServices)));
      });
    }
     return _buildListViewOfDevices();
   }

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Text("Connect",textAlign: TextAlign.center,style: TextStyle(color: Colors.indigo),),
      leading: IconButton(
        icon: Icon(Icons.arrow_back,color: Colors.indigo,),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('background.png'),
                fit: BoxFit.fill
            )
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
          child: _buildView(),
        )
    ),
  );
}