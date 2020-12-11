import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpx/gpx.dart';
import 'package:htd/pages/DNSN.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:htd/globals.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:htd/dnsnMarkers.dart';
import 'dart:async';

class DNSNMap extends StatefulWidget {

  @override
  _DNSNMapState createState() => _DNSNMapState();
}

class _DNSNMapState extends State<DNSNMap> {

  GoogleMapController _controller;
  LatLng currentLocation;
  String _mapStyle;
  final iconData = Icons.router;
  final iconHome = Icons.home;
  var pictureRecorder; var canvas; var textPainter; var iconStr;
  BitmapDescriptor dnsnBit,homeBit;
  Set<Marker> dnsnToShow = {};
  QuerySnapshot dnsnQs;
  QuerySnapshot homeQs;


  Future<void> getData() async {
    Position ps = await Geolocator().getCurrentPosition();
      currentLocation = new LatLng(ps.latitude, ps.longitude);
      dnsnBit=await getIconForMap(iconData);
      homeBit=await getIconForMap(iconHome);

    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    dnsnQs = await Firestore.instance.collection('DNSN').getDocuments();
    homeQs = await Firestore.instance.collection('YTP_Sites').getDocuments();

    dnsnQs.documents.forEach((element) {
      GeoPoint gp = element.data['latLong'];
      dnsnToShow.addAll(
          {
            Marker ( position: LatLng(gp.latitude, gp.longitude  ),markerId: MarkerId(element.documentID),
              icon : dnsnBit, infoWindow: InfoWindow(title: element.documentID),
              onTap: () {
                showDialog(
                    context: context,
                    child: AlertDialog(
                        title: Text(element.documentID),
                        content: Text(element.data['port'].toString())
                    )
                );
              },
            ),
          }
      );
    });
    homeQs.documents.forEach((element) {
      GeoPoint gp = element.data['homeLocation'];
      dnsnToShow.addAll(
          {
            Marker ( position: LatLng(gp.latitude, gp.longitude  ),markerId: MarkerId(element.documentID),
              icon : homeBit, infoWindow: InfoWindow(title: element.documentID),
              onTap: () {
                showDialog(
                    context: context,
                    child: AlertDialog(
                        title: Text(element.documentID),
                        content: Text(element.data['customerName'].toString())
                    )
                );
              },
            ),
          }
      );
    });

  }

  Future<BitmapDescriptor> getIconForMap(var iconD) async
  {
    pictureRecorder = new PictureRecorder();
    canvas = Canvas(pictureRecorder);
    textPainter = TextPainter(textDirection: TextDirection.ltr);
    iconStr = String.fromCharCode(iconD.codePoint);
    textPainter.text = TextSpan(
        text: iconStr,
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: 60.0,
          fontFamily: iconD.fontFamily,
          color: Colors.greenAccent,
        )
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0.0, 0.0));
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(60, 60);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
       return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return  FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: Center(child: Text('Please wait its loading...')));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return  Scaffold(
                  body:
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.green.withOpacity(0.7), BlendMode.overlay),
                    child:  GoogleMap(
                      myLocationEnabled: true,
                      mapType: MapType.normal,
                      zoomControlsEnabled: false,
                      markers: dnsnToShow,
                      buildingsEnabled: true,
                      myLocationButtonEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation,
                        zoom: 16.5,tilt: 89,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        _controller = controller;
                        _controller.setMapStyle(_mapStyle);
                      },
                    ),
                  )
              );
          }
        }
    );
  }
}

