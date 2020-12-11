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

class RoomList extends StatefulWidget {
  @override
  _RoomListState createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  String me;
  Future<void> getData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    me = sp.getString('currentUser');
  }

  Future<Album> fetchAlbum() async {
    final response = await http
        .get('https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Album.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getData();
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(
            child: Text('New Room'),
            onPressed: () async {
              Album futureAlbum;
              SharedPreferences sp = await SharedPreferences.getInstance();
              final response = await http.get(
                  'https://deckofcardsapi.com/api/deck/new/shuffle/?deck_count=1');
              futureAlbum = Album.fromJson(jsonDecode(response.body));
              String roomId = futureAlbum.deck_id;
              showDialog(
                  context: context, child: AlertDialog(title: Text(roomId)));
              DocumentReference dr =
                  await Firestore.instance.collection('Room').document(roomId);
              List<Map> cards = [];
              dr.setData({
                'state': 'Waiting',
                'host':sp.getString('currentUser'),
                'players': {
                  sp.getString('currentUser'): {
                    'cards': '',
                  }
                }
              });
              Navigator.of(context, rootNavigator: true).pushReplacement(
                  MaterialPageRoute(builder: (context) => Room(roomId)));
            },
          )
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance.collection("Room").snapshots(),
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
                    borderOnForeground: false,
                    elevation: 10,
                    color: Colors.transparent,
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
                              Text('Room# - ${room.documentID.substring(6)}'),
                              Text('Players - ${players.keys.length.toString()}'),
                            ],
                          ),
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
                                      'cards': '',
                                    }
                                  },
                                },merge: true,
                              );
                              Navigator.of(context, rootNavigator: true)
                                  .pushReplacement(MaterialPageRoute(
                                      builder: (context) =>
                                          Room(room.documentID)));
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
                    ),
                  );
                });
          }),
    );
  }
}

class Album {
  final String deck_id;

  Album({
    this.deck_id,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      deck_id: json['deck_id'],
    );
  }
}
