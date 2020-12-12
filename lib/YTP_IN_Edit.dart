import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmp;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/Home.dart';
import 'package:latlong/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:htd/pages/AllMap.dart' as dnsnMap;
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:htd/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class YTP_IN_Edit extends StatelessWidget {
  final DocumentSnapshot docID;

  const YTP_IN_Edit(this.docID);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.green.shade100,
        body: YTP_IN_EditForm(docID),
        appBar: AppBar(
          backgroundColor: Colors.green.shade100,
          elevation: 0,
        ),
      ),
    );
  }
}

class YTP_IN_EditForm extends StatefulWidget {
  final DocumentSnapshot docID;

  const YTP_IN_EditForm(this.docID);

  @override
  _YTP_IN_EditFormState createState() => _YTP_IN_EditFormState();
}

class _YTP_IN_EditFormState extends State<YTP_IN_EditForm> {
  String dnsnImg;
  String lossesImg;
  String portImg;
  String powerMeterImg;
  String deviceFrontImg;
  String deviceBackImg;
  String ssrImg;
  String feedbackImg;
  String speedTest;
  String usedPoles;
  String dropZone;
  String Zone;

  DateTime receivedDate;
  DateTime installationDate;
  TextEditingController customerName = TextEditingController();
  TextEditingController bandwidth = TextEditingController();
  TextEditingController customerID = TextEditingController();
  TextEditingController ttNO = TextEditingController();
  TextEditingController remark = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phone1 = TextEditingController();
  TextEditingController phone2 = TextEditingController();

  TextEditingController startMeter = TextEditingController();
  TextEditingController endMeter = TextEditingController();
  TextEditingController dnsn = TextEditingController();
  TextEditingController subZone = TextEditingController();
  TextEditingController dn = TextEditingController();
  TextEditingController sn = TextEditingController();
  TextEditingController dnsnPorts = TextEditingController();
  TextEditingController port = TextEditingController();
  TextEditingController dnsnLatlng = TextEditingController();
  TextEditingController customerType = TextEditingController();
  TextEditingController buildingType = TextEditingController();
  TextEditingController engrCmt = TextEditingController();
  GeoPoint homeLocation;

  TextEditingController usedDevice = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController fastConnector = TextEditingController();
  TextEditingController dropCable = TextEditingController();
  TextEditingController siteExpense = TextEditingController();
  TextEditingController txtNewPoleLoc = TextEditingController();
  MapControllerImpl mpl = new MapControllerImpl();
  QuerySnapshot fcData;
  QuerySnapshot dcData;
  List<DocumentSnapshot> _poleDS;
  List<DropdownMenuItem> poleList = [];
  String _pole;
  String showPage;
  String _onu;
  String usedDevicetoShow = 'none';
  List<DropdownMenuItem> ONUList = [];
  List<DocumentSnapshot> _onuDS = [];
  bool isPhoto = false;
  LatLng routeDataCenter;
  CollectionReference dnsnCr;
  List<String> dnsnList = [];
  List poleData = [];
  bool isLoaded = false;
  List<Marker> poleMarkerList=[];

  void initState() {
    getData();
    showPage = 'site';
    super.initState();
  }

  var fullImageName;

  Future<String> uploadImageToCloud(var imageFile) async {
    var Rand1 = new Random().nextInt(999);
    var Rand2 = new Random().nextInt(999);
    var Rand3 = new Random().nextInt(999);
    fullImageName = widget.docID.data["customerName"].trim() +
        '-' +
        widget.docID.data["customerID"] +
        '$Rand1$Rand2$Rand3.jpg';
    final StorageReference refImg = FirebaseStorage.instance.ref().child(
        DateTime.fromMillisecondsSinceEpoch(
            widget.docID.data["receivedDate"].millisecondsSinceEpoch)
            .toString()
            .substring(0, 10) +
            '/' +
            widget.docID.data["customerID"] +
            '/' +
            fullImageName);
    StorageUploadTask uploadTask = refImg.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl;
  }

  Future<void> getData() async {
    Position p = await Geolocator().getCurrentPosition();
    txtNewPoleLoc.text = p.latitude.toString().substring(0, 9) +
        ',' +
        p.longitude.toString().substring(0, 9);
    // routeDataCenter = new LatLng(p.latitude, p.longitude);
    dnsnCr = await Firestore.instance.collection('DNSN');
    QuerySnapshot qs = await dnsnCr.getDocuments();
    qs.documents.forEach((element) {
      dnsnList.add(element.documentID);
    });

    QuerySnapshot onuQS = await Firestore.instance
        .collection('device')
        .where('usedBy', isEqualTo: 'new')
        .getDocuments();
    List<DocumentSnapshot> onuDS = onuQS.documents.toList();
    // setState(() {
    //   _onuDS = onuDS;
    // });
    for (final index in onuDS) {
      String s = index.data['deviceSerial'];
      ONUList.add(DropdownMenuItem(
        value: s,
        child: Text(s),
      ));
    }
    Timestamp rDate, iDate;
    homeLocation = widget.docID.data['homeLocation'];
    poleData = widget.docID.data['poles'];
    rDate = widget.docID.data['receivedDate'];
    iDate = widget.docID.data['installationDate'];
    usedDevicetoShow = widget.docID.data['usedDevice'];
    ttNO.text =  widget.docID.data['ttNo'];
    engrCmt.text =  widget.docID.data['engineerComment'];
    receivedDate = rDate.toDate();
    installationDate = iDate.toDate();
    customerName.text = widget.docID.data['customerName'];
    customerID.text = widget.docID.data['customerID'];
    remark.text = widget.docID.data['remark'];
    Position currentLoc = await Geolocator().getCurrentPosition();
    dnsnLatlng.text = currentLoc.latitude.toString()+','+currentLoc.longitude.toString();
    bandwidth.text = widget.docID.data['bandwidth'];
    address.text = widget.docID.data['address'];
    phone1.text = widget.docID.data['phone1'];
    phone2.text = widget.docID.data['phone2'];
    bandwidth.text = widget.docID.data['bandwidth'];
    customerType.text = widget.docID.data['customerType'];
    buildingType.text = widget.docID.data['buildingType'];

    startMeter.text = widget.docID.data['startMeter'];
    endMeter.text = widget.docID.data['endMeter'];
    dnsn.text = widget.docID.data['dnsn'];
    port.text = widget.docID.data['port'];
    username.text = widget.docID.data['userName'];
    password.text = widget.docID.data['password'];
    fastConnector.text = widget.docID.data['fastConnectors'];
    dropCable.text = widget.docID.data['dropCable'];
    siteExpense.text = widget.docID.data['siteExpense'];
    if (dnsn.text!='')
    {
      dropZone = dnsn.text.split('-')[0];
      subZone.text=dnsn.text.split('-')[1];
      dn.text = dnsn.text.split('-')[2];
      sn.text = dnsn.text.split('-')[3];
    }
    else
      {
        dropZone = 'Twante';
      }
    poleData.forEach((element) {
      poleMarkerList.add(
        new Marker(
          point: LatLng(element.latitude,element.longitude),
          builder: (context) {
            return Icon(
              Icons.title,
              size: 20,
              color: Colors.green,
            );
          },
        )
      );
    });
    setState(() {
      isLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return !isLoaded?Container(child: Center(child: Text('Loading! Please Wait ...'),),):Container(
      decoration: BoxDecoration(
        color: Colors.green.shade100
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20),
          children: [
            SizedBox(
              height: 10,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FlatButton(
                      onPressed: () => this.setState(() {
                        showPage = 'site';
                      }),
                      child: Text(
                        'Site Data',
                        style: TextStyle(
                            color: showPage == 'site'
                                ? Colors.lightBlueAccent
                                : Colors.grey,
                            fontSize: 20/MediaQuery.textScaleFactorOf(context)),
                      )),
                  FlatButton(
                      onPressed: () => this.setState(() {
                        showPage = 'route';
                      }),
                      child: Text(
                        'Route Data',
                        style: TextStyle(
                            color: showPage == 'route'
                                ? Colors.lightBlueAccent
                                : Colors.grey,
                            fontSize: 20/MediaQuery.textScaleFactorOf(context)),
                      )),
                  FlatButton(
                      onPressed: () => this.setState(() {
                        showPage = 'local';
                      }),
                      child: Text(
                        'Local Data',
                        style: TextStyle(
                            color: showPage == 'local'
                                ? Colors.lightBlueAccent
                                : Colors.grey,
                            fontSize: 20/MediaQuery.textScaleFactorOf(context)),
                      )),
                  FlatButton(
                      onPressed: () => this.setState(() {
                        showPage = 'team';
                      }),
                      child: Text(
                        'Team Data',
                        style: TextStyle(
                            color: showPage == 'team'
                                ? Colors.lightBlueAccent
                                : Colors.grey,
                            fontSize: 20/MediaQuery.textScaleFactorOf(context)),
                      )),
                ],
              ),
            ),
            Divider(
              color: Colors.lightBlueAccent,
            ),
            showPage != 'site'
                ? SizedBox()
                : SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.4,
                          child: FlatButton.icon(onPressed: () =>this.setState(()async {
                            receivedDate=await chooseDate(context);
                            this.setState(() {

                            });
                          }) ,
                              icon: Icon(Icons.calendar_today,color: receivedDate==null?Color(0xfffffff0):Colors.blue,),
                              label: Text('Received Date\n ${receivedDate.toString().split(' ')[0]}',
                                style:  receivedDate==null?TextStyle():TextStyle(color: Colors.blue),)
                          ),
                        ),
                        FlatButton.icon(
                            onPressed: () {
                              int hour;
                              int minute;
                              showTimePicker(
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
                                initialEntryMode: TimePickerEntryMode.dial,
                                initialTime: TimeOfDay.now(),
                              ).then((value) => this.setState(() {
                                receivedDate = new DateTime(receivedDate.year,receivedDate.month,receivedDate.day,value.hour,value.minute);
                              }));},
                            icon: Icon(Icons.timer,color: receivedDate==null?Color(0xfffffff0):Colors.blue,),
                            label: Text('Received Time\n${receivedDate.hour} : ${receivedDate.minute}',
                              style:  receivedDate==null?TextStyle():TextStyle(color: Colors.blue),)
                        ),
                      ],
                    ),
                    showPage!='site'?SizedBox():Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width*0.4,
                          child: FlatButton.icon(onPressed: () =>this.setState(()async {
                            installationDate=await chooseDate(context);
                            this.setState(() {

                            });
                          }) ,
                              icon: Icon(Icons.calendar_today,color: installationDate==null?Color(0xfffffff0):Colors.blue,),
                              label: Text('Install Date\n ${installationDate.toString().split(' ')[0]}',
                                style:  installationDate==null?TextStyle():TextStyle(color: Colors.blue),)
                          ),
                        ),
                        FlatButton.icon(
                            onPressed: () {
                              int hour;
                              int minute;
                              showTimePicker(
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
                                initialEntryMode: TimePickerEntryMode.dial,
                                initialTime: TimeOfDay.now(),
                              ).then((value) => this.setState(() {
                                installationDate = new DateTime(installationDate.year,installationDate.month,installationDate.day,value.hour,value.minute);
                              }));},
                            icon: Icon(Icons.timer,color: installationDate==null?Color(0xfffffff0):Colors.blue,),
                            label: Text('Install Time\n${installationDate.hour} : ${installationDate.minute}',
                              style:  installationDate==null?TextStyle():TextStyle(color: Colors.blue),)
                        ),
                      ],
                    ),
                    TextField(
                      controller: customerID,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Customer ID',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    widget.docID.data['type']!='Maintain'?SizedBox():TextField(
                      controller: ttNO,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Ticket Number',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: customerName,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Customer Name',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: address,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Address',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: phone1,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Primary Phone',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: phone2,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Secondary Phone',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: bandwidth,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Bandwidth',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    TextField(
                      controller: remark,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        labelStyle: getTextStyle(context),
                        labelText: 'Remark',
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                    Divider(
                      color: Colors.lightBlueAccent,
                    ),
                    FlatButton(
                      child: Text(
                        'Save!',
                        style: TextStyle(
                            fontSize: 20/MediaQuery.textScaleFactorOf(context), color: Colors.lightGreen),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        Firestore.instance.collection('activities').add({
                          'what': '${widget.docID.data['customerID']} Edit',
                          'when': DateTime.now().toString(),
                          'who': prefs.get('currentUser'),
                        });
                        showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text('Wait'),
                              content: Text('Data are uploading'),
                            ));
                        widget.docID.reference
                            .updateData({
                          'receivedDate': receivedDate,
                          'installationDate': installationDate,
                          'customerID': customerID.text,
                          'customerName': customerName.text,
                          'address': address.text,
                          'phone1': phone1.text,
                          'phone2': phone2.text,
                          'bandwidth': bandwidth.text,
                          'remark': remark.text,
                        }).then((value) => showDialog(
                            context: context,
                            child: AlertDialog(
                              title: Text('Success'),
                              content:
                              Text('Data are successfully saved'),
                            )));
                        Navigator.of(context, rootNavigator: true).pop();
                       Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ));
                      },
                    ),
                  ],
                ),
              ),
            ), // Site Data
            showPage != 'route'
                ? SizedBox()
                : Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: startMeter,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                            labelStyle: getTextStyle(context),
                            labelText: 'Start Meter',
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: endMeter,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                            labelStyle: getTextStyle(context),
                            labelText: 'End Meter',
                            enabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Text(
                        'Total : ' +
                            (int.parse(endMeter.text) -
                                int.parse(startMeter.text))
                                .toString(),
                        style: getTextStyle(context),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton(
                        items: getZones(),
                        hint: Text(
                          'Choose Zone Here',
                          style: getTextStyle(context),
                        ),
                        value: dropZone,
                        onChanged: (value) {
                          this.setState(() {
                            dropZone = value;
                          });
                        },
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: subZone,
                          keyboardType: TextInputType.number,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Sub Zone',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                    ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child:    Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: TextField(
                            controller: dn,
                            keyboardType: TextInputType.number,
                            style:
                            TextStyle(color: Colors.blue),
                            decoration: InputDecoration(
                                labelStyle: getTextStyle(context),
                                labelText: 'DN',
                                enabledBorder: InputBorder.none,
                                helperStyle: getTextStyle(context)
                                    .apply(color: Colors.lightGreen)),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: sn,
                          keyboardType: TextInputType.number,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'SN',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: port,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Port',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  dnsnList.contains(dropZone + '-' + subZone.text+ '-' + dn.text + '-' + sn.text)
                      ? Text(dropZone + '-' + subZone.text + '-' + dn.text + '-' + sn.text + ' exists in the map data.', style: TextStyle(color: Colors.green,fontSize: 14/MediaQuery.textScaleFactorOf(context)),):
                  Text('No such dnsn in the map data.', style: TextStyle(color: Colors.red,fontSize: 14/MediaQuery.textScaleFactorOf(context))),
                  dnsnList.contains(dropZone + '-' + subZone.text+ '-' + dn.text + '-' + sn.text)
                      ?SizedBox()
                      : TextField(
                    controller: dnsnLatlng,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'DNSN Location',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  dnsnList.contains(dropZone + '-' + subZone.text+ '-' + dn.text + '-' + sn.text)
                      ? SizedBox(
                  )
                      : TextField(
                    controller: dnsnPorts,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Ports',
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Column(
                      children: [
                        Text('Pole Data'),
                        Row(
                          children: [
                            Flexible(
                              child: TextField(
                                controller: txtNewPoleLoc,
                              ),
                            ),
                            FlatButton.icon(
                              label: Text('Add A Pole'),
                              icon: Icon(Icons.add_location_rounded),
                              onPressed: () async {
                                GeoPoint poleGp =  new GeoPoint(
                                    double.parse(
                                        txtNewPoleLoc.text.split(',')[0]),
                                    double.parse(
                                        txtNewPoleLoc.text.split(',')[1]));
                                await widget.docID.reference.updateData({
                                  'poles':
                                  FieldValue.arrayUnion([poleGp])
                                });
                                await Firestore.instance
                                    .collection('Pole')
                                    .document(DateTime.now()
                                    .toString()
                                    .substring(0, 16))
                                    .setData({
                                  'latLong': new GeoPoint(
                                      double.parse(
                                          txtNewPoleLoc.text.split(',')[0]),
                                      double.parse(
                                          txtNewPoleLoc.text.split(',')[1]))
                                });
                                DocumentSnapshot qs = await Firestore.instance.collection('YTP_Sites').document(widget.docID.documentID).get();
                                Navigator.of(context,rootNavigator: true).pop();
                                Navigator.of(context,
                                    rootNavigator: true)
                                    .push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            YTP_IN_Edit(qs)));
                              },
                            ),
                          ],
                        ),
                        Divider(),
                        Text('Used Poles : '+poleData.length.toString()),
                        poleData.isEmpty?SizedBox():Center(
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.symmetric(
                                vertical: 20),
                            width: 240,
                            height: 240,
                            child: FlutterMap(
                              options: new MapOptions(
                                center: LatLng(poleData.first.latitude,poleData.first.longitude),
                                zoom: 16.0,
                                interactive: true,
                              ),
                              layers: [
                                new TileLayerOptions(
                                    backgroundColor:
                                    Colors.white,
                                    opacity: 0.5,
                                    maxNativeZoom: 40,
                                    urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                    subdomains: [
                                      'a',
                                      'b',
                                      'c'
                                    ]),
                                new MarkerLayerOptions(
                                    markers: poleMarkerList),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey)),
                  ),
                  Divider(
                    color: Colors.lightBlueAccent,
                  ),
                  FlatButton(
                    child: Text(
                      'Save!',
                      style: TextStyle(
                          fontSize: 20/MediaQuery.textScaleFactorOf(context), color: Colors.lightGreen),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();

                      Firestore.instance.collection('activities').add({
                        'what': '${widget.docID.data['customerID']} Edit',
                        'when': DateTime.now().toString(),
                        'who': prefs.get('currentUser'),
                      });
                      showDialog(
                          context: context,
                          child: AlertDialog(
                            title: Text('Wait'),
                            content: Text('Data are uploading'),
                          ));
                      dnsnList.contains(dropZone + '-' + subZone.text+ '-' + dn.text + '-' + sn.text)?null:
                      await Firestore.instance.collection('DNSN').document(dropZone + '-' + subZone.text+ '-' + dn.text + '-' + sn.text).setData(
                        {
                          'zone':dropZone,
                          'subZone':subZone.text,
                          'dn':dn.text,
                          'sn':sn.text,
                          'ports':dnsnPorts.text,
                        }
                      );
                      DocumentSnapshot ds = await Firestore.instance.collection('DNSN').document(dropZone + '-' + subZone.text + '-' + dn.text + '-' + sn.text).get();
                      ds.reference.setData(
                          {
                            'port' :{
                              port.text : customerID.text,
                            }
                          },merge: true
                      );
                      dnsnCr
                          .document(
                          dropZone + '-' + dn.text + '-' + sn.text)
                          .updateData(
                          {'portid.${port.text}': customerID.text});
                      widget.docID.reference.updateData({
                        'startMeter': startMeter.text,
                        'endMeter': endMeter.text,
                        'dnsn': dropZone + '-' + subZone.text + '-' + dn.text + '-' + sn.text,
                        'port': port.text,
                      }).then((value) => showDialog(
                          context: context,
                          child: AlertDialog(
                            title: Text('Success'),
                            content:
                            Text('Data are successfully saved'),
                          )).then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ));
                      }));
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ), //
            SizedBox(
              height: 20,
            ),
            showPage != 'local'
                ? SizedBox()
                : Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: customerType,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Customer Type',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: buildingType,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Building Type',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child:  TextField(
                          controller: new TextEditingController(text:
                          homeLocation.latitude.toString() +
                              "," +
                              homeLocation.longitude.toString(),),
                          style:                           TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Building Type',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                          onSubmitted: (value) {
                            this.setState(() {
                              String lat = value.split(',')[0];
                              String lng = value.split(',')[1];
                              homeLocation = GeoPoint(
                                  double.parse(lat), double.parse(lng));
                              mpl.move(
                                  LatLng(homeLocation.latitude,
                                      homeLocation.longitude),
                                  16);
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child:  IconButton(
                          icon: Icon(Icons.pin_drop),
                          onPressed: () {
                            chooseLocation(context)
                                .then((value) => this.setState(() {
                              homeLocation = GeoPoint(
                                  value.latitude, value.longitude);
                              mpl.move(
                                  LatLng(homeLocation.latitude,
                                      homeLocation.longitude),
                                  16);
                            }));
                            setState(() {});
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 240,
                      height: 240,
                      child: FlutterMap(
                        options: new MapOptions(
                          center: LatLng(homeLocation.latitude,
                              homeLocation.longitude),
                          zoom: 16.0,
                          interactive: true,
                        ),
                        mapController: mpl,
                        layers: [
                          new TileLayerOptions(
                              backgroundColor: Colors.blue,
                              opacity: 0.5,
                              maxNativeZoom: 40,
                              urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                              subdomains: ['a', 'b', 'c']),
                          new MarkerLayerOptions(markers: [
                            Marker(
                                point: LatLng(homeLocation.latitude,
                                    homeLocation.longitude),
                                height: 50,
                                width: 50,
                                builder: (ctx) => Container(
                                  child: Icon(Icons.home),
                                )),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    color: Colors.lightBlueAccent,
                  ),
                  FlatButton(
                    child: Text(
                      'Save!',
                      style: TextStyle(
                          fontSize: 20/MediaQuery.textScaleFactorOf(context), color: Colors.lightGreen),
                    ),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      Firestore.instance.collection('activities').add({
                        'what': '${widget.docID.data['customerID']} Edit',
                        'when': DateTime.now().toString(),
                        'who': prefs.get('currentUser'),
                      });
                      showDialog(
                          context: context,
                          child: AlertDialog(
                            title: Text('Wait'),
                            content: Text('Data are uploading'),
                          ));
                      widget.docID.reference.updateData({
                        'customerType': customerType.text,
                        'buildingType': buildingType.text,
                        'homeLocation': homeLocation,
                      }).then((value) => showDialog(
                          context: context,
                          child: AlertDialog(
                            title: Text('Success'),
                            content:
                            Text('Data are successfully saved'),
                          )).then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ));
                      }));
                    },
                  ),
                ],
              ),
            ), // Loc
            showPage != 'team'
                ? SizedBox()
                : Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          controller: fastConnector,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Fast Connectors',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: dropCable,
                          keyboardType: TextInputType.number,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Drop Cable',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Text(
                      usedDevicetoShow,
                      style: getTextStyle(context),
                    ),
                  ),
                  Center(
                    child: DropdownButton(
                      value: _onu,
                      items: ONUList,
                      hint: Text(
                        'Used ONU',
                        style: getTextStyle(context),
                      ),
                      onChanged: (value) {
                        this.setState(() {
                          _onu = value;
                          usedDevicetoShow = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: TextField(
                      controller: siteExpense,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          labelStyle: getTextStyle(context),
                          labelText: 'Site Expense',
                          enabledBorder: InputBorder.none,
                          helperStyle: getTextStyle(context)
                              .apply(color: Colors.lightGreen)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  widget.docID.data['type']!='Maintain'?SizedBox():Container(
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: TextField(
                      controller: engrCmt,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                          labelStyle: getTextStyle(context),
                          labelText: 'Engineer Comment',
                          enabledBorder: InputBorder.none,
                          helperStyle: getTextStyle(context)
                              .apply(color: Colors.lightGreen)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: username,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Username',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          controller: password,
                          style:
                          TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                              labelStyle: getTextStyle(context),
                              labelText: 'Password',
                              enabledBorder: InputBorder.none,
                              helperStyle: getTextStyle(context)
                                  .apply(color: Colors.lightGreen)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    color: Colors.lightBlueAccent,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(
                        child: Text(
                          'Save!',
                          style: TextStyle(
                              fontSize: 20/MediaQuery.textScaleFactorOf(context), color: Colors.lightGreen),
                        ),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                title: Text('Wait'),
                                content: Text('Data are uploading'),
                              ));
                          SharedPreferences prf =
                          await SharedPreferences.getInstance();
                          if(_onu!=null){
                            Firestore.instance
                                .collection('inventory_log')
                                .add({
                              'when': Timestamp.now(),
                              'who': prf.get('currentUser'),
                              'site_id': widget.docID.data['customerID'],
                              'usedDevice': _onu
                            });
                          }
                          QuerySnapshot qsqs = await Firestore.instance
                              .collection('device')
                              .where('deviceSerial', isEqualTo: _onu)
                              .getDocuments();
                          qsqs.documents.first.reference.updateData({
                            'condition': 'Site Use',
                            'usedBy': widget.docID.data['customerID']
                          });
                          QuerySnapshot fcqs = await Firestore.instance
                              .collection('accessories')
                              .where('accessories',
                              isEqualTo: widget
                                  .docID.data['Fast Connectors'])
                              .getDocuments();
                          fcqs.documents.first.reference.updateData({
                            'qty': fcqs.documents.first.data['qty'] -
                                int.parse(
                                  fastConnector.text,
                                ),
                          });
                          QuerySnapshot dcqs = await Firestore.instance
                              .collection('accessories')
                              .where('accessories',
                              isEqualTo:
                              widget.docID.data['Drop Cables'])
                              .getDocuments();
                          dcqs.documents.first.reference.updateData({
                            'qty': dcqs.documents.first.data['qty'] -
                                int.parse(
                                  dropCable.text,
                                ),
                          });
                          widget.docID.reference.updateData({
                            'fastConnectors': fastConnector.text,
                            'dropCable': dropCable.text,
                            'usedDevice': _onu ?? '',
                            'siteExpense': siteExpense.text,
                            'userName': username.text,
                            'password': password.text,
                            'engineerComment':engrCmt.text,
                          }).then((value) => showDialog(
                              context: context,
                              child: AlertDialog(
                                title: Text('Success'),
                                content: Text(
                                    'Data are successfully saved'),
                              )).then((value) {
                            Navigator.of(context,rootNavigator: true).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => MyApp(),
                                ));
                          }));
                        },
                      ), //
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'ပထမဆုံး အသုံးစာရင်းများထည့်လျှင် ',
                      style: TextStyle(color: Colors.redAccent),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'Save! ',
                            style: getTextStyle(context)
                                .apply(color: Colors.lightGreen)),
                        TextSpan(text: 'သာနှိပ်ပါ'),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'ထည့်ပြီးသားစာရင်းအား ပြင်ဆင်သည့်အခါမှသာ',
                      style: TextStyle(color: Colors.redAccent),
                      children: <TextSpan>[
                        TextSpan(
                            text: ' Update! ',
                            style: getTextStyle(context)
                                .apply(color: Colors.lightGreen)),
                        TextSpan(text: 'ကို နှိပ်ပေးပါ'),
                      ],
                    ),
                  ),
                ],
              ),
            ), // Team
          ],
        ),
      ),
    );
  }
}
