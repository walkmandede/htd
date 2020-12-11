import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:htd/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmp;
import 'package:latlong/latlong.dart';
import 'package:htd/globals.dart' as globals;
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:htd/dnsnMarkers.dart' as dnsnmarks;
import 'dart:async';

class CommonThings {
  static Size size;
}

class allMap extends StatefulWidget {
  @override
  _allMapState createState() => _allMapState();
}

class _allMapState extends State<allMap> {
  MapController mpc = new MapController();
  MapControllerImpl mpcl = new MapControllerImpl();
  LatLng ls = new LatLng(16.8147984, 96.1702065);
  List<Marker> mk = [];
  List<TextField> portID = [];
  bool showports = false;

  TextEditingController newZone = new TextEditingController();
  TextEditingController newSubZone = new TextEditingController();
  TextEditingController newDN = new TextEditingController();
  TextEditingController newSN = new TextEditingController();
  TextEditingController newPorts = new TextEditingController();
  TextEditingController newLocation = new TextEditingController();

  TextEditingController newPoleName = new TextEditingController();
  TextEditingController newType = new TextEditingController();
  TextEditingController newPoleLoc = new TextEditingController();
  TextEditingController newOwner = new TextEditingController();

  void getData() async {
    Geolocator().getCurrentPosition().then((value) => this.setState(() {
          ls = new LatLng(value.latitude, value.longitude);
        }));
    QuerySnapshot qs =
    await Firestore.instance.collection('DNSN').getDocuments();
    QuerySnapshot pqs =
    await Firestore.instance.collection('Pole').getDocuments();
    void tb(int k, DocumentSnapshot dss) {
      for (int i = 1; i < k + 1; i++) {
        String index = i.toString();
        TextEditingController _port$index = new TextEditingController();
        _port$index.text = dss.data['port$index'] ?? '';
        portID.add(TextField(
          controller: _port$index,
          keyboardType: TextInputType.number,
          style: TextStyle(
              color: _port$index.text == '' ? Colors.green : Colors.red,
              fontSize: 15),
          decoration: InputDecoration(
              labelText: 'Port $index',
              border: InputBorder.none,
              labelStyle: TextStyle(
                fontSize: 15,
                color: _port$index.text == '' ? Colors.green : Colors.red,
              )),
          onSubmitted: (value) {
            dss.reference.updateData({
              'port$index': value,
            });
            Phoenix.rebirth(context);
          },
        ));
      }
    }
    for (final index in pqs.documents) {
      GeoPoint gp = index.data['latLong'];
      mk.add(new Marker(
          point: LatLng(gp.latitude, gp.longitude),
          height: 30,
          width: 30,
          builder: (ctx) => Container(
            child: GestureDetector(
              child: Icon(Icons.wb_incandescent),
              onTap: () {
                showDialog(context: context,
                child: AlertDialog(
                  title: Text(index.documentID+'/'+index.data['belongedTo']+'/'+index.data['method']),
                ));
              },
            )
          )));
    }

    for (final index in qs.documents) {
      List<Widget> portList = [];
      Map<String,dynamic> pairedportid=index.data['portid'];
      if(pairedportid!=null){
        pairedportid.forEach((key, value) {
          portList.add(Text('port# $key : $value'));
        });
      }
      GeoPoint gp = index.data['latLong'];
      mk.add(new Marker(
          point: LatLng(gp.latitude, gp.longitude),
          height: 50,
          width: 50,
          builder: (ctx) => Container(
            child: new GestureDetector(
              child: Icon(Icons.router, color: Colors.greenAccent),
              onTap: () {
                TextEditingController _editDN = new TextEditingController();
                TextEditingController _editSN = new TextEditingController();
                TextEditingController _editZone =
                new TextEditingController();
                TextEditingController _editTotalPorts =
                new TextEditingController();
                _editDN.text = index.data['dn'];
                _editSN.text = index.data['sn'];
                _editZone.text = index.data['zone'];
                _editTotalPorts.text =
                index.data['ports'] == null ? '0' : index.data['ports'];
                index.data['ports'] == null
                    ? null
                    : tb(int.parse(_editTotalPorts.text), index);
                var AD = new SimpleDialog(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  title: Text(index.documentID),
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Zone'),
                      controller: _editZone,
                      onSubmitted: (value) {
                        index.reference.updateData({'zone': value});
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'DN'),
                      controller: _editDN,
                      onSubmitted: (value) {
                        index.reference.updateData({'dn': value});
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'SN'),
                      controller: _editSN,
                      onSubmitted: (value) {
                        index.reference.updateData({'sn': value});
                      },
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Total Ports'),
                      controller: _editTotalPorts,
                      onSubmitted: (value) {
                        index.reference.updateData({'totalPorts': value});
                        Navigator.pop(context);
                        Phoenix.rebirth(context);
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.blueGrey
                          )
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: portList,
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                );
                showDialog(context: context, child: AD).then((value) {
                  Firestore.instance
                      .collection('DNSN')
                      .document(newZone.text + newDN.text + newSN.text)
                      .updateData({
                    'zone': newZone.text,
                    'dn': newDN.text,
                    'sn': newSN.text,
                    'ports': newPorts.text,
                  }).then((value) {
                    showDialog(
                        context: context,
                        child: AlertDialog(
                          content: Text('Done'),
                        )).whenComplete(() {
                      Navigator.pop(context);
                    });
                  });
                });
              },
            ),
          )));
    }
  }

  @override
  void initState() {
    getData();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff243b55),
        child: Icon(Icons.my_location),
        onPressed: () async {
          Position pp = await Geolocator().getCurrentPosition();
          mpcl.move(LatLng(pp.latitude, pp.longitude), 16);
          mk.add(Marker(
            width: 20,
            height: 20,
            point: LatLng(pp.latitude, pp.longitude),
            builder: (context) {
              return Icon(
                Icons.location_on,
                color: Colors.blue,
              );
            },
          ));
        },
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(5),
            color: Colors.blueAccent,
            child:  Text('ဖိထားပီး dnsn အသစ်ထည့်နိုင်ပါသည်',style: TextStyle(color: Colors.yellow,fontSize: 15,fontWeight: FontWeight.w600),textAlign: TextAlign.center,),
          ),
          FlutterMap(
            options: new MapOptions(
              onLongPress: (point) {
                showDialog(
                    context: context,
                    child: SimpleDialog(
                      title: Text('What Would You Like To Do?'),
                      children: [
                        Column(
                          children: [
                            FlatButton.icon(
                                onPressed: () => newDNSN(point),
                                icon: Icon(Icons.add),
                                label: Text('New DNSN')),
                            FlatButton.icon(
                                onPressed: () => newPole(point),
                                icon: Icon(Icons.add),
                                label: Text('New Pole')),
                          ],
                        )
                      ],
                    ));
              },
              center: ls,
              zoom: 16.0,
              interactive: true,
              maxZoom: 100,
            ),
            mapController: mpcl,
            layers: [
//            TappablePolylineLayerOptions(
//                // Will only render visible polylines, increasing performance
//                polylineCulling: true,
//                polylines: [
//                  TaggedPolyline(
//                    tag: "My Polyline",
//                    // An optional tag to distinguish polylines in callback
//                    points: [
//                      globals.ygnOffice,
//                      LatLng(16.8147635, 96.169596),
//                    ],
//                    // ...all other Polyline options
//                  ),
//                ],
//                onTap: (TaggedPolyline polyline) => print(polyline.tag)),
              new TileLayerOptions(
                  backgroundColor: Colors.blue,
                  opacity: 0.5,
                  maxNativeZoom: 100,
                  urlTemplate:
                  "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c']),
              new MarkerLayerOptions(
                markers: mk,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void newDNSN(LatLng point) {
    showDialog(
        context: context,
        child: SimpleDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
              'New DNSN \n ${point.latitude.toString().substring(0, 9)},${point.longitude.toString().substring(0, 9)}'),
          children: [
            DropdownButton(items: globals.getZones(),
              hint: Text('Choose Zone Here'),
              onChanged: (value) {
              this.setState(() {
                newZone.text = value;
              });
            },),
            TextField(
              controller: newZone,
              readOnly: true,
              decoration: InputDecoration(labelText: 'Zone'),
            ),
            TextField(
              controller: newSubZone,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Sub Zone'),
            ),
            TextField(
              controller: newDN,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'DN'),
            ),
            TextField(
              controller: newSN,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'SN'),
            ),
            TextField(
              controller: newPorts,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Total Ports'),
            ),
            FlatButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save'),
              onPressed: () {
                Firestore.instance
                    .collection('DNSN')
                    .document(newZone.text +'-'+ newSubZone.text+'-'+ newDN.text +'-'+ newSN.text)
                    .setData({
                  'zone': newZone.text,
                  'subZone':newSubZone.text,
                  'dn': newDN.text,
                  'sn': newSN.text,
                  'ports': newPorts.text,
                  'latLong': new GeoPoint(point.latitude, point.longitude),
                }).then((value) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        content: Text('Done'),
                      )).then((value){
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => allMap(),
                        ));
                  });
                });
              },
            )
          ],
        ));
  }

  void newPole(LatLng point) {
    showDialog(
        context: context,
        child: SimpleDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          title: Text(
              'New Pole \n ${point.latitude.toString().substring(0, 9)},${point.longitude.toString().substring(0, 9)}'),
          children: [
            TextField(
              controller: newPoleName,
              decoration: InputDecoration(labelText: 'Pole Name'),
            ),
            TextField(
              controller: newOwner,
              decoration: InputDecoration(labelText: 'Belonged To'),
            ),
            TextField(
              controller: newType,
              decoration: InputDecoration(labelText: 'Method'),
            ),
            FlatButton.icon(
              icon: Icon(Icons.save),
              label: Text('Save'),
              onPressed: () {
                Firestore.instance
                    .collection('Pole')
                    .document(newPoleName.text)
                    .setData({
                  'poleName': newPoleName.text,
                  'belongedTo': newOwner.text,
                  'method': newType.text,
                  'latLong': new GeoPoint(point.latitude, point.longitude),
                }).then((value) {
                  showDialog(
                      context: context,
                      child: AlertDialog(
                        content: Text('Done'),
                      )).whenComplete(() {
                    Navigator.pop(context);
                  });
                });
              },
            )
          ],
        ));
  }
}
