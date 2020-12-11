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
import 'globals.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:htd/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class YTP_Email extends StatelessWidget {
  final String emailText;
  const YTP_Email(this.emailText);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          primary: true,
          title: Text(
            'YTP Maintain Email',
            textAlign: TextAlign.center,
          ),centerTitle: true,
        ),
        body: YTP_EmailForm(emailText),
        resizeToAvoidBottomPadding: false,
      ),
    );
  }
}

class YTP_EmailForm extends StatefulWidget {

  final String emailText;
  const YTP_EmailForm(this.emailText);

  @override
  _YTP_EmailFormState createState() => _YTP_EmailFormState();
}

class _YTP_EmailFormState extends State<YTP_EmailForm> {

  String customerName,customerID,address,ttNo,phone='';
  DateTime receivedDate = DateTime.now();

  String subZone,dn,sn,port;
  String zone;
  TextEditingController txtZone = new TextEditingController();
  TextEditingController txtSubZone = new TextEditingController();
  TextEditingController txtDn = new TextEditingController();
  TextEditingController txtSn = new TextEditingController();
  TextEditingController txtPort = new TextEditingController();
  TextEditingController txtMail = new TextEditingController();

  void getData(){
    customerName = widget.emailText
        .substring(
        widget.emailText.lastIndexOf(
            'Customer Name'),
        widget.emailText.indexOf(
            'Symptom of Fault'))
        .split('\n\n')[1];
    address = widget.emailText
        .substring(
        widget.emailText.lastIndexOf(
            'Address'),
        widget.emailText.indexOf(
            'Phone Number'))
        .split('\n\n')[1];
    ttNo = widget.emailText
        .substring(
        widget.emailText.lastIndexOf(
            'Ticket No'),
        widget.emailText.indexOf(
            'Customer Name'))
        .split('\n\n')[1];
    phone = widget.emailText
        .substring(
        widget.emailText.lastIndexOf(
            'Phone Number'),
        widget.emailText.indexOf(
            'Engineer\'s Comment'))
        .split('\n\n')[1];
    customerID = widget.emailText
        .substring(widget.emailText
        .lastIndexOf(
        'Customer ID'))
        .split('\n\n')[1];
  }

  void initState() {
    getData();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return   Container(
      margin: EdgeInsets.all(20),
      child: SingleChildScrollView(
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
              SizedBox(height: 20,),
              TextField(
                controller:
                new TextEditingController(text: customerName),
                readOnly:
                true,
                decoration:
                InputDecoration(
                  labelText:
                  'Customer Name',
                  border:
                  InputBorder.none,
                ),
              ),
              TextField(
                controller:
                new TextEditingController(text: customerID),
                readOnly:
                true,
                decoration:
                InputDecoration(
                  labelText:
                  'Customer ID',
                  border:
                  InputBorder.none,
                ),
              ),
              TextField(
                controller:
                new TextEditingController(text: ttNo),
                readOnly:
                true,
                decoration:
                InputDecoration(
                  labelText:
                  'Ticket Number',
                  border:
                  InputBorder.none,
                ),
              ),
              TextField(
                controller:
                new TextEditingController(text: phone),
                readOnly:
                true,
                decoration:
                InputDecoration(
                  labelText:
                  'Customer Phone',
                  border:
                  InputBorder.none,
                ),
              ),
              TextField(
                controller:
                new TextEditingController(text: address),
                readOnly:
                true,
                maxLines:
                null,
                decoration:
                InputDecoration(
                  labelText:
                  'Customer Address',
                  border:
                  InputBorder.none,
                ),
              ),
              Divider(thickness: 2,color: Colors.blueGrey,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: DropdownButton(
                      value:
                      zone,

                      hint: Text(
                          'Choose Zone'),
                      items: getZones(),
                      onChanged:
                          (value) {
                        setState(() {
                          txtZone.text=value;
                          zone=value;
                        });
                      },
                    ),
                  ),
                  Flexible(
                    child:   TextField(
                      controller: txtSubZone,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(
                        labelText:
                        'Sub Zone',
                        border:
                        InputBorder.none,
                      ),
                    ),

                  )
                ],
              ),
              Row(
                children: [
                  Flexible(
                    child:   TextField(
                      controller: txtDn,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(
                        labelText:
                        'DN',
                        border:
                        InputBorder.none,
                      ),
                    ),

                  ),
                  Flexible(
                    child:   TextField(
                      controller: txtSn,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(
                        labelText:
                        'SN',
                        border:
                        InputBorder.none,
                      ),
                    ),
                  ),
                  Flexible(
                    child:   TextField(
                      controller: txtPort,
                      keyboardType: TextInputType.number,
                      decoration:
                      InputDecoration(
                        labelText:
                        'Port',
                        border:
                        InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(thickness: 2,color: Colors.blueGrey,),
              SizedBox(height: 20,),
              RaisedButton(
                child: Text('Submit'),
                onPressed: () async{
                  await Firestore.instance.collection('YTP_Sites').document(ttNo).setData(
                      {
                        'type': 'Maintain',
                        'ssr':false,
                        'receivedDate': receivedDate,
                        'installationDate': DateTime.now(),
                        'customerID': customerID,
                        'customerName': customerName,
                        'address': address,
                        'phone1': phone,
                        'ttNo': ttNo,
                        'phone2': '',
                        'remark': '',
                        'status':'Remaining',
                        'startMeter': "0",
                        'endMeter': "0",
                        'dnsn': zone+'-'+txtSubZone.text+'-'+txtDn.text+'-'+txtSn.text,
                        'port': txtPort.text,
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
                        'engineerComment':'',
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
                  );
                  Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) =>MyApp()));
                },
              )

            ]),
      ),
    );
  }
}
