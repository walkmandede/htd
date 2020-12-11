import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/pages/ShweShan.dart';
import 'package:htd/pages/Tower.dart';
import 'package:htd/pages/room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:image_downloader/image_downloader.dart';
import 'package:htd/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class TowerList extends StatefulWidget {
  @override
  _TowerListState createState() => _TowerListState();
}

class _TowerListState extends State<TowerList> {
  String me;
  Future<void> getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    me = sp.getString('currentUser');
  }


  Map Cards = {
    'Demolish':{
      'desc':'-3hp,-3sh',
      'cost':{'brick':0,'bullet':0,'magic':3,},
      'effect':{'dmg':0,'hp':-3,'shield':-3,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },
    'Protection>Cure':{
      'desc':'Convert 5 HP to  10 Shield',
      'cost':{'brick':0,'bullet':0,'magic':5,},
      'effect':{'dmg':0,'hp':-5,'shield':10,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },
    'Anit Mage':{
      'desc':'Kill one mage',
      'cost':{'brick':0,'bullet':15,'magic':10,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':-1,},
    },
    'Assassinate':{
      'desc':'Kill one soldier',
      'cost':{'brick':0,'bullet':15,'magic':10,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':-1,'mages':0,},
    },
    'Snipe Him':{
      'desc':'Kill one worker',
      'cost':{'brick':0,'bullet':15,'magic':10,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':-1,'soldiers':0,'mages':0,},
    },
    'Army Camp':{
      'desc':'+1 soldier',
      'cost':{'brick':0,'bullet':0,'magic':20,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':1,'mages':0,},
    },
    'Carpenter':{
      'desc':'+1 Worker',
      'cost':{'brick':0,'bullet':0,'magic':20,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':1,'soldiers':0,'mages':0,},
    },
    'Magic Hall':{
      'desc':'+1 Mage',
      'cost':{'brick':10,'bullet':10,'magic':10,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':1,},
    },
    'Burn them all':{
      'desc':'-10 all resource',
      'cost':{'brick':0,'bullet':0,'magic':15,},
      'effect':{'dmg':0,'hp':0,'shield':0,'brick':-10,'bullet':-10,'magic':-10,'workers':0,'soldiers':0,'mages':0,},
    },


    'Destroy':{
      'desc':' 6 damage',
      'cost':{'brick':0,'bullet':3,'magic':0,},
      'effect':{'dmg':-6,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },
    'Nuke':{
      'desc':' 20 damage',
      'cost':{'brick':0,'bullet':8,'magic':0,},
      'effect':{'dmg':-20,'hp':0,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },
    'Catapult':{
      'desc':' -15 sh',
      'cost':{'brick':0,'bullet':6,'magic':0,},
      'effect':{'dmg':0,'hp':0,'shield':-15,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },


    'Build It':{
      'desc':' +10 hp',
      'cost':{'brick':5,'bullet':0,'magic':0,},
      'effect':{'dmg':0,'hp':10,'shield':0,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },
    'Cover me':{
      'desc':' +10 sh',
      'cost':{'brick':4,'bullet':0,'magic':0,},
      'effect':{'dmg':0,'hp':0,'shield':10,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },
    'Fortification':{
      'desc':' +15hp,+20sh',
      'cost':{'brick':12,'bullet':0,'magic':0,},
      'effect':{'dmg':0,'hp':15,'shield':20,'brick':0,'bullet':0,'magic':0,'workers':0,'soldiers':0,'mages':0,},
    },




  };
  
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text('New Game'),
        icon: Icon(Icons.add_box),
        onPressed: () async {
          SharedPreferences sp = await SharedPreferences.getInstance();
          String roomId = sp.getString('currentUser');
          showDialog(
              context: context, child: AlertDialog(title: Text(roomId)));
          DocumentReference dr =
          await Firestore.instance.collection('Tower').document(roomId);
          List<Map> cards = [];
          dr.setData({
            'state': 'Waiting',
            'host':sp.getString('currentUser'),
            'players': {
              sp.getString('currentUser'): {
                'hp':50,
                'shield':10,
                'brick':5,
                'bullet':5,
                'magic':5,
                'workers':1,
                'soldiers':1,
                'mages':1,
              }
            },
            'cards': Cards,
          });
          Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(builder: (context) => Tower(roomId)));
        },
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("Tower").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  final DocumentSnapshot room = snapshot.data.documents[index];
                  bool isInGame = false;
                  Map players = room.data['players'];

                  return Card(
                    margin: EdgeInsets.all(20),
                    borderOnForeground: false,
                    elevation: 10,
                    color: Colors.lightGreen.shade100,
                    semanticContainer: false,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.transparent),
                      width: double.maxFinite,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Host - ${room.documentID}'),
                              Text('Players - ${players.keys.length.toString()}'),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RaisedButton(
                                child: Text('Join'),
                                onPressed: () async {
                                  SharedPreferences sp =
                                      await SharedPreferences.getInstance();
                                  List<Map> cards = [];
                                  room.reference.setData(
                                    {
                                      'players': {
                                        sp.getString('currentUser'): {
                                          'hp':50,
                                          'shield':10,
                                          'brick':5,
                                          'bullet':5,
                                          'magic':5,
                                          'workers':1,
                                          'soldiers':1,
                                          'mages':1,
                                        }
                                      },
                                      'state':room.documentID
                                    },merge: true,
                                  );
                                  Navigator.of(context, rootNavigator: true)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) =>
                                              Tower(room.documentID)));
                                },
                              ),
                              room.data['host']!=me?SizedBox():RaisedButton(
                                child: Text('Delete'),
                                onPressed: () async {
                                  await room.reference.delete();
                                },
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
