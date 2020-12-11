library my_prj.globals;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gpx/gpx.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:htd/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:htd/main.dart';
import 'dart:io';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:htd/dnsnMarkers.dart';
import 'package:latlong/latlong.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

bool isLoggedIn = false;
FirebaseUser currentUser;
String currentEmail='none';
bool isTdyCheckedIn = false;
File image;
String filename;
DocumentSnapshot currentUserDocumentSnapshot;
List<String> zoneList = [
  'Ahlon',
  'Bahan',
  'Botataung',
  'Cocokyun',
  'Dagon',
  'DagonSeikkan',
  'Dala',
  'Dawbon',
  'Hlaing',
  'Hlaingthaya',
  'Hlegu',
  'Hmawbi',
  'Htantabin',
  'Insein',
  'Kamayut',
  'Kawhmu',
  'Khayan',
  'Kungyangon',
  'Kyauktada',
  'Kyauktan',
  'Kyimyindaing',
  'Lanmadaw',
  'Latha',
  'Mayangon',
  'MingalaTaungnyunt',
  'Mingaladon',
  'NewDagonEast',
  'NewDagonNorth',
  'NewDagonSouth',
  'NorthOkkalapa',
  'Pabedan',
  'Pazundaung',
  'Sanchaung',
  'Seikkan',
  'SeikkyiKanaungto',
  'Shwepyitha',
  'SouthOkkalapa',
  'Taikkyi',
  'Tamwe',
  'Thaketa',
  'Thanlyin',
  'Thingangyun',
  'Thongwa',
  'Twante',
  'Yankin'
];

String selectedZone = zoneList[0];


List<DropdownMenuItem> getZones(){
  List<DropdownMenuItem> zoneDrop = [
  ];
  for(final index in zoneList)
    {
      zoneDrop.add(
        DropdownMenuItem(child: Text(index,),value: index.toString(),)
      );
    }
  return zoneDrop;
}

bool getCurrentEmail (){
  return currentEmail=='none'?false:true;
}


final ZoneDropdown = new DropdownButton(
  value: selectedZone,
  items: zoneList
      .map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          ))
      .toList(),
  onChanged: (value) {
    selectedZone = value;
  },
);

Widget zoneDropDown()
{
  return zoneDropDown();
}

String DateNow() {
  return DateTime.now().toString().substring(0, 10);
}
LinearGradient bgColor()
{
  return  LinearGradient(
    colors: [Color(0xffffffff), Color(0xffffffff)],
  );
}

TextStyle getTextStyle(BuildContext context)
{
  return  TextStyle(fontSize: 14/MediaQuery.textScaleFactorOf(context));
}

String TimeNow() {
  return DateTime.now().toString().substring(11, 16);
}

ThemeData getThemeData(BuildContext context)
{
  return ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    buttonColor: Colors.blue,
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
  );
}

Future<DateTime> chooseDate(BuildContext context) async {
  final DateTime picked = await showDatePicker(
    context: context,
    builder: (BuildContext context, Widget child) {
      return Theme(
        data: ThemeData.light().copyWith(
          primaryColor: const Color(0xff243b55),
          accentColor: const Color(0xFF8CE7F1),
          dialogBackgroundColor: const Color(0xfffffff0),
          colorScheme: ColorScheme.light(primary: const Color(0xff243b55)),
          buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary
          ),
        ),
        child: child,
      );
    },
    initialDatePickerMode: DatePickerMode.day,
    initialDate: DateTime.now(),
    firstDate: DateTime(1970, 12),
    lastDate: DateTime(2222, 12),
  );
  if (picked != null) return DateTime(picked.year, picked.month, picked.day);
  if (picked == null) return DateTime.now();
}

Future<Position> chooseLocation(BuildContext context) async {
  final Position picked = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
  return picked;
}

void GoToHome(BuildContext context) {
  Route route = MaterialPageRoute(builder: (context) => MyHomePage());
  Navigator.pop(context, route);
}

Future<String> uploadImageCloud(var imageFile, var customerID,DateTime date) async {
  var Rand1 = new Random().nextInt(999);
  var Rand2 = new Random().nextInt(999);
  var Rand3 = new Random().nextInt(999);
  var fullImageName = customerID.toString() +
      '$Rand1$Rand2$Rand3.jpg';
  final StorageReference refImg = FirebaseStorage.instance.ref().child(
      DateTime.fromMillisecondsSinceEpoch(date.millisecondsSinceEpoch)
      .toString()
      .substring(0, 10) +
      '/' +
     customerID+
      '/' +
      fullImageName);
  StorageUploadTask uploadTask = refImg.putFile(imageFile);
  var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
  return dowurl;
}

Future<File> cameraOpen() async {
  File img = await ImagePicker.pickImage(source: ImageSource.camera);
  if (img != null) {
    return img;
  }
}

Future<File> galleryOpen() async {
  File img = await FilePicker.getFile(type: FileType.image,);
  if (img != null) {
    return img;
  }
}



Future<String> getProfileName() async {
  final prefs = await SharedPreferences.getInstance();
  QuerySnapshot qs;
  prefs.getString('currentUser')==null?qs=null:
  await Firestore.instance
      .collection('employee')
      .where('Email', isEqualTo: await prefs.getString('currentUser'))
      .getDocuments();
  return qs==null?'none':qs.documents.first.data['Name'];
}

void showAlertDialog(BuildContext ct,String title,Widget content,List<Widget> action)
{
  showDialog(
      context: ct,
      child: AlertDialog(
        title: Text(title),
        content: content,
        actions: action,
      )
  );
}

void showHero(BuildContext ct,String url)
{
  showDialog(
      context: ct,
      child: AlertDialog(
        title: CachedNetworkImage(
          imageUrl: url,
        ),
      )
  );
}

var pictureRecorder; var canvas; var textPainter; var iconStr;
final iconData = Icons.router;
BitmapDescriptor myIcon;
Future<BitmapDescriptor> getMapDataIcon() async {
  pictureRecorder = new PictureRecorder();
  canvas = Canvas(pictureRecorder);
  textPainter = TextPainter(textDirection: TextDirection.ltr);
  iconStr = String.fromCharCode(iconData.codePoint);
  textPainter.text = TextSpan(
      text: iconStr,
      style: TextStyle(
        letterSpacing: 0.0,
        fontSize: 60.0,
        fontFamily: iconData.fontFamily,
        color: Colors.greenAccent,
      )
  );
  textPainter.layout();
  textPainter.paint(canvas, Offset(0.0, 0.0));
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(48, 48);
  final bytes = await image.toByteData(format: ImageByteFormat.png);
  myIcon =
      BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());

  return myIcon;
}

class SizeConfig {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;
  static double _safeAreaHorizontal;
  static double _safeAreaVertical;
  static double safeBlockHorizontal;
  static double safeBlockVertical;
  static double textScaleFactor;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    textScaleFactor = _mediaQueryData.textScaleFactor;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth/100;
    blockSizeVertical = screenHeight/100;
    _safeAreaHorizontal = _mediaQueryData.padding.left +
        _mediaQueryData.padding.right;
    _safeAreaVertical = _mediaQueryData.padding.top +
        _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal)/100;
    safeBlockVertical = (screenHeight - _safeAreaVertical)/100;
  }
}




