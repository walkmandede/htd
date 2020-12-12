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
import 'package:htd/pages/DNSN.dart';
import 'package:htd/pages/MyCalender.dart';
import 'package:htd/pages/TimeSheet.dart';
import 'package:htd/pages/Staff.dart';
import 'package:htd/pages/Operation.dart';
import 'package:htd/pages/AllMap.dart';
import 'package:htd/pages/employeeEditForm.dart';
import 'package:htd/wifiCheck.dart';
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
import 'package:table_calendar/table_calendar.dart';

class Profile extends StatelessWidget {
  final String user;
  const Profile(this.user);

  @override
  Widget build(BuildContext context) {
    return Material(
      textStyle: TextStyle(fontSize: 10/MediaQuery.textScaleFactorOf(context)),
      child: Scaffold(
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.green,
          title: Text(this.user,style: TextStyle(color: Colors.white,fontSize: 14/MediaQuery.textScaleFactorOf(context)),),
        ),
        body: ProfileForm(this.user),
        resizeToAvoidBottomPadding: false,

      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  final String user;
  const ProfileForm(this.user);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  var k;
  int index;
  String currentUser = '';
  String today;
  DateTime tdy;

  DocumentSnapshot myProfile;
  DocumentSnapshot chckData;

  @override
  void initState() {
    getData();
    super.initState();
  }


  Future<void> getData() async {
    final prefs =
    await SharedPreferences.getInstance();
    tdy = DateTime.now();
    today = tdy.day.toString() +
        '-' +
        tdy.month.toString() +
        '-' +
        tdy.year.toString();

    setState(() {
      currentUser = prefs.getString('currentUser');
    });

    DocumentReference ds =
    await Firestore.instance.collection('employee').document(widget.user);
    ds.get().then((value) => this.setState(() {
      myProfile=value;
    }));

    chckData = await Firestore.instance.collection('CheckIn').document(today).get();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new  ListView(
            children: [
              Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.25,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    )
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                            myProfile.data['Picture']),
                        radius: MediaQuery
                            .of(context)
                            .size
                            .height * 0.05,
                      ),
                      Text(myProfile.data['Name'].toString().toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              Shadow(color: Colors.white, blurRadius: 20)
                            ]
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FlatButton.icon(
                              label: Text('Change Picture',),
                              icon: Icon(
                                Icons.broken_image_outlined, size: 15,),
                              onPressed: () async {
                                File proPic;
                                proPic = await globals.galleryOpen();
                                showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      title: Container(
                                        child: Image.file(proPic),
                                      ),
                                      actions: [
                                        FlatButton(
                                          child: Text('Change This Picture!'),
                                          onPressed: () async {
                                            myProfile.reference.updateData(
                                                {
                                                  'Picture': await globals
                                                      .uploadImageCloud(proPic,
                                                      myProfile.documentID,
                                                      DateTime.now()),
                                                }
                                            );
                                            showDialog(context: context,
                                                child: AlertDialog(
                                                  title: Text('Please Wait'),));
                                            Navigator.of(
                                                context, rootNavigator: true)
                                                .pop();
                                            Navigator.of(
                                                context, rootNavigator: true)
                                                .pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Profile(widget.user)));
                                          },
                                        )
                                      ],
                                    )
                                );
                              },
                            ),
                            FlatButton.icon(
                              label: Text('Change Password',),
                              icon: Icon(Icons.edit, size: 15,),
                              onPressed: () async {
                                TextEditingController txtPwd = new TextEditingController();
                                TextEditingController txtPwd2 = new TextEditingController();
                                TextEditingController txtShowMsg = new TextEditingController(
                                    text: 'Change Password');
                                showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      title:
                                      Column(
                                        children: [
                                          Text(txtShowMsg.text),
                                          TextField(
                                            controller: txtPwd,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              labelText: 'New Password',
                                            ),

                                          ),
                                          TextField(
                                            controller: txtPwd2,
                                            obscureText: true,
                                            decoration: InputDecoration(
                                              labelText: 'Rewrite Password',
                                            ),
                                          ),
                                          FlatButton(
                                            child: Text('Confirm!'),
                                            onPressed: () async {
                                              if (txtPwd2.text != txtPwd.text) {
                                                showDialog(context: context,
                                                    child: AlertDialog(
                                                      title: Text(
                                                          'Passwords do not match!'),
                                                    ));
                                              }
                                              else {
                                                myProfile.reference.updateData(
                                                    {
                                                      'Password': txtPwd.text,
                                                    }
                                                );
                                                Navigator.of(context,
                                                    rootNavigator: true).pop();
                                                Navigator.of(context,
                                                    rootNavigator: true)
                                                    .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Profile(widget.user)));
                                                showDialog(context: context,
                                                    child: AlertDialog(
                                                      title: Text('Done!'),
                                                    ));
                                              }
                                            },
                                          )
                                        ],
                                      ),
                                    )
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: FlatButton.icon(
                        icon: Icon(Icons.alarm_on_outlined),
                        label: Text('Check In'),
                        onPressed: () async {
                          if (chckData.data['user'] != null) {
                            Position p = await Geolocator()
                                .getCurrentPosition();
                            SharedPreferences ps = await SharedPreferences
                                .getInstance();
                            String user = ps.getString('currentUser');
                            chckData.reference.setData({
                              user: {
                                'when': DateTime.now(),
                                'where': GeoPoint(p.latitude, p.longitude),
                                'what': 'Checking In'
                              }
                            }, merge: true).then((value) {
                              Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                      builder: (context) => CheckIn()));
                            }
                            );
                            Firestore.instance
                                .collection('employee')
                                .document(user)
                                .updateData({
                              'attendance': FieldValue.arrayUnion([today])
                            });
                          }
                          else {
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                  title: Text(
                                      'You\'re already checked in today!'),
                                )
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      child: FlatButton.icon(
                        icon: Icon(Icons.clear),
                        label: Text('Take Leave'),
                        onPressed: () async {
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => LeaveForm()));
                        },
                      ),
                    ),
                    Container(
                      child: FlatButton.icon(
                        icon: Icon(Icons.attach_money),
                        label: Text('Pre-Salary'),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: FlatButton.icon(
                        icon: Icon(Icons.calendar_today),
                        label: Text('My Calender'),
                        onPressed: () async {
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(
                                  builder: (context) => MyCalender()));
                        },
                      ),
                    ),
                    Container(
                      child: FlatButton.icon(
                        icon: Icon(Icons.attach_money),
                        label: Text('Edit Profile'),
                        onPressed: () {
                          if(widget.user==currentUser)
                            {
                              Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.user),));
                            }
                        },
                      ),
                    ),
                    Container(
                      child: FlatButton.icon(
                        icon: Icon(Icons.attach_money),
                        label: Text('Pre-Salary'),
                      ),
                    ),
                  ],
                ),
              ),
              ExpansionTile(
                title: Text('About'),
                children: [
                  Card(
                    color: Colors.blueGrey,
                    clipBehavior: Clip.hardEdge,
                    elevation: 10,
                    margin: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: 250,
                          padding: EdgeInsets.only(left: 20, right: 20),
                          color: Colors.green.shade300,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Staff - ' + myProfile.data['ID'],),
                              Text(myProfile.data['Email'],),
                              Text(myProfile.data['NRC'],),
                              Text(myProfile.data['Phone'],),
                              Center(child: Text(myProfile.data['Address'],)),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              ExpansionTile(
                title: Text('Activities'),
                children: [
                ],
              ),
            ],
    );
      }
    }
