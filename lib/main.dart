import 'dart:math';
import 'package:backdrop/backdrop.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/ChatGroup.dart';
import 'package:htd/ChatPanel.dart';
import 'package:htd/Home.dart';
import 'package:htd/LeaveForm.dart';
import 'package:htd/HelpPage.dart';
import 'package:htd/PlayChess.dart';
import 'package:htd/YTP_Email.dart';
import 'package:htd/YTP_IN.dart';
import 'package:htd/YTP_IN_Edit.dart';
import 'package:htd/internetCheck.dart';
import 'package:htd/locator.dart';
import 'package:htd/pages/Calender.dart';
import 'package:htd/pages/CheckIn.dart';
import 'package:htd/pages/DNSN.dart';
import 'package:htd/pages/MyCalender.dart';
import 'package:htd/pages/NewBusinessPartner.dart';
import 'package:htd/pages/TimeSheet.dart';
import 'package:htd/pages/Staff.dart';
import 'package:htd/pages/Operation.dart';
import 'package:htd/pages/AllMap.dart';
import 'package:htd/pages/cardChecking.dart';
import 'package:htd/pages/roomList.dart';
import 'package:htd/pages/roomListShweShan.dart';
import 'package:htd/pages/towerGameList.dart';
import 'package:htd/push_notification_service.dart';
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
import 'package:url_launcher/url_launcher.dart';

/*
Theme colors for this app
Input Field
            color: hexToColor('#31344A'),
Background
            color: hexToColor('#42455A'),
Label Color on input
            color: hexToColor('#525163'),
Buttons and Bar
            color: hexToColor('#292839'),
 */
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

bool isLog = false;
final _pushNotificationService = locator<PushNotificationService>();

void _notiInit() async {
  await _pushNotificationService.initialise();
}

void _readUser() async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'currentUser';
  final value = prefs.getString(key) ?? 'none';
  value == 'none' ? isLog = false : isLog = true;
}

_saveUser(String k) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'currentUser';
  final value = k;
  prefs.setString(key, value);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  RenderErrorBox.backgroundColor = Colors.transparent;
  RenderErrorBox.textStyle = ui.TextStyle(color: Colors.transparent);
  _readUser();
  _notiInit();
  RenderErrorBox('Please Wait');
  runApp(
    Phoenix(
      child: Center(child: MyApp()),
    ),
  );
}

bool isLoggedIn = false;
FirebaseUser _currentUser;
Position _currentLocation;
String pageToShow;
SharedPreferences prefs;



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Theme.of(context).backgroundColor,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        buttonColor: Colors.green,
          textTheme: TextTheme(
            caption:  TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),
            button:   TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),
            overline:  TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),
          ),
          primaryTextTheme: TextTheme(
            caption:  TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),
            button:   TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),
            overline:  TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),
          ),
        inputDecorationTheme: InputDecorationTheme(
            fillColor: hexToColor('#FFFFFF'),
            labelStyle: TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context)),),
      ),
      title: 'HTD Home Page',
      home: MyAppPage());
  }
}

class MyAppPage extends StatefulWidget {
  const MyAppPage();

  @override
  _MyAppPageState createState() {
    return _MyAppPageState();
  }
}

class _MyAppPageState extends State<MyAppPage> {
  Key key = UniqueKey();

  @override
  void initState() {
    setState(() {});
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        color: Theme.of(context).backgroundColor,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonColor: Colors.greenAccent,
          backgroundColor: hexToColor('#FFFFFF'),
          cardColor: hexToColor('#FFFFFF'),
            textTheme: TextTheme(
              caption:  TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),
              button:   TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),
              overline:  TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),
            ),
            primaryTextTheme: TextTheme(
              caption:  TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),
              button:   TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),
              overline:  TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),
            )
        ),
        title: 'HTD Home Page',
        home: isLog ? MyHomePage() : FirebaseLoginExample(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var k;
  int index;
  String currentUser = '';
  String today;
  DateTime tdy;
  String currentVersion ='1.0.3';

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  DocumentSnapshot myProfile;
  DocumentSnapshot chckData;
  bool isDrag = false;

  AppLifecycleState _notification;
  Offset ofs;
  int showPageIndex=0;
  Widget showPage;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    setState(() {
      _notification = state;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    QuerySnapshot ss = await Firestore.instance
        .collection('employee')
        .where('Email', isEqualTo: prefs.getString('currentUser'))
        .getDocuments();
    ss.documents.first.reference.setData(
      {
        'currentState': WidgetsBinding.instance.lifecycleState.index,
      },
      merge: true,
    );
  }

  Future<void> readUser() async {}

  Future<void> getData() async {

    final prefs = await SharedPreferences.getInstance();
    tdy = DateTime.now();
    today = tdy.day.toString() +
        '-' +
        tdy.month.toString() +
        '-' +
        tdy.year.toString();

    DocumentReference ds = await Firestore.instance
        .collection('employee')
        .document(prefs.getString('currentUser'));
    ds.get().then((value) => this.setState(() {
          myProfile = value;
        }));

    chckData =
        await Firestore.instance.collection('CheckIn').document(today).get();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getData();
    readUser();
    index = 2;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return new WillPopScope(
        onWillPop: () async => false,
        child: BackdropScaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.green,
            elevation: 0,
            title: Text('Green Burma v($currentVersion)',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 14/MediaQuery.textScaleFactorOf(context)),),
            centerTitle: true,
            leading: BackdropToggleButton(
              icon: AnimatedIcons.close_menu,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.chat),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPanel()));
                },
              )
            ],
          ),
          backLayerBackgroundColor: Colors.green,
          backLayer: mainProfilePage(),
          frontLayer: Calendar(),
        )
    );
  }



  Widget mainProfilePage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.green.shade200,borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Profile',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () async{
                        SharedPreferences sp = await SharedPreferences.getInstance();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile(sp.getString('currentUser'))));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Log Out',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () async {
                        globals.currentEmail = null;
                        final prefs =
                        await SharedPreferences.getInstance();
                        prefs.remove('currentUser');
                        prefs.clear();
                        Phoenix.rebirth(context);
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text('Logged Out Success!'),
                            ));
                        main();
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade200,borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Add Sites',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => CupertinoActionSheet(
                            title: Text('What You Wanna Do?'),
                            actions: [
                              CupertinoActionSheetAction(
                                child: Text('Installation Site'),
                                onPressed: () async{
                                  Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => YTP_In('Install'),));
                                },
                              ),
                              CupertinoActionSheetAction(
                                child: Text('Maintain Site'),
                                onPressed: () async{
                                  Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => YTP_In('Maintain'),));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('All Sites',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () async{
                        ClipboardData data = await Clipboard.getData('text/plain');
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) =>Operation()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('By Email',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () async{
                        ClipboardData data = await Clipboard.getData('text/plain');
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) =>YTP_Email(data.text)));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.green.shade200,borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('People',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Staff()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('New Partner',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewBusinessPartner()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Check In',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CheckIn()));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.green.shade200,borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Ref Map',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CheckCard()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('GB Map',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DNSNMap()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Tower',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TowerList()));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.green.shade200,borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Koe Mee',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RoomList()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Shwe Shan',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ShweShanList()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Tower',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TowerList()));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.green.shade200,borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Help',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HelpPage()));
                      },
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Update',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () async{
                        DocumentSnapshot ds = await Firestore.instance.collection('AppUpdate').document('AppUpdate').get();
                        String latestVersion  = ds.data['version'];
                        showDialog(
                          context: context,
                          child: AlertDialog(
                            title: latestVersion==currentVersion
                            ?Text('Your App is latest version!',style: TextStyle(color: Colors.green,fontSize: 20/MediaQuery.textScaleFactorOf(context)),)
                            :FlatButton(
                              child: Text('Update Available! Click to download!',style: TextStyle(color: Colors.red,fontSize: 20/MediaQuery.textScaleFactorOf(context)),),
                              onPressed: () async{
                                await launch(ds.data['link']);
                              },
                            ),
                          )
                        );
                      }
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.25,
                  decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all(color: Colors.black)
                  ),
                  child: Center(
                    child: FlatButton(
                      child: Text('Exit',style: TextStyle(fontSize: 12/MediaQuery.textScaleFactorOf(context)),),
                      onPressed: () {

                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 40,)
        ],
      ),
    );
  }
}
