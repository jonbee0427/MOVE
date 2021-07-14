import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class CrossJack extends StatefulWidget {
  final List<BluetoothService>? bluetoothServices;
  CrossJack({this.bluetoothServices});

  @override
  _CrossJackState createState() => _CrossJackState();
}

class _CrossJackState extends State<CrossJack> {
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();
  String gesture = "";
  // ignore: non_constant_identifier_names
  int gesture_num = 0;
  int cnt = 0;
  int set = 0;

  @override
  void dispose(){
    super.dispose();
  }

  ListView _buildConnectDeviceView() {
    // ignore: deprecated_member_use
    List<Container> containers = [];
    for (BluetoothService service in widget.bluetoothServices!) {
      // ignore: deprecated_member_use
      List<Widget> characteristicsWidget = [];

      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          characteristic.value.listen((value) {
            readValues[characteristic.uuid] = value;
          });
          characteristic.setNotifyValue(true);
        }
        if (characteristic.properties.read && characteristic.properties.notify) {
          setnum(characteristic);
        }
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Center(child:Text("블루투스 연결설정")),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
            child:Column(
              children: [
                SizedBox(height: 30),
                Center(
                    child:Column(
                      children: [
                        Text("값:" + gesture_num.toString(),style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      ],
                    )
                ),
              ],
            )
        ),
      ],
    );
  }

  Future<void> setnum(characteristic) async {
    var sub = characteristic.value.listen((value) {
      setState(() {
        readValues[characteristic.uuid] = value;
        gesture = value.toString();
        gesture_num = int.parse(gesture[1]);

        if(gesture_num == 4) {
          cnt++;
        }
      });
    });

    await characteristic.read();
    sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cross Jack'),
        ),
        body: Column(
          children: [
            Container(
                height: 100,
                child: _buildConnectDeviceView()
            ),
            // Text('세트 $set', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
            SizedBox(height: 20),
            Text('카운트: $cnt 개', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          ],
        )
    );
  }
}
