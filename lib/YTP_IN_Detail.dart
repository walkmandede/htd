import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmp;
import 'package:htd/Home.dart';
import 'package:htd/YTP_IN_Detail.dart';
import 'package:htd/pages/Operation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'package:flutter_map_tappable_polyline/flutter_map_tappable_polyline.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:math';
import 'package:htd/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'dart:io';
import 'dart:async';
import 'package:htd/YTP_IN.dart';
import 'package:htd/YTP_IN_Edit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:htd/main.dart';

class YTP_IN_Detail extends StatelessWidget {
  final DocumentSnapshot docID;

  const YTP_IN_Detail(this.docID);

  @override
  Widget build(BuildContext context) {
    return YTP_IN_DetailForm(docID);
  }
}

class YTP_IN_DetailForm extends StatefulWidget {
  final DocumentSnapshot docID;

  const YTP_IN_DetailForm(this.docID);

  @override
  _YTP_IN_DetailFormState createState() => _YTP_IN_DetailFormState();
}

class _YTP_IN_DetailFormState extends State<YTP_IN_DetailForm> {
  GeoPoint homelocation;
  Timestamp installDate;
  Timestamp receivedDate;
  QuerySnapshot dnsnqs;
  DocumentSnapshot ds;
  GeoPoint dnsnLatLong;
  List<String> dnsnList = [];
  GeoPoint homeLatLong;
  List poleList=[];
  var fullImageName;
  List<Marker> mapMarkers = [];
  List<LatLng> polyLinePoints = [];
  Widget dnsnMap;

  Future<String> uploadImageToCloud(var imageFile) async {
    var Rand1 = new Random().nextInt(999);
    var Rand2 = new Random().nextInt(999);
    var Rand3 = new Random().nextInt(999);
    fullImageName = widget.docID.data["customerName"].trim() +
        '-' +
        widget.docID.data["customerID"] +
        '$Rand1$Rand2$Rand3.jpg';
    final StorageReference refImg = FirebaseStorage.instance.ref().child(
        DateTime.fromMillisecondsSinceEpoch(
                    widget.docID.data["receivedDate"].millisecondsSinceEpoch)
                .toString()
                .substring(0, 10) +
            '/' +
            widget.docID.data["customerID"] +
            '/' +
            fullImageName);
    StorageUploadTask uploadTask = refImg.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl;
  }

  Future<void> getData() async {
    homelocation = widget.docID.data['homeLocation'];
    installDate = widget.docID.data['installationDate'];
    receivedDate = widget.docID.data['receivedDate'];
    poleList= widget.docID.data['poles'];
    setState(() {
    });
    dnsnqs = await Firestore.instance.collection('DNSN').getDocuments();

    for (final index in dnsnqs.documents) {
      dnsnList.add(index.documentID.toString());
    }

    if (dnsnList.contains(widget.docID.data['dnsn'])) {
      ds = await Firestore.instance
          .collection('DNSN')
          .document(widget.docID.data['dnsn'])
          .get();
      dnsnLatLong = ds.data['latLong'];
      mapMarkers.add(
        Marker(
          point: LatLng(dnsnLatLong.latitude, dnsnLatLong.longitude),
          builder: (context) {
            return Icon(
              Icons.router,
              color: Colors.greenAccent,
            );
          },
        ),
      );
    }
    homeLatLong = widget.docID.data['homeLocation'];
    mapMarkers.add(Marker(
      point: LatLng(homeLatLong.latitude, homeLatLong.longitude),
      builder: (context) {
        return Icon(
          Icons.home,
          color: Colors.redAccent,
        );
      },
    ));

    polyLinePoints.add(LatLng(homeLatLong.latitude, homeLatLong.longitude));

    poleList.forEach((element) {
       GeoPoint poleLoc = element;
      // double lat = double.parse(element.toString().split(',')[0]);
      // double lng = double.parse(element.toString().split(',')[1]);
      mapMarkers.add(Marker(
        point: LatLng(poleLoc.latitude, poleLoc.longitude),
        builder: (context) {
          return Icon(
            Icons.title,
            color: Colors.blueGrey,
          );
        },
      ));
      polyLinePoints.add(
        LatLng(poleLoc.latitude, poleLoc.longitude),
      );
    }
    );

    polyLinePoints.add(LatLng(dnsnLatLong.latitude, dnsnLatLong.longitude));
    setState(() {
      dnsnMap = new Container(
        height: 250,
        width: 300,
        child: FlutterMap(
          options: new MapOptions(
            bounds: LatLngBounds(
                LatLng(homeLatLong.latitude, homeLatLong.longitude),
                LatLng(
                    dnsnLatLong.latitude, dnsnLatLong.longitude)),
            zoom: 15.0,
            interactive: true,
            maxZoom: 100,
          ),
          layers: [
            TappablePolylineLayerOptions(
              //Will only render visible polylines, increasing performance
                polylineCulling: true,
                polylines: [
                  TaggedPolyline(
                    tag: "My Polyline",
                    color: Colors.black,
                    isDotted: true,
                    strokeWidth: 4.0,
                    //  An optional tag to distinguish polylines in callback
                    points:polyLinePoints
                    //...all other Polyline options
                  ),
                ],
                onTap: (TaggedPolyline polyline) =>
                    print(polyline.tag)),
            new TileLayerOptions(
                backgroundColor: Colors.blue,
                opacity: 0.5,
                maxNativeZoom: 100,
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
            new MarkerLayerOptions(
              markers: mapMarkers,
            ),
          ],
        ),
      );
    });
  }

  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 20,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.green),
        title: Text(
          widget.docID.data['customerName'],
          style: TextStyle(color: Colors.green,fontSize: 25/MediaQuery.textScaleFactorOf(context)),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              switch (value) {
                case 'process':
                  Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => YTP_IN_Edit(widget.docID),));
                  break;

                case 'makeFinish':
                  await widget.docID.reference.updateData({
                    'status': 'Finished',
                  });
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) =>YTP_IN_Detail(widget.docID)));
                  break;

                case 'ssr':
                  await widget.docID.reference.updateData({
                    'ssr': true,
                  });
                  Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) =>YTP_IN_Detail(widget.docID)));
                  break;

                case 'call':
                  launch("tel://${widget.docID.data['phone1']}");
                  break;

                case 'delete':
                  await widget.docID.reference.delete();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyAppPage(),
                      ));
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              const PopupMenuItem(
                value: 'process',
                child: Text('Process'),
              ),
              const PopupMenuItem(
                value: 'makeFinish',
                child: Text('Make Finish'),
              ),
              const PopupMenuItem(
                value: 'ssr',
                child: Text('Make SSR'),
              ),
              const PopupMenuItem(
                value: 'call',
                child: Text('Call Phone'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(5),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Installation Date',
                      style: globals.getTextStyle(context),
                    ),
                    Text(
                      installDate.toDate().day.toString() +
                          '.' +
                          installDate.toDate().month.toString() +
                          '.' +
                          installDate.toDate().year.toString(),
                      style: globals.getTextStyle(context).apply(color: Colors.blue),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      'Received Date',
                      style: globals.getTextStyle(context),
                    ),
                    Text(
                      receivedDate.toDate().day.toString() +
                          '.' +
                          receivedDate.toDate().month.toString() +
                          '.' +
                          receivedDate.toDate().year.toString(),
                      style: globals.getTextStyle(context).apply(color: Colors.blue),
                    ),
                  ],
                ),
              ],
            ),
            Flexible(
              child: TextField(
                controller: new TextEditingController(
                  text: widget.docID.data['customerID'],
                ),
                readOnly: true,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Customer ID',
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            widget.docID.data['type']=='Maintan'?SizedBox():Flexible(
              child: TextField(
                controller: new TextEditingController(
                  text: widget.docID.data['ttNo'],
                ),
                readOnly: true,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: 'Ticket No',
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            dnsnList.contains(widget.docID.data['dnsn']) == false
                ? FlatButton.icon(
                onPressed: () => this.setState(() {}),
                icon: Icon(Icons.refresh),
                label: Text('View Map'))
                : dnsnMap,
            TextField(
              controller: new TextEditingController(
                text: widget.docID.data['address'],
              ),
              readOnly: true,
              maxLines: null,
              decoration: InputDecoration(
                labelText: 'address',
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['phone1'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Primary Phone',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['phone2'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Secondary Phone',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['bandwidth'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Bandwidth',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['startMeter'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Start Meter',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['endMeter'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'End Meter',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['dnsn'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'DNSN',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['port'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Port',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['customerType'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Customer Type',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['buildingType'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Building Type',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: homelocation.latitude.toString() +
                          "," +
                          homelocation.longitude.toString(),
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Home Location',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['usedDevice'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Use Device',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['userName'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['password'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['dropCable'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Drop Cable',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['fastConnectors'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Fast Connectors',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                Flexible(
                  child: TextField(
                    controller: new TextEditingController(
                      text: widget.docID.data['siteExpense'],
                    ),
                    readOnly: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      labelText: 'Site Expense',
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Container(
              child: Card(
                child: ExpansionTile(
                  title: Text(
                    'Photo Data',
                    textAlign: TextAlign.center,
                    style: globals.getTextStyle(context),
                  ),
                  children: <Widget>[
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget
                                                  .docID.data['dnsnPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'dnsnPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'dnsnPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'dnsnPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                  });
                                                  Navigator.of(context,
                                                      rootNavigator: true)
                                                      .pop();
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            Operation(),
                                                      ));
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'dnsnPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['dnsnPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'DNSN',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget
                                                  .docID.data['lossesPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'lossesPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'lossesPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'lossesPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'lossesPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['lossesPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Losses',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        child: SimpleDialog(
                                          children: [
                                            CachedNetworkImage(
                                                imageUrl: widget
                                                    .docID.data['portPhoto']),
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: [
                                                FlatButton.icon(
                                                  icon: Icon(Icons.edit),
                                                  label: Text('Edit'),
                                                  onPressed: () async {
                                                    await globals
                                                        .galleryOpen()
                                                        .then((value) async {
                                                      if (widget.docID.data[
                                                      'portPhoto'] !=
                                                          'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                        final StorageReference
                                                        predeleterefImg =
                                                        await FirebaseStorage
                                                            .instance
                                                            .getReferenceFromUrl(widget
                                                            .docID
                                                            .data[
                                                        'portPhoto']);
                                                        predeleterefImg
                                                            .delete();
                                                      }
                                                      widget.docID.reference
                                                          .updateData({
                                                        'portPhoto':
                                                        await uploadImageToCloud(
                                                            value)
                                                      });
                                                      Navigator.of(context,
                                                          rootNavigator:
                                                          true)
                                                          .pop();
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                Operation(),
                                                          ));
                                                    });
                                                  },
                                                ),
                                                FlatButton.icon(
                                                  icon: Icon(Icons.delete),
                                                  label: Text('Delete'),
                                                  onPressed: () async {
                                                    final StorageReference
                                                    predeleterefImg =
                                                    await FirebaseStorage
                                                        .instance
                                                        .getReferenceFromUrl(
                                                        widget.docID
                                                            .data[
                                                        'portPhoto']);
                                                    predeleterefImg.delete();
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ));
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: widget.docID.data['portPhoto'],
                                    width: 150,
                                  )),
                              Container(
                                child: Text(
                                  'Port',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget.docID
                                                  .data['powerMeterPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'powerMeterPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'powerMeterPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'powerMeterPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'powerMeterPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl:
                                  widget.docID.data['powerMeterPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Power Meter',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget
                                                  .docID.data['frontPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'frontPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'frontPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'frontPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'frontPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['frontPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'ONU Front',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget
                                                  .docID.data['backPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'backPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'backPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'backPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'backPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['backPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'ONU Back',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget
                                                  .docID.data['ssrPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID
                                                        .data['ssrPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'ssrPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'ssrPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'ssrPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['ssrPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'SSR',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget
                                                  .docID.data['feedbackPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'feedbackPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'feedbackPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'feedbackPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'feedbackPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['feedbackPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Feedback',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Stack(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      child: SimpleDialog(
                                        children: [
                                          CachedNetworkImage(
                                              imageUrl: widget.docID
                                                  .data['speedTestPhoto']),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              FlatButton.icon(
                                                icon: Icon(Icons.edit),
                                                label: Text('Edit'),
                                                onPressed: () async {
                                                  await globals
                                                      .galleryOpen()
                                                      .then((value) async {
                                                    if (widget.docID.data[
                                                    'speedTestPhoto'] !=
                                                        'https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg') {
                                                      final StorageReference
                                                      predeleterefImg =
                                                      await FirebaseStorage
                                                          .instance
                                                          .getReferenceFromUrl(
                                                          widget.docID
                                                              .data[
                                                          'speedTestPhoto']);
                                                      predeleterefImg.delete();
                                                    }
                                                    widget.docID.reference
                                                        .updateData({
                                                      'speedTestPhoto':
                                                      await uploadImageToCloud(
                                                          value)
                                                    });
                                                    Navigator.of(context,
                                                        rootNavigator: true)
                                                        .pop();
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              Operation(),
                                                        ));
                                                  });
                                                },
                                              ),
                                              FlatButton.icon(
                                                icon: Icon(Icons.delete),
                                                label: Text('Delete'),
                                                onPressed: () async {
                                                  final StorageReference
                                                  predeleterefImg =
                                                  await FirebaseStorage
                                                      .instance
                                                      .getReferenceFromUrl(
                                                      widget.docID.data[
                                                      'speedTestPhoto']);
                                                  predeleterefImg.delete();
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ));
                                },
                                child: CachedNetworkImage(
                                  imageUrl: widget.docID.data['speedTestPhoto'],
                                  width: 150,
                                ),
                              ),
                              Container(
                                child: Text(
                                  'Speedtest',
                                ),
                                color: Colors.yellow,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
