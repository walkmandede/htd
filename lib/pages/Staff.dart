import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/pages/Profile.dart';
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
        appBar: AppBar(
          backgroundColor: Colors.green,
        ),
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
  QuerySnapshot empSnap;
  List<Widget> empWidget = [];
  
  Future<void> getData() async {
    empSnap = await Firestore.instance.collection('employee').getDocuments();
      empSnap.documents.forEach((element) {
        empWidget.add(
            GestureDetector(
              child: Container(
                margin: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: MediaQuery.of(context).size.height*0.04,
                      backgroundImage: CachedNetworkImageProvider(element.data['Picture']),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(element.data['Name'],style: TextStyle(fontSize: 20/MediaQuery.textScaleFactorOf(context),color: Colors.green),),
                          Text(element.data['Branch'],style: TextStyle(fontSize: 15/MediaQuery.textScaleFactorOf(context)),),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Profile(element.documentID),));
              },
            )
        );
      });
  }
  
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: Center(child: Text('Please wait its loading...')));
          } else {
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            else
              return Container(
                color: Colors.green.shade100,
                child: ListView(
                  children: empWidget,
                ),
              );
          }
        }
    );
  }
}
