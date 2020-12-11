import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:htd/globals.dart' as globals;
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: InventoryForm(),
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

class InventoryForm extends StatefulWidget {
  const InventoryForm();

  @override
  _InventoryFormState createState() => _InventoryFormState();
}

class _InventoryFormState extends State<InventoryForm> {
  QuerySnapshot accSnapShot;
  QuerySnapshot logSnapShot;
  QuerySnapshot devSnapShot;
  Timestamp logDateTime;

  TextEditingController deviceSerial = new TextEditingController();
  TextEditingController deviceName = new TextEditingController();

  Future<void> getData() async {
    QuerySnapshot qq;
    qq = await Firestore.instance.collection("accessories").getDocuments();
    this.setState(() {
      accSnapShot = qq;
    });
    QuerySnapshot qq2;
    qq2 = await Firestore.instance
        .collection("inventory_log")
        .orderBy('when', descending: true)
        .getDocuments();
    this.setState(() {
      logSnapShot = qq2;
    });
    QuerySnapshot qq3;
    qq3 = await Firestore.instance.collection("device").where('usedBy',isEqualTo: 'new').getDocuments();
    this.setState(() {
      devSnapShot = qq3;
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int acclength = accSnapShot.documents.length;
    int devlength = devSnapShot.documents.length;
    int loglength = logSnapShot.documents.length;

    return Container(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueGrey,
            leading: Container(),
            flexibleSpace: TabBar(
              labelColor: Colors.yellow,
              labelStyle: GoogleFonts.carterOne(),
              tabs: [
                Tab(
                  text: 'Accessories',
                  icon: Icon(Icons.inventory),
                ),
                Tab(
                  text: 'Devices',
                  icon: Icon(Icons.router),
                ),
                Tab(
                  text: 'Log',
                  icon: Icon(Icons.format_list_numbered),
                ),
              ],
            ),
          ),
          body: Container(
            child: TabBarView(
              children: [
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: acclength,
                      itemBuilder: (_, int index) {
                        final DocumentSnapshot doc =
                            accSnapShot.documents[index];
                        return Container(
                          height: 120,
                          child: new Card(
                            color: Colors.blueGrey,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 60),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  color: Colors.blueGrey,
                                  child: Text(
                                    doc.data['accessories'],
                                    style: GoogleFonts.carterOne(
                                        color: Colors.yellowAccent),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    doc.data['qty'].toString(),
                                    style: GoogleFonts.carterOne(
                                        color: Colors.greenAccent),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      FlatButton.icon(
                                          onPressed: null,
                                          icon: Icon(Icons.add),
                                          label: Text('Update',
                                              style: GoogleFonts.carterOne())),
                                      FlatButton.icon(
                                          onPressed: null,
                                          icon: Icon(Icons.edit),
                                          label: Text('Edit',
                                              style: GoogleFonts.carterOne())),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ExpansionTile(
                        title: Text('New Device'),
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: deviceSerial,
                              decoration: InputDecoration(
                                labelText: 'Serial',
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: TextField(
                              controller: deviceName,
                              decoration: InputDecoration(
                                labelText: 'Name',
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          RaisedButton(
                            child: Text('Save',),
                            onPressed: () async {
                              await Firestore.instance.collection('device').add({
                                'condition': 'new',
                                'deviceName': deviceName.text,
                                'deviceSerial': deviceSerial.text,
                                'usedBy': 'new',
                              });
                              showDialog(
                                  context: context,
                                  child: AlertDialog(
                                    title: Text('Wait'),
                                  ));
                              Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) =>Inventory()));
                            },
                          ),
                        ],
                      ),
                      Divider(),
                      Text(
                        'Current Devices : '+ devSnapShot.documents.length.toString(),
                        style: GoogleFonts.carterOne(fontSize: 20),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.6,
                        decoration: BoxDecoration(
                            border: Border.all(color: Color(0xff243b55))),
                        child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: devlength,
                            itemBuilder: (_, int index) {
                              final DocumentSnapshot doc =
                                  devSnapShot.documents[index];
                              return GestureDetector(
                                child: new Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  width: 200,
                                  height: 30,
                                  child: SizedBox(
                                    width: 200,
                                    height: 100,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                              doc.data['deviceSerial'],
                                          style: TextStyle(
                                              color: Colors.black),
                                        ),
                                        Text(
                                          doc.data['deviceName'],
                                          style: TextStyle(
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      title: Text(doc.data['deviceSerial']),
                                      actions: [
                                        FlatButton(child: Text('Delete',style: TextStyle(color: Colors.red),),onPressed: () async {
                                          doc.reference.delete();
                                          Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) =>Inventory()));
                                        },)
                                      ],

                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: loglength,
                      itemBuilder: (_, int index) {
                        final DocumentSnapshot doc =
                            logSnapShot.documents[index];
                        Timestamp logTime;
                        logTime = doc.data['when'];
                        return new Container(
                          width: 200,
                          height: 30,
                          child: SizedBox(
                            width: 200,
                            height: 100,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Text(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          logTime.millisecondsSinceEpoch)
                                      .toString()
                                      .substring(0, 10),
                                  style: GoogleFonts.carterOne(
                                      color: Colors.redAccent),
                                ),
                                Text(
                                  doc.data['site_id'],
                                  style: GoogleFonts.carterOne(
                                      color: Colors.blueAccent),
                                ),
                                Text(
                                  doc.data['usedDevice'],
                                  style: GoogleFonts.carterOne(
                                      color: Colors.orange),
                                ),
                                Text(
                                  doc.data['who'],
                                  style: GoogleFonts.carterOne(
                                      color: Colors.greenAccent),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
