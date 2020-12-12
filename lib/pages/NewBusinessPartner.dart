import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:htd/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmp;
import 'package:latlong/latlong.dart';
import 'package:htd/globals.dart' as globals;
import 'package:dotted_border/dotted_border.dart';
import 'dart:async';

class NewBusinessPartner extends StatefulWidget {
  @override
  _NewBusinessPartnerState createState() => _NewBusinessPartnerState();
}

class _NewBusinessPartnerState extends State<NewBusinessPartner> {
  //partner
  TextEditingController _name = new TextEditingController(text: '');
  TextEditingController _additionalName = new TextEditingController(text: '');
  TextEditingController _priceList = new TextEditingController(text: '');
  TextEditingController _paymentType = new TextEditingController(text: '');
  TextEditingController _shippingType = new TextEditingController(text: '');
  TextEditingController _groupName = new TextEditingController(text: '');
  TextEditingController _officePhone = new TextEditingController(text: '');
  TextEditingController _mobilePhone = new TextEditingController(text: '');
  TextEditingController _otherPhone = new TextEditingController(text: '');
  TextEditingController _fax = new TextEditingController(text: '');
  TextEditingController _email = new TextEditingController(text: '');
  TextEditingController _website = new TextEditingController(text: '');
  TextEditingController _notes = new TextEditingController(text: '');

  String _type;

  //contact
  Map _contactList = {};
  TextEditingController _titleContact = new TextEditingController(text: '');
  TextEditingController _firstNameContact = new TextEditingController(text: '');
  TextEditingController _lastNameContact = new TextEditingController(text: '');
  TextEditingController _positionContact = new TextEditingController(text: '');
  TextEditingController _professionContact = new TextEditingController(text: '');
  TextEditingController _officePhoneContact = new TextEditingController(text: '');
  TextEditingController _mobilePhoneContact = new TextEditingController(text: '');
  TextEditingController _otherPhoneContact = new TextEditingController(text: '');
  TextEditingController _faxContact = new TextEditingController(text: '');
  TextEditingController _pagerContact = new TextEditingController(text: '');
  TextEditingController _emailContact = new TextEditingController(text: '');
  TextEditingController _notesContact = new TextEditingController(text: '');

  bool _defaultContact = false;
  String _gender;
  DateTime _dob = DateTime.now();

  //address
  Map _addressList = {};
  String _addressType;
  bool _defaultAddress = false;

  TextEditingController _nameAddress = new TextEditingController(text: '');
  TextEditingController _name2Address = new TextEditingController(text: '');
  TextEditingController _name3Address = new TextEditingController(text: '');

  TextEditingController _streetAddress = new TextEditingController(text: '');
  TextEditingController _streetNo = new TextEditingController(text: '');
  TextEditingController _blockAddress = new TextEditingController(text: '');
  TextEditingController _buildingAddress = new TextEditingController(text: '');
  TextEditingController _floorAddress = new TextEditingController(text: '');
  TextEditingController _roomAddress = new TextEditingController(text: '');
  TextEditingController _zipAddress = new TextEditingController(text: '');

  TextEditingController _countryAddress = new TextEditingController(text: '');
  TextEditingController _cityAddress = new TextEditingController(text: '');


  bool _isForeign = false;

  String _townShipAddress;
  String _state;

  List<Widget> _addressWidgets = [
    Text('Address : ',style: TextStyle(fontWeight: FontWeight.w800),)
  ];
  List<Widget> _contacWidgets = [
    Text('Contact : ',style: TextStyle(fontWeight: FontWeight.w800),)
  ];

  void getData()
  {
    _addressList.forEach((key, value) {
      _addressWidgets.add(
        Text(key.toString())
      );
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
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(
        title: Text('New Business Partner Form'),
        backgroundColor: Colors.green,
        centerTitle: true,
        actions: [
          FlatButton(
            child: Text('Save',style: TextStyle(color: Colors.yellowAccent),),
            onPressed: () async{

              Firestore.instance.collection('BusinessPartners').add(
                {
                  'name':_name.text,
                  'additionalName':_additionalName.text,
                  'type':_type,
                  'priceList':_priceList.text,
                  'paymentType':_paymentType.text,
                  'shippingType':_shippingType.text,
                  'groupName':_groupName.text,
                  'officePhone':_officePhone.text,
                  'mobilePhone':_mobilePhone.text,
                  'otherPhone':_otherPhone.text,
                  'fax':_fax.text,
                  'email':_email.text,
                  'website':_website.text,
                  'notes':_notes.text,
                  'addresses':_addressList,
                  'contacts':_contactList,
                }
              );
              Navigator.of(context,rootNavigator: true).pop();
            },
          )
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30,),
              TextField(
                controller: _name,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                    labelText: 'Name'
                ),
              ),
              TextField(
                controller: _additionalName,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Additional Name',
                ),
              ),
              DropdownButton(
                isExpanded: true,
                items: [
                  DropdownMenuItem(value: 'Customer',child: Text('Customer'),),
                  DropdownMenuItem(value: 'Supplier',child: Text('Supplier'),),
                  DropdownMenuItem(value: 'Lead',child: Text('Lead'),),
                ],
                value: _type,
                style: TextStyle(color: Colors.blue),
                hint: Text('Type'),
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
              ),
              SizedBox(height: 50,),
              TextField(
                controller: _priceList,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Price List',
                ),
              ),
              TextField(
                controller: _paymentType,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Payment Type',
                ),
              ),
              TextField(
                controller: _shippingType,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Shipping Type',
                ),
              ),
              SizedBox(height: 50,),
              TextField(
                controller: _groupName,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Group Name',
                ),
              ),
              SizedBox(height: 50,),
              TextField(
                controller: _officePhone,
                style: TextStyle(color: Colors.blue),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Office Phone',
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _mobilePhone,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Mobile Phone',
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _otherPhone,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Other Phone',
                ),
              ),
              TextField(
                controller: _fax,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Fax',
                ),
              ),
              SizedBox(height: 50,),

              TextField(
                controller: _email,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: _website,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Website',
                ),
              ),
              SizedBox(height: 50,),
              TextField(
                controller: _notes,
                style: TextStyle(color: Colors.blue),
                decoration: InputDecoration(
                  labelText: 'Notes',
                ),
              ),
              SizedBox(height: 50,),
              Column(children: _addressWidgets,),
              SizedBox(height: 20,),
              Container(
                child: DottedBorder(
                  color: Colors.black,
                  strokeWidth: 1,
                  child: FlatButton.icon(
                    icon: Icon(Icons.add_business),
                    label: Text('Add Address'),
                    onPressed: () {
                      Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => AddressForm()));
                    },
                  ),
                ),
              ),
              SizedBox(height: 20,),

              Column(children: _contacWidgets,),
              SizedBox(height: 20,),
              DottedBorder(
                color: Colors.black,
                strokeWidth: 1,
                child:  FlatButton.icon(
                  icon: Icon(Icons.person_add),
                  label: Text('Add Contact'),
                  onPressed: () {
                    Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => ContactForm()));
                  },
                ),
              ),
              SizedBox(height: 50,),
            ],
          ),
        ),
      ),
    );
  }

  Widget ContactForm() {

    return StatefulBuilder(builder: (context, StateSetter setState)
    {
      return Scaffold(
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('New Contact Form'),
          centerTitle: true,
          actions: [
            FlatButton(
              child: Text('Save',style: TextStyle(color: Colors.yellow),),
              onPressed: () async{
                this.setState(() {
                  _contactList.addEntries(
                      [
                        MapEntry(_firstNameContact.text + ' '+_lastNameContact.text, {
                         'titleContact':_titleContact.text,
                         'firstNameContact':_firstNameContact.text,
                         'lastNameContact':_lastNameContact.text,
                         'positionContact':_positionContact.text,
                         'professionContact':_professionContact.text,
                         'officePhoneContact':_officePhoneContact.text,
                         'mobilePhoneContact':_mobilePhoneContact.text,
                         'otherPhoneContact':_otherPhoneContact.text,
                         'faxContact':_faxContact.text,
                         'pagerContact':_pagerContact.text,
                         'emailContact':_emailContact.text,
                         'notesContact':_notesContact.text,
                        'defaultConact': _defaultContact,
                        'gender':_gender,
                        'dob':_dob,
                        })
                      ]
                  );
                });
                this.setState(() {
                  String currentName =_firstNameContact.text + ' '+_lastNameContact.text;
                  _contacWidgets.add(
                      Text(currentName)
                  );
                });

                this.setState(() {
                  _titleContact = new TextEditingController(text: '');
                  _firstNameContact = new TextEditingController(text: '');
                  _lastNameContact = new TextEditingController(text: '');
                  _positionContact = new TextEditingController(text: '');
                  _professionContact = new TextEditingController(text: '');
                  _officePhoneContact = new TextEditingController(text: '');
                  _mobilePhoneContact = new TextEditingController(text: '');
                  _otherPhoneContact = new TextEditingController(text: '');
                  _faxContact = new TextEditingController(text: '');
                  _pagerContact = new TextEditingController(text: '');
                  _emailContact = new TextEditingController(text: '');
                  _notesContact = new TextEditingController(text: '');

                  _defaultContact = false;
                  _gender=null;
                  _dob = DateTime.now();
                });
                Navigator.of(context,rootNavigator: true).pop();
              },
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                ),
                TextField(
                  controller: _firstNameContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'First Name',
                  ),
                ),
                TextField(
                  controller: _lastNameContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                  ),
                ),
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Default Contact'),
                    Switch(
                      value: _defaultContact,
                      onChanged: (value){
                        setState(() {
                          _defaultContact = value;
                        });

                      },
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                DropdownButton(
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'Male',child: Text('Male'),),
                    DropdownMenuItem(value: 'Female',child: Text('Female'),),
                    DropdownMenuItem(value: 'Other',child: Text('Other'),),
                  ],
                  value: _gender,
                  style: TextStyle(color: Colors.blue),
                  hint: Text('Gender'),
                  onChanged: (value) {
                    setState(() {
                      _gender = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RaisedButton.icon(
                      icon: Icon(Icons.calendar_today),
                    onPressed: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      ).then((value){
                        setState(() {
                          _dob=value;
                        });
                      });
                    },
                      label: Text('Date of Birth'),
                    ),
                    Text(_dob.toString().substring(0,10)),
                  ],
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: _positionContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Position',
                  ),
                ),
                TextField(
                  controller: _professionContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Profession',
                  ),
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: _officePhoneContact,
                  style: TextStyle(color: Colors.blue),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Office Phone',
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _mobilePhoneContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Mobile Phone',
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _otherPhoneContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Other Phone',
                  ),
                ),
                TextField(
                  controller: _faxContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Fax',
                  ),
                ),
                TextField(
                  controller: _pagerContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Pager',
                  ),
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: _emailContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                TextField(
                  controller: _notesContact,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Note',
                  ),
                ),
                SizedBox(height: 50,),
              ],
            ),
          ),
        ),
      );
    }
    );
  }

  Widget AddressForm() {
    return StatefulBuilder(builder: (context, StateSetter setState)
    {
      return Scaffold(
        backgroundColor: Colors.green.shade100,
        appBar: AppBar(
          title: Text('New Address Form'),
          backgroundColor: Colors.green.shade100,
          centerTitle: true,
          actions: [
            FlatButton(
              child: Text('Save',style: TextStyle(color: Colors.yellow),),
              onPressed: () async{
                this.setState(() {
                  _addressList.addEntries(
                      [
                        MapEntry(_nameAddress.text, {
                          'addressType':_addressType,
                          'defaultAddress':_defaultAddress,

                          'nameAddress':_nameAddress.text,
                          'name2Address':_name2Address.text,
                          'name3Address':_name3Address.text,

                          'street':_streetAddress.text,
                          'streetNo':_streetNo.text,
                          'block':_blockAddress.text,
                          'building':_buildingAddress.text,
                          'floor':_floorAddress.text,
                          'room':_roomAddress.text,
                          'zip':_zipAddress.text,
                          'township':_townShipAddress,

                          'foreign':_isForeign,
                          'region':_state,
                          'country':_countryAddress.text,
                          'city':_cityAddress.text,

                        })
                      ]
                  );
                });
                this.setState(() {
                  String currentName = _nameAddress.text;
                  _addressWidgets.add(
                      Text(currentName)
                  );
                });

                this.setState(() {
                  _addressType = null;
                  _defaultAddress = false;

                  _nameAddress = new TextEditingController(text: '');
                  _name2Address = new TextEditingController(text: '');
                  _name3Address = new TextEditingController(text: '');

                  _streetAddress = new TextEditingController(text: '');
                  _streetNo = new TextEditingController(text: '');
                  _blockAddress = new TextEditingController(text: '');
                  _buildingAddress = new TextEditingController(text: '');
                  _floorAddress = new TextEditingController(text: '');
                  _roomAddress = new TextEditingController(text: '');
                  _zipAddress = new TextEditingController(text: '');

                  _countryAddress = new TextEditingController(text: '');
                  _cityAddress = new TextEditingController(text: '');


                  _isForeign = false;

                  _townShipAddress=null;
                  _state=null;
                });
                Navigator.of(context,rootNavigator: true).pop();
              },
            )
          ],
        ),
        body: Container(
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 50,),
                DropdownButton(
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'Ship To Address',child: Text('Ship To Address'),),
                    DropdownMenuItem(value: 'Bill To Address',child: Text('Bill To Address'),),
                    DropdownMenuItem(value: 'Work',child: Text('Work'),),
                    DropdownMenuItem(value: 'Home',child: Text('Home'),),
                  ],
                  value: _addressType,
                  style: TextStyle(color: Colors.blue),
                  hint: Text('Address Type'),
                  onChanged: (value) {
                    setState(() {
                      _addressType = value;
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Default Address'),
                    Switch(
                      value: _defaultAddress,
                      onChanged: (value) {
                        setState(() {
                          _defaultAddress = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: _nameAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                TextField(
                  controller: _name2Address,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Name 2',
                  ),
                ),
                TextField(
                  controller: _name3Address,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Name 3',
                  ),
                ),
                SizedBox(height: 50,),
                TextField(
                  controller: _streetAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Street',
                  ),
                ),
                TextField(
                  controller: _streetNo,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Street No',
                  ),
                ),
                TextField(
                  controller: _blockAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Block',
                  ),
                ),
                TextField(
                  controller: _buildingAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Building',
                  ),
                ),
                TextField(
                  controller: _floorAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Floor',
                  ),
                ),
                TextField(
                  controller: _roomAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Room',
                  ),
                ),
                TextField(
                  controller: _zipAddress,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Zip',
                  ),
                ),
                DropdownButton(
                  isExpanded: true,
                  items: globals.getZones(),
                  value: _townShipAddress,
                  style: TextStyle(color: Colors.blue),
                  hint: Text('Township'),
                  onChanged: (value) {
                    setState(() {
                      _townShipAddress = value;
                    });
                  },
                ),
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Foreign Contact'),
                    Switch(
                      value: _isForeign,
                      onChanged: (value) {
                        setState(() {
                          _isForeign = value;
                        });
                      },
                    ),
                  ],
                ),
                _isForeign? TextField(
                  controller: _countryAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'Country',
                  ),
                ):SizedBox(),
                _isForeign?
                TextField(
                  controller: _cityAddress,
                  style: TextStyle(color: Colors.blue),
                  decoration: InputDecoration(
                    labelText: 'City',
                  ),
                )
                    :
                DropdownButton(
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(value: 'Ayeyarwady Region',child: Text('Ayeyarwady Region'),),
                    DropdownMenuItem(value: 'Bago Region',child: Text('Bago Region'),),
                    DropdownMenuItem(value: 'Chin State',child: Text('Chin State'),),
                    DropdownMenuItem(value: 'Kachin State',child: Text('Kachin State'),),
                    DropdownMenuItem(value: 'Kayah State',child: Text('Kayah State'),),
                    DropdownMenuItem(value: 'Kayin State',child: Text('Kayin State'),),
                    DropdownMenuItem(value: 'Magway Region',child: Text('Magway Region'),),
                    DropdownMenuItem(value: 'Mandalay Region',child: Text('Mandalay Region'),),
                    DropdownMenuItem(value: 'Mon State',child: Text('Mon State'),),
                    DropdownMenuItem(value: 'Rakhine State',child: Text('Rakhine State'),),
                    DropdownMenuItem(value: 'Shan State',child: Text('Shan State'),),
                    DropdownMenuItem(value: 'Sagaing Region',child: Text('Sagaing Region'),),
                    DropdownMenuItem(value: 'Tanintharyi Region',child: Text('Tanintharyi Region'),),
                    DropdownMenuItem(value: 'Yangon Region',child: Text('Yangon Region'),),
                    DropdownMenuItem(value: 'Naypyidaw Union Territory',child: Text('Naypyidaw Union Territory'),),
                  ],
                  value: _state,
                  style: TextStyle(color: Colors.blue),
                  hint: Text('Region/State'),
                  onChanged: (value) {
                    setState(() {
                      _state = value;
                    });
                  },
                ),
                SizedBox(height: 50,),

              ],
            ),
          ),
        ),
      );
    }
    );
  }
}