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
import 'package:htd/pages/cardChecking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:htd/main.dart';
import 'dart:math';
import 'package:image_downloader/image_downloader.dart';
import 'package:htd/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:async';

class ShweShan extends StatefulWidget {
  final String docID;

  const ShweShan(this.docID);

  @override
  _ShweShanState createState() => _ShweShanState();
}

class _ShweShanState extends State<ShweShan> with TickerProviderStateMixin{

  String txt = 'Exit';
  String host = '';
  String me = '';
  Map<String, bool> isShowed = {};
  Map<String, bool> wannaDraw = {};
  bool isDrag = false;
  bool showTime = false;
  DocumentSnapshot ds;
  bool dd = false;
  List swapCards=[];
  int i1,i2;

  List cards = [
    'AS',
    '2S',
    '3S',
    '4S',
    '5S',
    '6S',
    '7S',
    '8S',
    '9S',
    '0S',
    'JS',
    'QS',
    'KS',
    'AH',
    '2H',
    '3H',
    '4H',
    '5H',
    '6H',
    '7H',
    '8H',
    '9H',
    '0H',
    'JH',
    'QH',
    'KH',
    'AD',
    '2D',
    '3D',
    '4D',
    '5D',
    '6D',
    '7D',
    '8D',
    '9D',
    '0D',
    'JD',
    'QD',
    'KD',
    'AC',
    '2C',
    '3C',
    '4C',
    '5C',
    '6C',
    '7C',
    '8C',
    '9C',
    '0C',
    'JC',
    'QC',
    'KC',
  ];

  List<Widget> playerPic = [];
  AnimationController controller;

  String get timerString {
    Duration duration = controller.duration * controller.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  startTimeout([int milliseconds]) {
    var duration = Duration(milliseconds: milliseconds);
    return new Timer(duration, handleTimeout);
  }



  void handleTimeout() async{
    showAlertDialog(context, 'Time\'s up', Text('Press OK to continue!'), [FlatButton(child: Text('OK'),onPressed: () => Navigator.of(context,rootNavigator: true).pop(),)]);
    DocumentSnapshot room = await Firestore.instance
        .collection("ShweShan")
        .document(widget.docID.toString())
        .get();
    Map players = room.data['players'];
    players.forEach((key, value) {
      room.reference.setData(
        {
          'players':{
            key:{
              'show':true
            }
          }
        },merge: true
      );
    });

  }

  Future<void> getData() async {

    ds = await Firestore.instance
        .collection('ShweShan')
        .document(widget.docID)
        .get();
    QuerySnapshot pds =
        await Firestore.instance.collection('employee').getDocuments();
    Map players = ds.data['players'];
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      host = ds.data['host'];
      me = sp.getString('currentUser');
    });
    players.keys.forEach((element) {
      isShowed.addEntries([MapEntry(element, false)]);
      wannaDraw.addEntries([MapEntry(element, false)]);
      pds.documents.forEach((tt) {
        if (tt.documentID == element) {
          if (tt.documentID == host) {
            playerPic.add(new Stack(
              children: [
                CircleAvatar(
                  backgroundImage:
                      CachedNetworkImageProvider(tt.data['Picture']),
                  radius: 25,
                ),
                Icon(
                  Icons.home,
                  color: Colors.greenAccent,
                )
              ],
            ));
          } else {
            playerPic.add(new CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(tt.data['Picture']),
            ));
          }
        }
      });
    });
  }

  @override
  void initState() {

    getData();
    super.initState();
  }

  Timer timeLeft;
  String _selection;

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        floatingActionButton:
        PopupMenuButton(
          onSelected: ( result) async{
            switch(result)
            {
              case 1:                       Navigator.of(context, rootNavigator: true).pop();
              break;
              case 2:                       SharedPreferences sp =
                  await SharedPreferences.getInstance();
              DocumentSnapshot room = await Firestore.instance
                  .collection("ShweShan")
                  .document(widget.docID.toString())
                  .get();
              Map players = room.data['players'];
              Map _newPlayers = {};

              players.keys.forEach((element) {
                if (element != sp.getString('currentUser')) {
                  _newPlayers.addEntries(
                      [MapEntry(element, players[element])]);
                }
              });
              room.reference.updateData({'players': _newPlayers});
              Navigator.of(context, rootNavigator: true).pop();
              break;
              case 3:                       timeLeft=startTimeout(30000);
              SharedPreferences sp =
              await SharedPreferences.getInstance();
              DocumentSnapshot room = await Firestore.instance
                  .collection("ShweShan")
                  .document(widget.docID.toString())
                  .get();
              Map players = room.data['players'];
              setState(() {
                cards = [
                  'AS',
                  '2S',
                  '3S',
                  '4S',
                  '5S',
                  '6S',
                  '7S',
                  '8S',
                  '9S',
                  '0S',
                  'JS',
                  'QS',
                  'KS',
                  'AH',
                  '2H',
                  '3H',
                  '4H',
                  '5H',
                  '6H',
                  '7H',
                  '8H',
                  '9H',
                  '0H',
                  'JH',
                  'QH',
                  'KH',
                  'AD',
                  '2D',
                  '3D',
                  '4D',
                  '5D',
                  '6D',
                  '7D',
                  '8D',
                  '9D',
                  '0D',
                  'JD',
                  'QD',
                  'KD',
                  'AC',
                  '2C',
                  '3C',
                  '4C',
                  '5C',
                  '6C',
                  '7C',
                  '8C',
                  '9C',
                  '0C',
                  'JC',
                  'QC',
                  'KC',
                ];
              });
              players.keys.forEach((element) {
                String c1, c2, c3, c4, c5, c6, c7, c8;
                var rng = new Random();
                int c1i, c2i, c3i, c4i, c5i, c6i, c7i, c8i;
                c1i = rng.nextInt(cards.length);
                c1 = cards[c1i];
                cards.removeAt(c1i);
                c2i = rng.nextInt(cards.length);
                c2 = cards[c2i];
                cards.removeAt(c2i);
                c3i = rng.nextInt(cards.length);
                c3 = cards[c3i];
                cards.removeAt(c3i);
                c4i = rng.nextInt(cards.length);
                c4 = cards[c4i];
                cards.removeAt(c4i);
                c5i = rng.nextInt(cards.length);
                c5 = cards[c5i];
                cards.removeAt(c5i);
                c6i = rng.nextInt(cards.length);
                c6 = cards[c6i];
                cards.removeAt(c6i);
                c7i = rng.nextInt(cards.length);
                c7 = cards[c7i];
                cards.removeAt(c7i);
                c8i = rng.nextInt(cards.length);
                c8 = cards[c8i];
                cards.removeAt(c8i);
                setState(() {});
                room.reference.setData({
                  'players': {
                    element: {
                      'cards': c1 +
                          '-' +
                          c2 +
                          '-' +
                          c3 +
                          '-' +
                          c4 +
                          '-' +
                          c5 +
                          '-' +
                          c6 +
                          '-' +
                          c7 +
                          '-' +
                          c8,
                      'show': false,
                      'draw': false
                    }
                  }
                }, merge: true).then((value) async {
                  DocumentSnapshot tt = await Firestore.instance
                      .collection('ShweShan')
                      .document(widget.docID)
                      .get();
                  setState(() {
                    showTime = true;
                    ds = tt;
                  });
                });
              });
              break;
            }
            },
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            const PopupMenuItem(
              child: Text('Back'),
              value: 1,
            ),
            const PopupMenuItem(
              child: Text('Exit'),
              value: 2,
            ),
            const PopupMenuItem(
              child: Text('ဖဲဝေ'),
              value: 3,
            ),
          ],
        ),
        body: Column(
          children: [

            SizedBox(
              height: 10,
            ),
            Flexible(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("ShweShan")
                    .document(widget.docID.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  final DocumentSnapshot room = snapshot.data;
                  Map players = room.data['players'];
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

                  List<Widget> playerDesk = [];
                  players.keys.forEach((element) {
                    List myCards;
                    Map playerInfo = players[element];
                    String _name = element.toString();
                    String _c1 = 'No Card';
                    String _c2 = 'No Card';
                    String _c3 = 'No Card';
                    String _c4 = 'No Card';
                    String _c5 = 'No Card';
                    String _c6 = 'No Card';
                    String _c7 = 'No Card';
                    String _c8 = 'No Card';
                    if (playerInfo['cards'].toString() != '') {
                      _c1 = playerInfo['cards'].toString().split('-')[0];
                      _c2 = playerInfo['cards'].toString().split('-')[1];
                      _c3 = playerInfo['cards'].toString().split('-')[2];
                      _c4 = playerInfo['cards'].toString().split('-')[3];
                      _c5 = playerInfo['cards'].toString().split('-')[4];
                      _c6 = playerInfo['cards'].toString().split('-')[5];
                      _c7 = playerInfo['cards'].toString().split('-')[6];
                      _c8 = playerInfo['cards'].toString().split('-')[7];
                    }

                    myCards = [_c1, _c2, _c3, _c4, _c5, _c6, _c7, _c8,];

                    playerDesk.add(new Flexible(
                      child: Container(
                        child: playerInfo['show']
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Text(
                                          _name.split('@')[0],
                                          style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        padding: EdgeInsets.all(5),
                                        decoration: element == me
                                            ? BoxDecoration(
                                                color: Colors.lightGreenAccent,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    color: element == host
                                                        ? Colors.red
                                                        : Colors.black,
                                                    width: 2))
                                            : BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    color: element == host
                                                        ? Colors.red
                                                        : Colors.black,
                                                    width: 2)),
                                      ),
                                      Container(
                                        child: Text(
                                          element==host?'H O S T':'',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        padding: EdgeInsets.all(5),
                                      ),
                                    ],
                                  ),
                                  Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          gradient: LinearGradient(colors: [
                                            Colors.black,
                                            Colors.blueGrey,
                                          ])),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',
                                                  )),
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                          'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c3.toString()}.png',
                                                  )),
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                          'https://deckofcardsapi.com/static/img/${_c4.toString()}.png')),
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c5.toString()}.png',
                                                  )),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                          'https://deckofcardsapi.com/static/img/${_c6.toString()}.png')),
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                      'https://deckofcardsapi.com/static/img/${_c7.toString()}.png')),
                                              Container(
                                                  height: 70,
                                                  margin: EdgeInsets.symmetric(
                                                      horizontal: 5),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.black)),
                                                  child: CachedNetworkImage(
                                                      imageUrl:
                                                      'https://deckofcardsapi.com/static/img/${_c8.toString()}.png')),
                                            ],
                                          ),
                                        ],
                                      )),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Text(
                                          _name.split('@')[0],
                                          style: TextStyle(
                                              color: Colors.blueGrey,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        padding: EdgeInsets.all(5),
                                        decoration: element == me
                                            ? BoxDecoration(
                                                color: Colors.lightGreenAccent,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    color: element == host
                                                        ? Colors.red
                                                        : Colors.black,
                                                    width: 2))
                                            : BoxDecoration(
                                                color: Colors.yellow,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10)),
                                                border: Border.all(
                                                    color: element == host
                                                        ? Colors.red
                                                        : Colors.black,
                                                    width: 2)),
                                      ),
                                      Container(
                                        child: Text(
                                          element==host?'H O S T':'',

                                          style: TextStyle(
                                              color: Colors.redAccent,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        padding: EdgeInsets.all(5),
                                      ),
                                    ],
                                  ),
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(5),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            gradient: LinearGradient(colors: [
                                              Colors.black,
                                              Colors.blueGrey,
                                            ])),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        : GestureDetector(
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',
                                                            ),
                                                            onTap: () async {
                                                              if(swapCards.length==0)
                                                                {
                                                                  setState(() {
                                                                    swapCards.add(_c1);
                                                                    i1 = 0;
                                                                  });
                                                                }
                                                              else if(swapCards.length==1)
                                                                {
                                                                  setState(() {
                                                                    swapCards.add(_c1);
                                                                    i2 = 0;
                                                                  });
                                                                  setState(() {
                                                                    myCards[i1] = swapCards[1];
                                                                    myCards[i2] = swapCards[0];
                                                                  });
                                                                  await room.reference.setData(
                                                                      {
                                                                        'players': {
                                                                          element : {
                                                                            'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                            'draw': false,
                                                                            'show':false,
                                                                          }
                                                                        }
                                                                      },merge: true,
                                                                  );
                                                                  setState(() {
                                                                    myCards.clear();
                                                                    swapCards.clear();
                                                                    i1=i2=null;
                                                                  });
                                                                }
                                                            },
                                                          )
                                                ),
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        :  GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c2.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c2);
                                                            i1 = 1;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c2);
                                                            i2 = 1;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                            {
                                                              'players': {
                                                                element : {
                                                                  'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                  'draw': false,
                                                                  'show':false,
                                                                }
                                                              }
                                                            },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        :  GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c3.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c3);
                                                            i1 = 2;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c3);
                                                            i2 = 2;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                              {
                                                                'players': {
                                                                  element : {
                                                                    'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                    'draw': false,
                                                                    'show':false,
                                                                  }
                                                                }
                                                              },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )
                                                ),
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        :  GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c4.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c4);
                                                            i1 = 3;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c4);
                                                            i2 = 3;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                              {
                                                                'players': {
                                                                  element : {
                                                                    'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                    'draw': false,
                                                                    'show':false,
                                                                  }
                                                                }
                                                              },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )
                                                ),
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        :  GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c5.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c5);
                                                            i1 = 4;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c5);
                                                            i2 = 4;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                              {
                                                                'players': {
                                                                  element : {
                                                                    'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                    'draw': false,
                                                                    'show':false,
                                                                  }
                                                                }
                                                              },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        : GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c6.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c6);
                                                            i1 = 5;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c6);
                                                            i2 = 5;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                              {
                                                                'players': {
                                                                  element : {
                                                                    'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                    'draw': false,
                                                                    'show':false,
                                                                  }
                                                                }
                                                              },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )),
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        :  GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c7.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c7);
                                                            i1 = 6;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c7);
                                                            i2 = 6;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                              {
                                                                'players': {
                                                                  element : {
                                                                    'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                    'draw': false,
                                                                    'show':false,
                                                                  }
                                                                }
                                                              },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )),
                                                Container(
                                                    height: 70,
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Colors.black)),
                                                    child: playerInfo['cards']
                                                                    .toString() ==
                                                                '' ||
                                                            element != me
                                                        ? CachedNetworkImage(
                                                            imageUrl:
                                                                'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',
                                                          )
                                                        :  GestureDetector(
                                                      child:
                                                      CachedNetworkImage(
                                                        imageUrl:
                                                        'https://deckofcardsapi.com/static/img/${_c8.toString()}.png',
                                                      ),
                                                      onTap: () async {
                                                        if(swapCards.length==0)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c8);
                                                            i1 = 7;
                                                          });
                                                        }
                                                        else if(swapCards.length==1)
                                                        {
                                                          setState(() {
                                                            swapCards.add(_c8);
                                                            i2 = 7;
                                                          });
                                                          setState(() {
                                                            myCards[i1] = swapCards[1];
                                                            myCards[i2] = swapCards[0];
                                                          });
                                                          await room.reference.setData(
                                                              {
                                                                'players': {
                                                                  element : {
                                                                    'cards' : myCards[0]+'-'+myCards[1]+'-'+myCards[2]+'-'+myCards[3]+'-'+myCards[4]+'-'+myCards[5]+'-'+myCards[6]+'-'+myCards[7],
                                                                    'draw': false,
                                                                    'show':false,
                                                                  }
                                                                }
                                                              },merge: true,
                                                          );
                                                          setState(() {
                                                            myCards.clear();
                                                            swapCards.clear();
                                                            i1=i2=null;
                                                          });
                                                        }
                                                      },
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      !playerInfo['draw']
                                          ? SizedBox()
                                          : Container(
                                              margin: EdgeInsets.all(10),
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  color: Colors.yellow
                                                      .withOpacity(0.9),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              child: Text(
                                                'ဆွဲမယ်ဟေ့',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w900,
                                                    decorationColor:
                                                        Colors.yellow),
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ));
                  });

                  return Container(
                      child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          childAspectRatio: 1 / 1.4,

                          children: playerDesk));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

