import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/ChatGroup.dart';
import 'package:htd/pages/Calender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:htd/main.dart';
import 'package:htd/pages/TimeSheet.dart';
import 'package:htd/pages/Staff.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:htd/pages/AllMap.dart';
import 'package:htd/pages/Profile.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'pages/CheckIn.dart';
import 'package:htd/pages/Login.dart';
import 'package:htd/pages/Inventory.dart';
import 'package:htd/globals.dart' as globals;
import 'package:geolocator/geolocator.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'dart:ui' as ui;

Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

bool isLoggedIn = false;
FirebaseUser _currentUser;
Position _currentLocation;
String pageToShow;
TextEditingController txtWhat = new TextEditingController();

class HomeTabPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Theme.of(context).backgroundColor,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonColor: Colors.greenAccent,
        backgroundColor: hexToColor('#FFFFFF'),
        cardColor: hexToColor('#FFFFFF'),
        inputDecorationTheme: InputDecorationTheme(
            fillColor: hexToColor('#FFFFFF'),
            labelStyle: TextStyle(
              color: hexToColor('#525163'),
            )),
      ),
      title: 'HTD Home Page',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var showPage;
  @override
  void initState() {
    showPage = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: globals.bgColor(),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      child: FlatButton(onPressed: () => this.setState(() {
                        showPage=1;
                      }),
                          child: Text('Newsfeed',style: showPage!=1?TextStyle():TextStyle(color: Colors.blueAccent),),),
                    ),
                    Container(
                      child: FlatButton(onPressed:() => this.setState(() {
                        showPage=2;
                      }),
                        child: Text('Activities',style: showPage!=2?TextStyle():TextStyle(color: Colors.blueAccent),),),
                    )
                  ],
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.blueGrey)),
                  margin: EdgeInsets.all(20),
                  child: showPage==1?showNFPanel():showActivitiesPanel(),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.08,
                    margin: EdgeInsets.all(20),
                    child: newsfeedpanel()),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  margin: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            FlatButton(
                                onLongPress: () {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text("Check-In"),
                                  ));
                                },
                                child: Card(
                                  elevation: 10,
                                  child: Container(
                                    height: 60,
                                    width:60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.timer),
                                  ),
                                ),
                              onPressed: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context) =>CheckIn()));
                              },
                            ),
                            Text('Check-In',style: TextStyle(),),
                          ],
                        ),
                        Column(
                          children: [
                            FlatButton(
                              onPressed: (){
                                Route route = MaterialPageRoute(builder: (context) => allMap());
                                Navigator.push(context, route);
                              },
                                onLongPress: () {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text("Map"),
                                  ));
                                },
                                child: Card(
                                  elevation: 10,
                                  child: Container(
                                    height: 60,
                                    width:60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.map),
                                  ),
                                )),
                            Text('Map',style: TextStyle(),),
                          ],
                        ),
                        Column(
                          children: [
                            FlatButton(
                                onLongPress: () {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    duration: Duration(seconds: 3),
                                    content: Text("Add Pole"),
                                  ));
                                },
                                child: Card(
                                  elevation: 10,
                                  child: Container(
                                    height: 60,
                                    width:60,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.plus_one),
                                  ),
                                )),
                            Text('Add Pole',style: TextStyle(),),
                          ],
                        ),
                        Column(
                          children: [
                            FlatButton(
                              onLongPress: () {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  duration: Duration(seconds: 3),
                                  content: Text("Log Out"),
                                ));
                              },
                              child: Card(
                                elevation: 10,
                                child: Container(
                                  height: 60,
                                  width:60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.logout),
                                ),
                              ),
                              onPressed: () async{
                                globals.currentEmail = null;
                                final prefs = await SharedPreferences.getInstance();
                                prefs.remove('currentUser');
                                prefs.clear();
                                Phoenix.rebirth(context);
                              },
                            ),
                            Text('Log Out',style: TextStyle(),),
                          ],
                        ),
                        Column(
                          children: [
                            FlatButton(
                              onLongPress: () {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  duration: Duration(seconds: 3),
                                  content: Text("Calender"),
                                ));
                              },
                              child: Card(
                                elevation: 10,
                                child: Container(
                                  height: 60,
                                  width:60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.calendar_today),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(context,MaterialPageRoute(builder: (context) =>Calendar()));
                              },
                            ),
                            Text('Calender',style: TextStyle(),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget newsfeedpanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: TextField(
              textInputAction: TextInputAction.newline,
              maxLines: null,
              decoration: InputDecoration(
                enabledBorder:  OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                  borderRadius: BorderRadius.circular(20),
                ),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(20),
                ),
                
              ),
              style:
              GoogleFonts.carterOne(fontSize: 18, color: Colors.blueGrey),
              controller: txtWhat,
            ),
          ),
          txtWhat.text == ""
              ? IconButton(
            icon: Icon(
              Icons.send,size: 20,
              color: Colors.black,
            ),
            onPressed: () {},
          )
              : IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.greenAccent,
            ),
            onPressed: () async {
              var email = await SharedPreferences.getInstance();
              var name = await Firestore.instance
                  .collection('employee')
                  .where('Email', isEqualTo: email.get('currentUser'))
                  .getDocuments();
              Firestore.instance.collection('newsfeed').add({
                'who': name.documents.first.data['Name'],
                'what': txtWhat.text,
                'when': Timestamp.now(),
              });
              txtWhat.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget showNFPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: Scrollbar(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection("newsfeed")
                .orderBy('when', descending: true)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Fetching Data..."),
                      ],
                    ),
                  ),
                );
              }
              int length = snapshot.data.documents.length;
              return ListView.builder(
                  itemCount: length,
                  itemBuilder: (_, int index) {
                    final DocumentSnapshot doc =
                    snapshot.data.documents[index];
                    Timestamp _when = doc.data['when'];

                    var k;
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_when.toDate().toString().substring(0,16),style: TextStyle(color: Colors.lightBlueAccent),),
                            Text(doc.data['who'],style: TextStyle(color: Colors.greenAccent),)
                          ],
                        ),
                        Text(doc.data['what'],style: TextStyle(),),
                        Divider(),
                      ],
                    );
                  });
            }),
      ),
    );
  }
  Widget showActivitiesPanel() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      child: Scrollbar(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection("activities")
                .orderBy('when', descending: true)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Fetching Data..."),
                      ],
                    ),
                  ),
                );
              }
              int length = snapshot.data.documents.length;
              return ListView.builder(
                  itemCount: length,
                  itemBuilder: (_, int index) {
                    final DocumentSnapshot doc =
                    snapshot.data.documents[index];
                    var k;
                    return Column(
                      children: [
                        Text(doc.data['when'],style: TextStyle(color: Colors.lightBlueAccent),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(doc.data['who'],style: TextStyle(color: Colors.greenAccent),),
                            Text(doc.data['what'],style: TextStyle(),),
                          ],
                        ),
                        Divider(),
                      ],
                    );
                  });
            }),
      ),
    );
  }
}
