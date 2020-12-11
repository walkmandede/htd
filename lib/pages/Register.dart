import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'Login.dart';
import 'package:geolocator/geolocator.dart';
import 'package:htd/globals.dart' as globals;
import 'package:htd/main.dart';
import 'dart:io';
import 'dart:math';

final kFirebaseAnalytics = FirebaseAnalytics();

class Register extends StatefulWidget {
  const Register({Key key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String fullImageName;
  File profileImage;
  TextEditingController empName = new TextEditingController();
  TextEditingController empStaffID = new TextEditingController();
  TextEditingController empAddress = new TextEditingController();
  TextEditingController empEmail = new TextEditingController();
  TextEditingController empPhone = new TextEditingController();
  TextEditingController empBranch = new TextEditingController();
  TextEditingController empPassword = new TextEditingController();
  TextEditingController confirmPwd = new TextEditingController();
  TextEditingController empNRC = new TextEditingController();
  bool isMatched = true;
  bool confirm = false;
  List<String> emailLists = [];
  bool isExist = false;

  Future<String> uploadImageToCloud(var imageFile) async {
    var Rand1 = new Random().nextInt(999);
    var Rand2 = new Random().nextInt(999);
    var Rand3 = new Random().nextInt(999);
    fullImageName = empName.text + '$Rand1$Rand2$Rand3.jpg';
    final StorageReference refImg =
        FirebaseStorage.instance.ref().child('ProfilePictures' + fullImageName);
    StorageUploadTask uploadTask = refImg.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl;
  }

  camPowerMeterLosses() async {
    File img = await ImagePicker.pickImage(source: ImageSource.camera);
    if (img != null) {
      profileImage = img;
      setState(() {});
    }
  }

  galleryPowerMeterLosses() async {
    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      profileImage = img;
      setState(() {});
    }
  }

  Future<void> getEmails() async {
    QuerySnapshot qs;
    qs = await Firestore.instance.collection('employee').getDocuments();
    qs.documents.forEach((element) {
      this.setState(() {
        emailLists.add(element.documentID);
      });
    });
  }

  @override
  void initState() {
    getEmails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.blueGrey,
      body: Center(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height * 0.05),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.white])),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: EdgeInsets.all(10),
                child: Text(
                  '𝐑𝐞𝐠𝐢𝐬𝐭𝐞𝐫',
                  style: TextStyle(
                      color: Color(0xffdbc3aa),
                      fontSize: 40,
                      fontWeight: FontWeight.w900),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              new Container(
                height: 140.0,
                width: 140.0,
                decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.grey),
                ),
                padding: new EdgeInsets.all(5.0),
                child: profileImage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new IconButton(
                              icon: new Icon(Icons.camera_alt),
                              onPressed: camPowerMeterLosses),
                          Divider(),
                          new IconButton(
                              icon: new Icon(Icons.image),
                              onPressed: galleryPowerMeterLosses),
                        ],
                      )
                    : Image.file(
                        profileImage,
                        fit: BoxFit.fill,
                      ),
              ),
              Center(
                child: FlatButton.icon(
                    onPressed: () {
                      this.setState(() {
                        profileImage = null;
                      });
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey,
                    ),
                    label: Text(
                      'Clear',
                      style: TextStyle(color: Colors.grey),
                    )),
              ),
              Divider(),
              Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Name',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empName,
                          cursorColor: Colors.grey,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empEmail,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                          onChanged: (value) {
                            var ad = AlertDialog(
                              title: Text('Email already exists'),
                            );
                            emailLists.contains(empEmail.text)
                                ? this.setState(() {
                                    isExist = true;
                                  })
                                : this.setState(() {
                                    isExist = false;
                                  });
                            emailLists.contains(empEmail.text)
                                ? showDialog(context: context, child: ad)
                                : null;
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'NRC',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empNRC,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Staff ID',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empStaffID,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empAddress,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Phone',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empPhone,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: false, signed: false),
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Branch',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empBranch,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        TextField(
                          decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey)),
                          controller: empPassword,
                          style: TextStyle(color: Colors.blueGrey),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          onChanged: (value) => {
                            if (value == empPassword.text)
                              {
                                this.setState(() {
                                  confirm = false;
                                })
                              }
                            else
                              {
                                this.setState(() {
                                  confirm = true;
                                })
                              },
                          },
                          onSubmitted: (value) {
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        Container(
                          child: TextField(
                            decoration: InputDecoration(
                              suffix: confirm
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : null,
                              labelText: isMatched
                                  ? 'Re-write password'
                                  : 'Password does not match!',
                              labelStyle: TextStyle(
                                color: isMatched ? Colors.grey : Colors.red,
                              ),
                            ),
                            controller: confirmPwd,
                            style: TextStyle(color: Colors.blueGrey),
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            onChanged: (value) => {
                              if (value != empPassword.text)
                                {
                                  this.setState(() {
                                    isMatched = false;
                                    confirm = false;
                                  })
                                }
                              else
                                {
                                  this.setState(() {
                                    isMatched = true;
                                    confirm = true;
                                  })
                                },
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Divider(),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: RaisedButton(
                            color: Colors.blueGrey,
                            child: Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: empName.text.isEmpty ||
                                    empStaffID.text.isEmpty ||
                                    empPhone.text.isEmpty ||
                                    empBranch.text.isEmpty ||
                                    empNRC.text.isEmpty ||
                                    empAddress.text.isEmpty ||
                                    empEmail.text.isEmpty ||
                                    empPassword.text.isEmpty ||
                                    profileImage == null ||
                                    isExist ||
                                    confirm == false
                                ? () {
                                    var AD = new AlertDialog(
                                      title: Text("Missing Data"),
                                      content: Text(
                                          "Please, make sure that all fields are filled up!"),
                                    );
                                    showDialog(context: context, child: AD)
                                        .timeout(Duration(seconds: 3));
                                  }
                                : () async {
                                    var AD = new AlertDialog(
                                      title: Text("Success"),
                                      content: Text(
                                          "Please, wait for a moment of data saving!"),
                                    );
                                    showDialog(context: context, child: AD)
                                        .timeout(Duration(seconds: 3));
                                    String proPath =
                                        "https://www.kindpng.com/picc/m/495-4952535_create-digital-profile-icon-blue-user-profile-icon.png";
                                    proPath =
                                        await uploadImageToCloud(profileImage);
                                    Firestore.instance
                                        .collection('employee')
                                        .document(empEmail.text)
                                        .setData({
                                      'Name': empName.text,
                                      'Email': empEmail.text,
                                      'NRC': empNRC.text,
                                      'ID': empStaffID.text,
                                      'Address': empAddress.text,
                                      'Phone': empPhone.text,
                                      'Branch': empBranch.text,
                                      'Password': empPassword.text,
                                      'Picture': proPath,
                                      'attendance':[],
                                      'leave':[],
                                    }).whenComplete(() {
                                      globals.currentEmail = empEmail.text;
                                      Route route = MaterialPageRoute(
                                          builder: (context) => FirebaseLoginExample());
                                      Navigator.push(context, route);
                                    }).catchError(FlutterError.onError);
                                  },
                          ),
                        )
                      ]))
            ]),
          ),
        ),
      ),
    );
  }
}
