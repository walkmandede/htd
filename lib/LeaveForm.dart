import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/ChatGroup.dart';
import 'package:htd/ChatPanel.dart';
import 'package:htd/Home.dart';
import 'package:htd/LeaveForm.dart';
import 'package:htd/YTP_IN.dart';
import 'package:htd/YTP_IN_Edit.dart';
import 'package:htd/internetCheck.dart';
import 'package:htd/pages/Calender.dart';
import 'package:htd/pages/CheckIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:htd/pages/Profile.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:htd/pages/Login.dart';
import 'package:htd/pages/Inventory.dart';
import 'package:htd/globals.dart' as globals;
import 'package:geolocator/geolocator.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:htd/globals.dart' as globals;

class LeaveForm extends StatefulWidget {
  @override
  _LeaveFormState createState() => _LeaveFormState();
}

class _LeaveFormState extends State<LeaveForm> {
  DateTime startDate,endDate;
  SharedPreferences prefs;
  String me;
  DocumentSnapshot myDocSnap;
  List<String> myCases = [];
  List<DateTime> myLeaves = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getData() async{
    setState(() async{
      prefs = await SharedPreferences.getInstance();
      me = prefs.getString('currentUser');
      myDocSnap = await Firestore.instance.collection('employee').document(me).get();
      myCases = myDocSnap.data['leave'];
    });
    myCases.forEach((element) { 
      DateTime dt = new DateTime(int.parse(element.split('-')[2]),int.parse(element.split('-')[1]),int.parse(element.split('-')[0]));
      myLeaves.add(dt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home:  Scaffold(
          body:  Center(
            child: Container(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Leave Form',style: TextStyle(fontSize: 25,fontWeight: FontWeight.w900),),
                    Divider(),
                    RaisedButton(
                      child: Text('Choose Start Date\n'+startDate.toString()),
                      onPressed: () async{
                        startDate = await globals.chooseDate(context);
                        this.setState(() {
                        });
                      },
                    ),
                    RaisedButton(
                      child: Text(' Choose End Date \n'+endDate.toString()),
                      color: Colors.orangeAccent,
                      onPressed: () async{
                        endDate = await globals.chooseDate(context);
                        this.setState(() {
                        });
                      },
                    ),
                    TextField(decoration: InputDecoration(labelText: 'Reason'),),
                    Divider(),
                    RaisedButton(
                    child: Text('Submit'),
                      onPressed: () async {
                      Duration leaveDays = endDate.difference(startDate);
                      SharedPreferences ps = await SharedPreferences.getInstance();
                      String user = ps.getString('currentUser');
                      for(int i=0;i<=leaveDays.inDays;i++)
                        {
                          DateTime t = startDate.add(Duration(days: i));
                          String today = t.day.toString() +
                              '-' +
                              t.month.toString() +
                              '-' +
                              t.year.toString();
                          Firestore.instance
                              .collection('CheckIn')
                              .document(today)
                              .setData({
                            user: {
                              'what': 'Leave',
                              'when': DateTime.now(),
                            }
                          }, merge: true).then((value)
                          {
                            Navigator.push(context,MaterialPageRoute(builder: (context) =>CheckIn()));
                          }
                          );
                          Firestore.instance
                              .collection('employee')
                              .document(user)
                              .updateData({
                            'leave':FieldValue.arrayUnion([today])
                          });
                        }
                      },
                    )

                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
