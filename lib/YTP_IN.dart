import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/pages/Operation.dart';
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

class YTP_In extends StatelessWidget {
  final String siteType;
  const YTP_In(this.siteType);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          primary: true,
          title: Text(
            'YTP Site',
            style:
            GoogleFonts.carterOne(color: Colors.red, fontSize: 25),
            textAlign: TextAlign.center,
          ),centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: bgColor()),
          ),
        ),
        body: YTP_InForm(siteType),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }
}

class YTP_InForm extends StatefulWidget {
  final String siteType;
  const YTP_InForm(this.siteType);

  @override
  _YTP_InFormState createState() => _YTP_InFormState();
}

class _YTP_InFormState extends State<YTP_InForm> {
  File dnsnImg;
  File lossesImg;
  File portImg;
  File powerMeterImg;
  File deviceFrontImg;
  File deviceBackImg;
  File ssrImg;
  File feedbackImg;
  File speedTest;

  DateTime receivedDate;
  DateTime installationDate;

  TextEditingController customerName =  TextEditingController();
  TextEditingController customerID =  TextEditingController();
  TextEditingController ttNo =  TextEditingController();
  TextEditingController remark =  TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController phone1 = TextEditingController();
  TextEditingController bandwidth = TextEditingController();
  TextEditingController phone2 = TextEditingController();
  TextEditingController startMeter = TextEditingController();
  TextEditingController endMeter = TextEditingController();
  TextEditingController portNo = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController fastConnector = TextEditingController();
  TextEditingController dropCable = TextEditingController();
  TextEditingController siteExpense = TextEditingController();

  TextEditingController addName1 = TextEditingController();
  TextEditingController addName2 = TextEditingController();
  TextEditingController addName3 = TextEditingController();
  TextEditingController addStreet = TextEditingController();
  TextEditingController addStreetNo = TextEditingController();
  TextEditingController addBlock = TextEditingController();
  TextEditingController addBuliding = TextEditingController();
  TextEditingController addFloor = TextEditingController();
  TextEditingController addRoom = TextEditingController();
  TextEditingController addZip = TextEditingController();
  TextEditingController addCity = TextEditingController();
  TextEditingController addTownship = TextEditingController();
  TextEditingController addState = TextEditingController();
  TextEditingController addCountry = TextEditingController();

  String showPage;
  String addType;
  bool defaultAdd;


  void initState() {
    showPage='site';
    defaultAdd= false;
    setData();
    super.initState();
  }

  bool checkData(){
    if(
    customerID.text==""||
        customerName.text==""||
        address.text==""||
        phone1.text==""||
        bandwidth.text==""||
        remark.text==""
    )
    {
      return false;
    }
    else return true;
  }

  void setData() async{
    customerName.text=  "";
    customerID.text=  "";
    remark .text=  "";
    bandwidth.text="";
    address.text="";
    phone1.text = "";
    ttNo.text='';
    phone2.text = "";
    startMeter.text = "";
    endMeter.text = "";
    portNo.text = "";
    username.text = "";
    password.text = "";
    fastConnector.text = "";
    dropCable.text = "";
    siteExpense.text = "";

    addName1.text = "";
    addName2.text = "";
    addName3.text = "";
    addStreet.text = "";
    addStreetNo.text = "";
    addBlock.text = "";
    addBuliding.text = "";
    addFloor.text = "";
    addRoom.text = "";
    addZip.text = "";
    addCity.text = "";
    addTownship.text = "";
    addState.text = "";
    addCountry.text = "";
    installationDate = DateTime.now();
    receivedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: bgColor()),
      child: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20),
          children: [
            SizedBox(
              height: 20,
            ),
            Divider(color: Colors.lightBlueAccent,),
            showPage!='site'?SizedBox():Row(
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

            showPage!='site'?SizedBox():TextField(
              controller: customerID,
              keyboardType: TextInputType.number,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Customer ID',
                enabledBorder: InputBorder.none,
              ),
            ),
            widget.siteType!='Maintain'?SizedBox():TextField(
              controller: ttNo,
              keyboardType: TextInputType.number,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'TT No',
                enabledBorder: InputBorder.none,
              ),
            ),
            showPage!='site'?SizedBox():TextField(
              controller: customerName,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Customer Name',
                enabledBorder: InputBorder.none,
              ),
            ),
            showPage!='site'?SizedBox():TextField(
              controller: phone1,
              keyboardType: TextInputType.number,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Primary Phone',
                enabledBorder: InputBorder.none,
              ),
            ),
            showPage!='site'?SizedBox():TextField(
              controller: phone2,
              keyboardType: TextInputType.number,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Secondary Phone',
                enabledBorder: InputBorder.none,
              ),
            ),
            showPage!='site'?SizedBox():TextField(
              controller: address,
              maxLines: null,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Address',
                enabledBorder: InputBorder.none,
              ),
            ),
            showPage!='site'?SizedBox():TextField(
              controller: bandwidth,
              keyboardType: TextInputType.number,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Bandwidth',
                enabledBorder: InputBorder.none,
              ),
            ),
            showPage!='site'?SizedBox():TextField(
              controller: remark,
              style: GoogleFonts.carterOne(color: Colors.blue),
              decoration: InputDecoration(
                labelStyle: TextStyle(),
                labelText: 'Remark',
                enabledBorder: InputBorder.none,
              ),
            ),
            SizedBox(height: 20,),
            Divider(color: Colors.lightBlueAccent,),
            FlatButton(
              child: Text('Save!',style: GoogleFonts.carterOne(fontSize: 20,color: Colors.lightGreen),),
              onPressed: () async{
                if(checkData()) {
                  showDialog(context: context,
                      child: AlertDialog(title: Text('Wait'),
                        content: Text('Data are uploading'),));
                  final prefs = await SharedPreferences.getInstance();
                  Firestore.instance.collection('YTP_Sites').document(
                      widget.siteType=='Maintain'?ttNo.text:customerID.text).setData(
                      {
                        'type': widget.siteType,
                        'ttNo':ttNo.text,
                        'engineerComment':'',
                        'receivedDate': receivedDate,
                        'installationDate': installationDate,
                        'customerID': customerID.text,
                        'customerName': customerName.text,
                        'address': address.text,
                        'phone1': phone1.text,
                        'bandwidth': bandwidth.text,
                        'phone2': phone2.text,
                        'remark': remark.text,
                        'status':'Remaining',
                        'startMeter': "0",
                        'endMeter': "0",
                        'dnsn': "",
                        'port': "",
                        'ssr':false,
                        'poles': [],
                        'customerType': "",
                        'buildingType': "",
                        'homeLocation': GeoPoint(0,0),
                        'usedDevice': "",
                        'userName': "",
                        'password': "",
                        'fastConnectors': "",
                        'dropCable': "",
                        'siteExpense': "",
                        'dnsnPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'lossesPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'portPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'powerMeterPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'frontPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'backPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'ssrPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'feedbackPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                        'speedTestPhoto': "https://teplodom.com.ua/uploads/shop/nophoto/nophoto.jpg",
                      }
                  ).then((value) =>
                      showDialog(
                          context: context, child: AlertDialog(title: Text(
                          'Success'), content: Text(
                          'Data are successfully saved'),)).then((value) {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyApp(),
                            ));
                      }));
                }
                else{
                  showDialog(
                      context: context, child: AlertDialog(title: Text(
                      'Some Data Are Missing'), content: Text(
                      'Please, check and fill all the fields!'),));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
