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
import 'package:htd/YTP_Email.dart';
import 'package:htd/YTP_IN_Detail.dart';
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
import 'package:cached_network_image/cached_network_image.dart';
import 'package:htd/main.dart';

class Operation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
          backgroundColor: Colors.green,
        ),
        body: OperationForm(),
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

class OperationForm extends StatefulWidget {
  const OperationForm();

  @override
  _OperationFormState createState() => _OperationFormState();
}

class _OperationFormState extends State<OperationForm> {
  List<DocumentSnapshot> doc;
  List<DocumentSnapshot> docMaintainYTP;
  var k;
  List<Widget> sitesCard = [];
  List<Widget> maintainCard = [];
  List<Widget> installCard = [];
  List<Card> sitesCardMaintainYTP = [];
  List dnsnList = [];
  int index;
  String showPage = 'all';
  String showOperator = 'YTP';
  bool isLoaded = false;
  List<DataRow> tableRow = [];

  Future<void> getData() async {
    QuerySnapshot qs;
    QuerySnapshot qsMaintainYTP;
    Widget k;
    qs = await Firestore.instance
        .collection('YTP_Sites')
        .orderBy('installationDate', descending: true)
        .getDocuments();
    doc = qs.documents;
    for (final _site in doc) {
      Timestamp installDate = _site.data['installationDate'];
      Timestamp receivedDate = _site.data['receivedDate'];
      DateTime date = installDate.toDate();
      tableRow.add(
          DataRow(
              cells: [
        DataCell(Text(_site.documentID),
        ),
        DataCell(Text(_site.data['customerName']),
        ),
        DataCell(Text(receivedDate.toDate().toString().substring(5, 10)),
        ),
        DataCell(Text(installDate.toDate().toString().substring(5, 10)),
        ),
        DataCell(Text(_site.data['address']),
        ),
        DataCell(Text(_site.data['phone1']),
        ),
        DataCell(Text(_site.data['remark']),
        ),
      ]));
    }
    QuerySnapshot dnsnQS =
        await Firestore.instance.collection('DNSN').getDocuments();
    for (final index in dnsnQS.documents) {
      dnsnList.add(index.documentID);
    }
    setState(() {
      isLoaded = true;
    });
  }

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return FutureBuilder(
        future: !isLoaded ? getData() : null,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return   Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:  DataTable(
                    columns: [
                      DataColumn(label: Text(
                          'ID / Ticket No',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                      DataColumn(label: Text(
                          'Name',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                      DataColumn(label: Text(
                          'Received',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                      DataColumn(label: Text(
                          'Install',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                      DataColumn(label: Text(
                          'Address',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                      DataColumn(label: Text(
                          'Phone',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                      DataColumn(label: Text(
                          'Remark',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                      )),
                    ],
                    rows: tableRow,
                  ),
                ),
              )
          );
        });
  }
}
