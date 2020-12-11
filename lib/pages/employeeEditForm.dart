import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
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

class EmployeeEditForm extends StatefulWidget {
  final String docId;

  const EmployeeEditForm(this.docId);

  @override
  _EmployeeEditFormState createState() => _EmployeeEditFormState();
}

class _EmployeeEditFormState extends State<EmployeeEditForm> {

  String dob = 'Date of Birth';
  String doj = 'Date of Join';

  TextEditingController txtEmployeeName = new TextEditingController(text: '');
  TextEditingController txtPhone = new TextEditingController(text: '');
  TextEditingController txtDesignation = new TextEditingController(text: '');
  TextEditingController txtEmail = new TextEditingController(text: '');
  TextEditingController txtPassword = new TextEditingController(text: '');
  DateTime dateBirth,dateJoin;
  String Branch,paymentType;
  TextEditingController txtSalary = new TextEditingController(text: '');
  Map timeSlot = {};
  DocumentSnapshot myDs;

  Future<void> getData() async{
    myDs = await Firestore.instance.collection('employee').document(widget.docId).get();
    txtEmployeeName.text = myDs.data['Name'];
    txtPhone.text = myDs.data['Phone'];
    Branch = myDs.data['Branch'];
    txtEmail.text = myDs.data['Email'];
    txtPassword.text = myDs.data['Password'];
    paymentType = myDs.data['PaymentType'];
    txtSalary.text = myDs.data['Salary'];
    timeSlot = myDs.data['TimeSlot'];

    setState(() {

    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add Employee',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.check,color: Colors.white,),
            onPressed: () async{
              myDs.reference.updateData(
                {
                  'Name': txtEmployeeName.text,
                  'DateOfBirth': dateBirth,
                  'DateOfJoin': dateJoin,
                  'Designation':txtDesignation.text,
                  'Branch':Branch,
                  'Email':txtEmail.text,
                  'Password':txtPassword.text,
                  'PaymentType':paymentType,
                  'Salary':txtSalary.text
                }
              ).then((value) => Navigator.of(context,rootNavigator: true).pop());
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue)
              ),
              child: Column(
                children: [
                  Text('Employee Information',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w500),),
                  TextField(
                    controller: txtEmployeeName,
                    decoration: InputDecoration(
                        labelText: 'Employee Name'
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        child: RaisedButton(
                          child: Text(dob),
                          onPressed: () async{
                            showDatePicker(
                              context: context,
                              initialDate: DateTime(1997),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((value) {
                              setState(() {
                                dob = value.day.toString()+'-'+value.month.toString()+'-'+value.year.toString();
                                dateBirth = value;
                              });
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child: RaisedButton(
                          child: Text(doj),
                          onPressed: () async{
                            showDatePicker(
                              context: context,
                              initialDate: DateTime(2020),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ).then((value) {
                              setState(() {
                                doj = value.day.toString()+'-'+value.month.toString()+'-'+value.year.toString();
                                dateJoin = value;
                              });
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  TextField(
                    controller: txtPhone,
                    decoration: InputDecoration(
                        labelText: 'Phone',
                        prefixText: '+95'
                    ),
                  ),
                  TextField(
                    controller: txtDesignation,
                    decoration: InputDecoration(
                        labelText: 'Designation',
                      helperText: 'eg : Employee, Manager'
                    ),
                  ),
                  DropdownButton(
                    value: Branch,
                    items: [
                      DropdownMenuItem(value: 'Yangon',child: Text('Yangon'),),
                      DropdownMenuItem(value: 'Mogok',child: Text('Mogok'),),
                      DropdownMenuItem(value: 'Myitkyina',child: Text('Myitkyina'),),
                    ],
                    hint: Text('Select Branch'),
                    onChanged: (value) {
                      setState(() {
                        Branch=value;
                      });
                    },
                  ),
                ],),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue)
              ),
              child: Column(
                children: [
                  Text('Credentials',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w500)),
                  TextField(
                    controller: txtEmail,
                    decoration: InputDecoration(
                        labelText: 'Email'
                    ),
                  ),
                  TextField(
                    controller: txtPassword,
                    decoration: InputDecoration(
                        labelText: 'Password'
                    ),
                  ),

                ],),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue)
              ),
              child: Column(
                children: [
                  Text('Time Slots',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w500)),
                  Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(color: Colors.black,style: BorderStyle.solid),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent
                        ),
                          children: [
                            Container(padding: EdgeInsets.all(10),child: Center(child: Text('Day'))),
                            Center(child: Text('From')),
                            Center(child: Text('To')),
                            Center(child: Text('Full')),
                            Center(child: Text('Half')),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Mon')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Mon']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Mon':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Mon']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Mon':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Mon']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Mon':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Mon']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Mon']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Mon':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Tue')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Tue']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Tue':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Tue']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Tue':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Tue']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Tue':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Tue']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Tue']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Tue':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Wed')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Wed']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Wed':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Wed']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Wed':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Wed']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Wed':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Wed']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Wed']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Wed':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Thu')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Thu']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Thu':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Thu']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Thu':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Thu']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Thu':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Thu']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Thu']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Thu':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Fri')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Fri']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Fri':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Fri']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Fri':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Fri']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Fri':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Fri']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Fri']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Fri':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Sat')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sat']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sat':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sat']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sat':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sat']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sat':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sat']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sat']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sat':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                      TableRow(
                          children: [
                            Center(child: Text('Sun')),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']['from']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sun']['from']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sun':{
                                          'from':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']['to']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sun']['to']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sun':{
                                          'to':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']['full']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sun']['full']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sun':{
                                          'full':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                            FlatButton(
                              child:
                              timeSlot==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              timeSlot['Sun']['half']==null?Text('Set',style: TextStyle(color: Colors.red),):
                              Text(timeSlot['Sun']['half']),
                              onPressed: () async{
                                showTimePicker(
                                  initialTime: TimeOfDay.now(),
                                  context: context,
                                  useRootNavigator: true,
                                ).then((value) async{
                                  myDs.reference.setData(
                                    {
                                      'TimeSlot':{
                                        'Sun':{
                                          'half':value.hour.toString(),
                                        }
                                      }
                                    },merge: true,
                                  ).then((value) {
                                    Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => EmployeeEditForm(widget.docId),));
                                  });
                                });
                              },
                            ),
                          ]
                      ),
                    ],
                  ),
                ],),
            ),
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue)
              ),
              child: Column(
                children: [
                  Text('Payment Information',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w500)),
                  DropdownButton(
                    value: paymentType,
                    hint: Text('Payment Type'),
                    items: [
                      DropdownMenuItem(value: 'monthly',child: Text('Monthly'),),
                      DropdownMenuItem(value: 'daily',child: Text('Daily'),)
                    ],
                    onChanged: (value) {
                      setState(() {
                        paymentType = value;
                      });
                    },
                  ),
                  TextField(
                    controller: txtSalary,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Salary'
                    ),
                  ),
                ],),
            ),
          ],
        ),
      ),
    );
  }
}
