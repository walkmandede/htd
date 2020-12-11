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

class Room extends StatefulWidget {
  final String docID;

  const Room(this.docID);

  @override
  _RoomState createState() => _RoomState();
}

class _RoomState extends State<Room> {
  String txt = 'Exit';
  String host = '';
  String me= '';
  Map<String,bool> isShowed ={};
  Map<String,bool> wannaDraw ={};
  bool isDrag = false;
  bool showTime = false;
  DocumentSnapshot ds;
  bool dd= false;


  List cards = [
    'AS','2S','3S','4S','5S','6S','7S','8S','9S','0S','JS','QS','KS',
    'AH','2H','3H','4H','5H','6H','7H','8H','9H','0H','JH','QH','KH',
    'AD','2D','3D','4D','5D','6D','7D','8D','9D','0D','JD','QD','KD',
    'AC','2C','3C','4C','5C','6C','7C','8C','9C','0C','JC','QC','KC',
  ];
  
  List<Widget> playerPic = [];

  Future<void> getData() async{
    ds = await Firestore.instance.collection('Room').document(widget.docID).get();
    QuerySnapshot pds = await Firestore.instance.collection('employee').getDocuments();
    Map players = ds.data['players'];
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      host= ds.data['host'];
      me = sp.getString('currentUser');
    });
    players.keys.forEach((element) {
      isShowed.addEntries(
          [
            MapEntry(element, false)
          ]
      );
      wannaDraw.addEntries(
          [
            MapEntry(element, false)
          ]
      );
      pds.documents.forEach((tt) {
        if(tt.documentID==element)
          {
            if(tt.documentID==host)
              {
                playerPic.add(
                    new Stack(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(tt.data['Picture']),
                          radius: 25,
                        ),
                        Icon(Icons.home,color: Colors.greenAccent,)

                      ],
                    )
                );
              }
            else{
              playerPic.add(
                  new CircleAvatar(
                    radius: 25,
                    backgroundImage: CachedNetworkImageProvider(tt.data['Picture']),
                  )
              );
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


  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightGreenAccent,
          leading: SizedBox(),
         flexibleSpace:                  Center(
           child: Container(
             color: Colors.lightGreenAccent,
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 FlatButton(child: Text('Back'),onPressed: () {
                   Navigator.of(context,rootNavigator: true).pop();
                 },),
                 FlatButton.icon(
                   icon: Icon(Icons.exit_to_app),
                   label: Text(txt),
                   onPressed: () async{
                     SharedPreferences sp = await SharedPreferences.getInstance();
                     DocumentSnapshot room= await Firestore.instance
                         .collection("Room")
                         .document(widget.docID.toString())
                         .get();
                     Map players = room.data['players'];
                     Map _newPlayers = {};

                     players.keys.forEach((element) {
                       if(element!=sp.getString('currentUser'))
                       {
                         _newPlayers.addEntries(
                             [
                               MapEntry(element,players[element])
                             ]
                         );
                       }

                     });
                     room.reference.updateData(
                         {
                           'players': _newPlayers
                         }
                     );
                     Navigator.of(context,rootNavigator: true).pop();
                   },
                 ),
                 host!=me?SizedBox():FlatButton.icon(
                   icon: Icon(Icons.play_arrow),
                   label: Text('ဖဲဝေ'),
                   onPressed: () async{
                     SharedPreferences sp = await SharedPreferences.getInstance();
                     DocumentSnapshot room= await Firestore.instance
                         .collection("Room")
                         .document(widget.docID.toString())
                         .get();
                     Map players = room.data['players'];
                     setState(() {
                       cards =  [
                         'AS','2S','3S','4S','5S','6S','7S','8S','9S','0S','JS','QS','KS',
                         'AH','2H','3H','4H','5H','6H','7H','8H','9H','0H','JH','QH','KH',
                         'AD','2D','3D','4D','5D','6D','7D','8D','9D','0D','JD','QD','KD',
                         'AC','2C','3C','4C','5C','6C','7C','8C','9C','0C','JC','QC','KC',
                       ];
                     });
                     players.keys.forEach((element) {
                       String c1,c2;
                       var rng = new Random();
                       int c1i,c2i;
                       c1i = rng.nextInt(cards.length);
                       c1 = cards[c1i];
                       cards.removeAt(c1i);
                       c2i = rng.nextInt(cards.length);
                       c2 = cards[c2i];
                       cards.removeAt(c2i);
                       setState(() {

                       });
                       room.reference.setData(
                           {
                             'players':{
                               element:{
                                 'cards':c1+'-'+c2,
                                 'show':false,
                                 'draw':false
                               }
                             }
                           },merge: true
                       ).then((value) async{
                         DocumentSnapshot tt =  await Firestore.instance.collection('Room').document(widget.docID).get();
                         setState(() {
                           showTime  = true;
                           ds = tt;
                         });
                       } );
                     });
                   },
                 ),
               ],
             ),
           ),
         ),
        ),
        body: Column(
          children: [
            SizedBox(height: 10,),
            Flexible(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("Room")
                    .document(widget.docID.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  final DocumentSnapshot room = snapshot.data;
                  Map players = room.data['players'];
                  if(!snapshot.hasData){
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
                    Map playerInfo = players[element];
                    String _name = element.toString();
                    String _c1='No Card';
                    String _c2='No Card';
                    String _c3='';
                    if(playerInfo['cards'].toString()!='')
                    {
                      _c1 = playerInfo['cards'].toString().split('-')[0];
                      _c2 = playerInfo['cards'].toString().split('-')[1];
                      if(playerInfo['cards'].toString().length>7)
                        {
                          _c3 = playerInfo['cards'].toString().split('-')[2];
                        }

                    }

                    playerDesk.add(
                        new Flexible(
                          child: Container(
                            child:  playerInfo['show']?
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Text(_name.split('@')[0],style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500),),
                                        padding: EdgeInsets.all(5),
                                        decoration: element==me?BoxDecoration(
                                            color: Colors.lightGreenAccent,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: element==host?Colors.red:Colors.black,width: 2)
                                        ):
                                        BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: element==host?Colors.red:Colors.black,width: 2)
                                        ),
                                      ),
                                      Container(
                                        child: Text(playerInfo['cards'].toString().split('-').length.toString()+' Cards',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500),),
                                        padding: EdgeInsets.all(5),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.all(5),
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(15)),
                                        gradient: LinearGradient(
                                            colors: [
                                              Colors.black,
                                              Colors.blueGrey,
                                            ]
                                        )
                                    ),
                                    child:
                                    Row(children: [
                                      Container(
                                          height:70,
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black)
                                          ),
                                          child: CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',)
                                      ),
                                      Container(
                                          height:70,
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black)
                                          ),
                                          child:
                                          CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                      ),
                                      _c3==''?SizedBox():
                                      Container(
                                          height:70,
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          decoration: BoxDecoration(
                                              border: Border.all(color: Colors.black)
                                          ),
                                          child:         CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c3.toString()}.png')
                                      ),
                                    ],)
                                    ,
                                  ),
                                ],
                              ):
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Text(_name.split('@')[0],style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500),),
                                        padding: EdgeInsets.all(5),
                                        decoration: element==me?BoxDecoration(
                                            color: Colors.lightGreenAccent,
                                          borderRadius: BorderRadius.all(Radius.circular(10)),
                                          border: Border.all(color: element==host?Colors.red:Colors.black,width: 2)
                                        ):
                                        BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius: BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(color: element==host?Colors.red:Colors.black,width: 2)
                                        ),
                                      ),
                                      Container(
                                        child: Text(playerInfo['cards'].toString().split('-').length.toString()+' Cards',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.w500),),
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
                                          borderRadius: BorderRadius.all(Radius.circular(15)),
                                          gradient: LinearGradient(
                                              colors: [
                                                Colors.black,
                                                Colors.blueGrey,
                                              ]
                                          )
                                      ),
                                      child:
                                      playerInfo['cards'].toString().length>7?
                                      Row(
                                        children: [
                                          Container(
                                              height:70,
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.black)
                                              ),
                                              child: playerInfo['cards'].toString()==''||element!=me?
                                              CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',)
                                                  :CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',)
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierColor: Colors.black.withOpacity(0.7),
                                                context: context,
                                                builder: (BuildContext context) {
                                                  // return object of type Dialog
                                                  return StatefulBuilder(builder: (context, StateSetter setState) {
                                                    return  Center(
                                                      child:Stack(
                                                        children: [
                                                          Container(
                                                              height: MediaQuery.of(context).size.height*0.6,
                                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                                              child: playerInfo['cards'].toString()==''||element!=me?
                                                              CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                              CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c3.toString()}.png')
                                                          ),
                                                          Draggable(
                                                            feedback:
                                                            Container(
                                                                height: MediaQuery.of(context).size.height*0.6,
                                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                                child: playerInfo['cards'].toString()==''||element!=me?
                                                                CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                                CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                            ),
                                                            child:
                                                            Container(
                                                                height: MediaQuery.of(context).size.height*0.6,
                                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                                child: playerInfo['cards'].toString()==''||element!=me?
                                                                CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                                CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                            ),
                                                            childWhenDragging: SizedBox(),
                                                            onDragStarted: () {
                                                              setState(() {
                                                                dd = true;
                                                              });
                                                            },
                                                            onDragEnd: (details) {

                                                              setState(() {
                                                                dd = false;
                                                              });
                                                            },
                                                            onDragCompleted: () {
                                                              setState(() {
                                                                dd = false;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  );
                                                },
                                              );
                                            },
                                            child:  Stack(
                                              children: [
                                                Container(
                                                    height:70,
                                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.black)
                                                    ),
                                                    child: playerInfo['cards'].toString()==''||element!=me?
                                                    CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',)
                                                        :CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',)
                                                ),
                                                Draggable(
                                                  feedback:
                                                  Container(
                                                      height:70,
                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.black)
                                                      ),
                                                      child: playerInfo['cards'].toString()==''||element!=me?
                                                      CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                      CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                  ),
                                                  child: dd?SizedBox():
                                                  Container(
                                                      height:70,
                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.black)
                                                      ),
                                                      child: playerInfo['cards'].toString()==''||element!=me?
                                                      CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                      CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                  ),
                                                  childWhenDragging: Container(),
                                                  onDragStarted: () {
                                                    setState(() {
                                                      dd = true;
                                                    });
                                                  },
                                                  onDragEnd: (details) {

                                                    setState(() {
                                                      dd = false;
                                                    });
                                                  },
                                                  onDragCompleted: () {
                                                    setState(() {
                                                      dd = false;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                      ],):
                                      Row(
                                        children:[
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                barrierColor: Colors.black.withOpacity(0.7),
                                                context: context,
                                                builder: (BuildContext context) {
                                                  // return object of type Dialog
                                                  return StatefulBuilder(builder: (context, StateSetter setState) {
                                                    return  Center(
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                              height:MediaQuery.of(context).size.height*0.6,
                                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                                              child: playerInfo['cards'].toString()==''||element!=me?
                                                              CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',)
                                                                  :CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',)
                                                          ),
                                                          Draggable(
                                                            feedback:
                                                            Container(
                                                                height:MediaQuery.of(context).size.height*0.6,
                                                                margin: EdgeInsets.symmetric(horizontal: 5),

                                                                child: playerInfo['cards'].toString()==''||element!=me?
                                                                CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                                CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                            ),
                                                            child:
                                                            Container(
                                                                height:MediaQuery.of(context).size.height*0.6,
                                                                margin: EdgeInsets.symmetric(horizontal: 5),
                                                                child: playerInfo['cards'].toString()==''||element!=me?
                                                                CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                                CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                            ),
                                                            onDragStarted: () {
                                                              setState(() {
                                                                dd = true;
                                                              });
                                                            },
                                                            childWhenDragging: SizedBox(
                                                            ),
                                                            onDragEnd: (details) {
                                                              setState(() {
                                                                dd = false;
                                                              });
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  );
                                                },
                                              );
                                            },
                                            child:  Stack(
                                              children: [
                                                Container(
                                                    height:70,
                                                    margin: EdgeInsets.symmetric(horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.black)
                                                    ),
                                                    child: playerInfo['cards'].toString()==''||element!=me?
                                                    CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',)
                                                        :CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c1.toString()}.png',)
                                                ),
                                                Draggable(
                                                  feedback:
                                                  Container(
                                                      height:70,
                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.black)
                                                      ),
                                                      child: playerInfo['cards'].toString()==''||element!=me?
                                                      CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                      CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                  ),
                                                  childWhenDragging: Container(height: 70,),
                                                  child:
                                                  Container(
                                                      height:70,
                                                      margin: EdgeInsets.symmetric(horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.black)
                                                      ),
                                                      child: playerInfo['cards'].toString()==''||element!=me?
                                                      CachedNetworkImage(imageUrl: 'https://i.pinimg.com/originals/c9/e5/61/c9e561d61fc50771ece1255125f7fb1a.jpg',):
                                                      CachedNetworkImage(imageUrl: 'https://deckofcardsapi.com/static/img/${_c2.toString()}.png')
                                                  ),
                                                  onDragStarted: () {
                                                    setState(() {
                                                      dd = true;
                                                    });
                                                  },
                                                  onDragEnd: (details) {

                                                    setState(() {
                                                      dd = false;
                                                    });
                                                  },
                                                  onDragCompleted: () {
                                                    setState(() {
                                                      dd = false;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          )
                                        ]),
                                    ),
                                      !playerInfo['draw']?SizedBox():
                                      Container(
                                        margin: EdgeInsets.all(10),
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.withOpacity(0.9),
                                          borderRadius: BorderRadius.all(Radius.circular(10))
                                        ),
                                        child: Text('ဆွဲမယ်ဟေ့',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w900,
                                              decorationColor: Colors.yellow
                                          ),),
                                      ),
                                  ],),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      element!=me?SizedBox():GestureDetector(
                                        child: Text('ပြမယ်',style: TextStyle(color: Colors.red)),
                                        onTap: () {
                                          room.reference.setData(
                                            {
                                              'players': {
                                                element: {
                                                  'show':true
                                                }
                                              },
                                            },merge: true,
                                          );
                                        },),
                                      element!=me?SizedBox():GestureDetector(
                                        child: Text('ဆွဲမယ်',style: TextStyle(color: Colors.red)),
                                        onTap: () {
                                          room.reference.setData(
                                            {
                                              'players': {
                                                element: {
                                                  'draw':true
                                                }
                                              },
                                            },merge: true,
                                          );
                                        },),
                                      host==me&&playerInfo['draw']==true?
                                      GestureDetector(
                                        child: Text('ဖဲပေး',style: TextStyle(color: Colors.green)),
                                        onTap: () async{
                                          String c3;
                                          var rng = new Random();
                                          int c3i;
                                          c3i = rng.nextInt(cards.length);
                                          c3 = cards[c3i];
                                          cards.removeAt(c3i);
                                          setState(() {

                                          });
                                          SharedPreferences sp = await SharedPreferences.getInstance();
                                          room.reference.setData(
                                            {
                                              'players': {
                                                element: {
                                                  'cards':_c1+'-'+_c2+'-'+c3,
                                                  'draw':false,
                                                }
                                              },
                                            },merge: true,
                                          );
                                        },):
                                      SizedBox()
                                    ],
                                  )
                                ],
                              ),
                          ),
                        )
                    );
                  });

                  return Container(
                      child: GridView.count(
                        crossAxisCount: 2,
                          shrinkWrap: true,
                          children:
                          playerDesk

                      )
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
