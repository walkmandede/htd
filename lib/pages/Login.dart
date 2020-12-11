import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:htd/globals.dart' as globals;
import 'package:htd/main.dart';
import 'package:htd/pages/Register.dart';
import 'dart:io';
import 'dart:math';

final kFirebaseAnalytics = FirebaseAnalytics();

class FirebaseLoginExample extends StatefulWidget {
  const FirebaseLoginExample({Key key}) : super(key: key);

  @override
  _FirebaseLoginExampleState createState() => _FirebaseLoginExampleState();
}

class _FirebaseLoginExampleState extends State<FirebaseLoginExample> {
  FirebaseUser _user;
  bool _busy = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String showName = "No User";
  QuerySnapshot qs;
  List<DocumentSnapshot> ds = [];
  TextEditingController txtemail = new TextEditingController();
  TextEditingController txtpwd = new TextEditingController();
  List<String> emailList = [];
  Map emailPwd = new Map();
  String password = "";
  bool isRegistered = false;

  Future<void> getData() async {
    qs = await Firestore.instance.collection('employee').getDocuments();
    ds = qs.documents;
    for (final index in ds) {
      emailList.add(index.data['Email']);
      emailPwd[index.data['Email']] = index.data['Password'];
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    double deviceFont = MediaQuery.of(context).textScaleFactor;
    final register = FlatButton.icon(
      icon: Icon(
        Icons.person_add,
        color: Color(0xff243b55),
      ),
      label: Text(
        'Register  $deviceFont',
        style: TextStyle(color: Color(0xff243b55)),
      ),
      onPressed: this._busy
          ? null
          : () async {
              setState(() => this._busy = true);
              Route route = MaterialPageRoute(builder: (context) => Register());
              Navigator.push(context, route);
              setState(() => this._busy = false);
            },
    );

    _saveUser(String k) async {
      final prefs = await SharedPreferences.getInstance();
      final key = 'currentUser';
      final value = k;
      prefs.setString(key, value);
    }

    final googleLoginBtn = IconButton(
      icon: Icon(
        Icons.login,
        color: Colors.green,
      ),
      onPressed: () async {
        var BD = new AlertDialog(
            title: Text("Invalid Email"), content: Text("Please, try again!"));
        emailList.contains(txtemail.text)
            ? null
            : showDialog(context: context, child: BD);
        var AD = new AlertDialog(
          title: Text("Incorrect Password"),
          content: Text("Please, try again!"),
        );
        emailList.contains(txtemail.text)
            ? null
            : showDialog(context: context, child: BD);
        Route route = MaterialPageRoute(builder: (context) => MyHomePage());
        QuerySnapshot _userqs;
        DocumentSnapshot _userds;
        String _pwd;
        _userqs = await Firestore.instance
            .collection('employee')
            .where('Email', isEqualTo: txtemail.text)
            .getDocuments();
        _userds = _userqs.documents.single;
        this.setState(() {
          password = _userds.data['Password'];
          _pwd = _userds.data['Password'];
        });
        emailPwd[txtemail.text] == txtpwd.text
            ? globals.currentEmail = txtemail.text
            : null;
        emailPwd[txtemail.text] == txtpwd.text
            ? _saveUser(txtemail.text)
            : null;
        emailPwd[txtemail.text] == txtpwd.text
            ? Navigator.push(context, route)
            : showDialog(context: context, child: AD);
      },
    );

    SystemChrome.setEnabledSystemUIOverlays([]);
    return  Scaffold(
        resizeToAvoidBottomPadding: true,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: CachedNetworkImageProvider('https://i.pinimg.com/originals/ac/17/56/ac17564a5b9ce3ba5bf49b0142ecfa24.jpg'),
              fit: BoxFit.fill,
            )
          ),
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.2,
                  MediaQuery.of(context).size.height * 0.2,
                  MediaQuery.of(context).size.width * 0.2,
                  MediaQuery.of(context).size.height * 0.2,
                ),
                height: MediaQuery.of(context).size.height * 0.6,
                child: ListView(
                  children: [
                    Center(
                        child: Text(
                          'Welcome!',
                          style: TextStyle(fontSize: 25/MediaQuery.textScaleFactorOf(context),color: Colors.white,),
                        )),
                    Center(
                        child: Text(
                          'Please Sign In To Continue!',
                          style: TextStyle(fontSize: 15/MediaQuery.textScaleFactorOf(context),color: Colors.white,),
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    TextField(
                      controller: txtemail,
                      style: TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context),color: Colors.white),
                      decoration: InputDecoration(
                          labelText: 'Email', border: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context),color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    TextField(
                      controller: txtpwd,
                      style: TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context),color: Colors.white),
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Password', border: InputBorder.none,
                        labelStyle: TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context),color: Colors.white),
                      ),
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.064,
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                          ),
                          borderRadius: BorderRadius.circular(14)),
                      child: googleLoginBtn,
                    ),
                    SizedBox(
                      height: 14,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.064,
                      decoration: BoxDecoration(
                          border: Border.all(color: Color(0xff243b55)),
                          borderRadius: BorderRadius.circular(14)),
                      child: register,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

// Sign in with Google.
}
