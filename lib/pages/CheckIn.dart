import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class CheckIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CheckInForm(),
        resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
      ),
    );
  }
}

class CheckInForm extends StatefulWidget {
  const CheckInForm();

  @override
  _CheckInFormState createState() => _CheckInFormState();
}

class _CheckInFormState extends State<CheckInForm> {
  SharedPreferences ps;
  String user;
  List<Widget> tdyCheckIn = [];
  DocumentSnapshot ds;
  DocumentReference dr;
  QuerySnapshot qs;
  DateTime tdy = DateTime.now();
  String today;
  bool alrdyChk = false;
  List<Widget> allStaff = [];
  QuerySnapshot empQs;
  Map checkedList = {};
  List<String> leaveList = [];
  bool alrdyLaded = false;

  Future<void> getData() async {
    today = tdy.day.toString() +
        '-' +
        tdy.month.toString() +
        '-' +
        tdy.year.toString();
    ps = await SharedPreferences.getInstance();
    user = ps.getString('currentUser');
    dr = Firestore.instance.collection('CheckIn').document(today);
    empQs = await Firestore.instance.collection('employee').getDocuments();
    qs = await Firestore.instance.collection('CheckIn').getDocuments();
    if (dr != null) {
      ds = await dr.get();
      if (ds.data[user] != null) alrdyChk = true;
    }

    for (final index in ds.data.keys) {
      DocumentSnapshot urds =
          await Firestore.instance.collection('employee').document(index).get();
      String picShown = urds.data['Picture'];
      DocumentSnapshot chckds = await dr.get();
      Timestamp chkintime = chckds.data[index]['when'];
      if (chckds.data[index]['what'] == 'Checking In') {
        checkedList.addEntries([MapEntry(urds.data['Name'], chkintime)]);
      }
      else if (chckds.data[index]['what'] == 'Leave') {
        checkedList.addEntries([MapEntry(urds.data['Name'], 'Leave')]);
      }
    }
    empQs.documents.forEach((element) {
      if (checkedList.keys.contains(element.data['Name']) &&
          checkedList[element.data['Name']] != 'Leave') {
        allStaff.add(Container(
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  element.data['Picture'],
                ),
              ),
              Divider(color: Colors.white,),
              Text(
                'Checked',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              Text(
                  checkedList[element.data['Name']].toDate().hour.toString() +
                      ' : ' +
                      checkedList[element.data['Name']]
                          .toDate()
                          .minute
                          .toString(),
                  style: TextStyle(color: Colors.green))
            ],
          ),
        ));
      } else if (checkedList.keys.contains(element.data['Name']) &&
          checkedList[element.data['Name']] == 'Leave') {
        allStaff.add(Container(
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  element.data['Picture'],
                ),
              ),
              Divider(color: Colors.white,),
              Text(
                'Leave',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ));
      } else {
        allStaff.add(Container(
          margin: EdgeInsets.all(5),
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  element.data['Picture'],
                ),
              ),
              Divider(color: Colors.white,),
              Text(
                'Not Yet',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ));
      }
    });
    setState(() {
      alrdyLaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: alrdyLaded ? null : getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return Scaffold(
            backgroundColor: Colors.green.shade100,
            appBar: AppBar(
              backgroundColor: Colors.green,
              title: Text(today,style: TextStyle(color: Colors.white,fontSize: 14/MediaQuery.textScaleFactorOf(context)),),
              actions: [
                alrdyChk == true
                    ? SizedBox()
                    : FlatButton(
                  child: Container(
                      child: Text(
                        'Check-In',style: TextStyle(color: Colors.white,fontSize: 14/MediaQuery.textScaleFactorOf(context)),
                      )),
                  onPressed: () async {
                    Position p = await Geolocator().getCurrentPosition();
                    Firestore.instance
                        .collection('CheckIn')
                        .document(today)
                        .setData({
                      user: {
                        'what': 'Checking In',
                        'when': DateTime.now(),
                        'where': GeoPoint(p.latitude, p.longitude),
                      }
                    }, merge: true).then((value) async{
                      await Firestore.instance
                          .collection('employee')
                          .document(user)
                          .updateData({
                        'attendance': FieldValue.arrayUnion([today])
                      });
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => CheckIn()));
                    });

                  },
                ),
              ],
            ),
            body:  !ds.exists
                ? Text(
              'No Check In Today',
            ) :
            GridView.count(
              crossAxisCount: 3,
              padding: EdgeInsets.all(10),
              shrinkWrap: true,
              children: allStaff,
            )
          );
        });
  }
}
