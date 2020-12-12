import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:internet_speed_test/internet_speed_test.dart';
import 'package:internet_speed_test/callbacks_enum.dart';
import 'package:connectivity/connectivity.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wifi/wifi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:htd/wifiCheck.dart';
import 'dart:io';


const MethodChannel _channel = const MethodChannel('wifi_iot');
const EventChannel _eventChannel =
const EventChannel('plugins.wififlutter.io/wifi_scan');

class InternetChecker extends StatefulWidget {
  @override
  _InternetCheckerState createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  final internetSpeedTest = InternetSpeedTest();
  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  double downloadRate = 0;
  double uploadRate = 0;
  String downloadProgress = '0';
  String uploadProgress = '0';
  Position currentLoc;
  String unitText = 'Mb/s';
  bool isTesting  = false;
  bool isDone  = false;

  String ssid = '';

//Signal strength， 1-3，The bigger the number, the stronger the signal
  int level = 0;

  String ip = '';

  var result;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getData() async{
    var loc = await Geolocator().getCurrentPosition();
    currentLoc = new Position(longitude: loc.longitude,latitude: loc.latitude);
  }

  static Future<String> getBSSID() async {
    Map<String, String> htArguments = Map();
    String sResult;
    try {
      sResult = await _channel.invokeMethod('getBSSID', htArguments);
    } on MissingPluginException catch (e) {
      print("MissingPluginException : ${e.toString()}");
    }
    return sResult;
  }

  Future<void> getWifiData() async
  {
     ssid = await Wifi.ssid;
     level = await Wifi.level;
     ip = await Wifi.ip;
     result = await Wifi.connection('ssid', 'password');
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
        });
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return
          currentLoc==null?
          CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(
          Colors.black),
          )
              :MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
          body: Center(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
          // Container(
          //   child: CachedNetworkImage(
          //     imageUrl: 'https://quickchart.io/chart?c={type:\'radialGauge\',data:{datasets:[{data:[${double.parse(downloadProgress).ceil().toString()}],backgroundColor:\'green\'}]}}',
          //     height: 200,width: 200,
          //   ),
          // ),
          Container(
          width: MediaQuery.of(context).size.height*0.2,
          child: LinearProgressIndicator(
          value: double.parse(downloadProgress)*0.01,
          minHeight:  MediaQuery.of(context).size.height*0.02,
          ),
          ),
          isTesting==false?SizedBox():Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
          Text('Progress ${double.parse(downloadProgress).ceil().toString()}%'),
          Text('Download rate  $downloadRate $unitText'),
          ],
          ),
          isTesting==true||isDone==true?SizedBox():RaisedButton(
          child: Text('start testing'),
          onPressed: () async{
          isTesting = true;
          currentLoc = await Geolocator().getCurrentPosition();
          internetSpeedTest.startDownloadTesting(
          onDone: (double transferRate, SpeedUnit unit) {
          print('the transfer rate $transferRate');
          setState(() {
          downloadRate = transferRate;
          unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          downloadProgress = '100';
          isDone = true;
          isTesting = false;
          });
          },
          onProgress:
          (double percent, double transferRate, SpeedUnit unit) {
          print(
          'the transfer rate $transferRate, the percent $percent \n ${currentLoc.latitude.toString()+','+currentLoc.longitude.toString()}');
          setState(() {
          downloadRate = transferRate;
          unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          downloadProgress = percent.toStringAsFixed(2);
          });
          },
          onError: (String errorMessage, String speedTestError) {
          print(
          'the errorMessage $errorMessage, the speedTestError $speedTestError');
          },
          testServer: 'https://burmawave.speedtestcustom.com',
          fileSize: 20000000,
          );
          },
          ),
          isDone==false?SizedBox():
          Center(
          child: Column(
          children:
          [
          Text('Download Speed :   $downloadRate $unitText'),
          Text(currentLoc.latitude.toString()+','+currentLoc.longitude.toString()),
          ]
          ),
          ),
          Container(
          height: MediaQuery.of(context).size.height*0.2,
          width: MediaQuery.of(context).size.height*0.2,
          child: FlutterMap(
          options: new MapOptions(
          center: LatLng(currentLoc.latitude, currentLoc.longitude),
          zoom: 15.0,
          interactive: true,
          maxZoom: 100,
          ),
          layers: [
          new TileLayerOptions(
          backgroundColor: Colors.blue,
          opacity: 0.5,
          maxNativeZoom: 100,
          urlTemplate:
          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c']),
          new MarkerLayerOptions(
          markers: [
          Marker(
          point: LatLng(
          currentLoc.latitude, currentLoc.longitude),
          builder: (context) {
          return Icon(
          Icons.wifi,
          color: Colors.redAccent,
          );
          },
          ),
          ],
          ),
          ],
          ),
          ),
          isDone==false?SizedBox():Container(
          margin: EdgeInsets.all(10),
          child: Text('Speed Testing Finished',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500),),
          )

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: <Widget>[
          //     Text('Progress $uploadProgress%'),
          //     Text('Upload rate  $uploadRate Kb/s'),
          //   ],
          // ),
          // isTesting?SizedBox():RaisedButton(
          //   child: Text('start testing'),
          //   onPressed: () {
          //     internetSpeedTest.startUploadTesting(
          //       onDone: (double transferRate, SpeedUnit unit) {
          //         print('the transfer rate $transferRate');
          //         setState(() {
          //           uploadRate = transferRate;
          //           unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          //           uploadProgress = '100';
          //         });
          //       },
          //       onProgress:
          //           (double percent, double transferRate, SpeedUnit unit) {
          //         print(
          //             'the transfer rate $transferRate, the percent $percent');
          //         setState(() {
          //           isTesting = true;
          //           uploadRate = transferRate;
          //           unitText = unit == SpeedUnit.Kbps ? 'Kb/s' : 'Mb/s';
          //           uploadProgress = percent.toStringAsFixed(2);
          //         });
          //       },
          //       onError: (String errorMessage, String speedTestError) {
          //         print(
          //             'the errorMessage $errorMessage, the speedTestError $speedTestError');
          //       },
          //       testServer: 'https://burmawave.dualstack.speedtestcustom.com',
          //       fileSize: 20000000,
          //     );
          //   },
          // ),
          ],
          ),
          ),
          ),
          );
        }
    );
  }
}