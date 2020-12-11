import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/pages/employeeEditForm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:htd/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class Staff extends StatelessWidget {
  const Staff();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StaffForm(),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }
}

class StaffForm extends StatefulWidget {
  const StaffForm();

  @override
  _StaffFormState createState() => _StaffFormState();
}

class _StaffFormState extends State<StaffForm> {
  List<DocumentSnapshot> staffList = [];
  List<Widget> picList = [];
  DocumentSnapshot showStaff;

  void initState() {
    super.initState();
    getData();
  }
  Widget showData() {
    return Card(
      color: Colors.blueGrey,
      clipBehavior: Clip.hardEdge,
      elevation: 20,
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(showStaff.data['Name'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 25,color: Color(0xfffffff0)),),
                  SizedBox(height: 5,),
                  Text(showStaff.data['Branch'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.yellowAccent),),
                ],
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(showStaff.data['Picture']),
                  radius: 40,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlatButton.icon(
                  onPressed: () => launch("tel://${showStaff.data['Phone']}"),
                  icon: Icon(
                    Icons.phone,
                    color: Colors.greenAccent,
                  ),
                  label: Text(
                    'Call',style: TextStyle(color: Colors.greenAccent),
                  )
              ),
              FlatButton.icon(
                  icon: Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Edit',style: TextStyle(color: Colors.white),
                  ),
                onPressed: () {
                    Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => EmployeeEditForm(showStaff.documentID),));
                },
              ),
            ],
          ),
          Container(
            width: double.maxFinite,
            height: 250,
            padding: EdgeInsets.only(left: 20,right: 20),
            color: Color(0xfffffff0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Staff - '+showStaff.data['ID'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 20,),),
                Text(showStaff.data['Email'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 20,),),
                Text(showStaff.data['NRC'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 20,),),
                Text(showStaff.data['Phone'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 20,),),
                Center(child: Text(showStaff.data['Address'],style: GoogleFonts.spartan(fontWeight: FontWeight.bold,fontSize: 20,),)),
              ],
            ),
          )
        ],
      ),
    );
  }

  void getData() async {
    QuerySnapshot staffQs =
        await Firestore.instance.collection('employee').getDocuments();
    this.setState(() {
      staffList = staffQs.documents;
    });
    for (final index in staffList) {
      String _currentState = '';
      Widget _showCurrentState = new Text('Away',style: TextStyle(color: Colors.grey),);
      if(index.data['currentState']!=null)
        {
          switch(index.data['currentState'])
          {
            case 0 : _showCurrentState= new Text('Online',style: TextStyle(color: Colors.green,fontWeight: FontWeight.w800),);break;
            case 1 : _showCurrentState= new Text('Away',style: TextStyle(color: Colors.grey),);break;
            case 2 : _showCurrentState= new Text('Offline',style: TextStyle(color: Colors.red),);break;
          }
        }
      picList.add(
          Column(
            children: [
              GestureDetector(
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(index.data['Picture']),
                  radius: 40,
                ),
                onTap: () {
                  setState(() {
                    if (showStaff == null)
                      showStaff = index;
                    else if (showStaff == index)
                      showStaff = null;
                    else
                      showStaff = index;
                  });
                },
              ),
              _showCurrentState
            ],
          ));
      picList.add(SizedBox(
        height: 20,
        width: 20,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
        child: SingleChildScrollView(
            child: Column(children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: picList),
          ),
          SizedBox(
            height: 10,
          ),
          showStaff == null
              ? SizedBox()
              : Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FlatButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.edit,
                              color: Color(0xfffffff0),
                            ),
                            label: Text(
                              'Edit',
                              style: GoogleFonts.spartan(
                                  fontSize: 15,
                                  color: Color(0xfffffff0),
                                  fontWeight: FontWeight.w900),
                            )),
                        FlatButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.calendar_today,
                              color: Color(0xfffffff0),
                            ),
                            label: Text(
                              'History',
                              style: GoogleFonts.spartan(
                                  fontSize: 15,
                                  color: Color(0xfffffff0),
                                  fontWeight: FontWeight.w900),
                            )),
                        FlatButton.icon(
                            onPressed: () {},
                            icon: Icon(
                              Icons.call,
                              color: Color(0xfffffff0),
                            ),
                            label: Text(
                              'Call',
                              style: GoogleFonts.spartan(
                                  fontSize: 15,
                                  color: Color(0xfffffff0),
                                  fontWeight: FontWeight.w900),
                            )),
                      ],
                    ),
                    showData(),
                  ],
                )
        ])));
  }
}
