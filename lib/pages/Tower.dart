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

class Tower extends StatefulWidget {
  final String docID;

  const Tower(this.docID);

  @override
  _TowerState createState() => _TowerState();
}

class _TowerState extends State<Tower> with TickerProviderStateMixin{

  String me;

  void handleTimeout() async{
    showAlertDialog(context, 'Time\'s up', Text('Press OK to continue!'), [FlatButton(child: Text('OK'),onPressed: () => Navigator.of(context,rootNavigator: true).pop(),)]);
    DocumentSnapshot room = await Firestore.instance
        .collection("Tower")
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
    SharedPreferences sp =await SharedPreferences.getInstance();
    setState(() {
      me = sp.getString('currentUser');
    });

  }

  @override
  void initState() {

    getData();
    super.initState();
  }

  Timer timeLeft;
  String _selection;
  bool isDragged =false;

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
                  .collection("Tower")
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
          ],
        ),
        body: Column(
          children: [
            Flexible(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection("Tower")
                    .document(widget.docID.toString())
                    .snapshots(),
                builder: (context, snapshot) {
                  final DocumentSnapshot room = snapshot.data;

                  Map _players = room.data['players'];
                  Map _cards = room.data['cards'];
                  String turn = room.data['state'];
                  int myBrick =  _players[me]['brick'];
                  int myBullet =  _players[me]['bullet'];
                  int myMagic =  _players[me]['magic'];
                  String enemy;
                  int myHp,enemyHp;
                  String winner;
                  List log = room.data['log'];
                  Widget logShow ;

                  if(log!=null)
                    {
                      String loglog = log.last;
                      String _logname = loglog.split(':')[0].split('@')[0];
                      String _logcard = loglog.split(':')[1];
                      logShow = Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(_logname),Text(_logcard)
                        ],
                      );
                    }

                  List<Widget> cardsWidget=[
                    FlatButton.icon(
                     icon: Icon(Icons.not_interested),label: Text('Skip'),
                      onPressed: () async{
                       _players.keys.forEach((tt) async{
                         int skipBrick = _players[tt]['brick'];
                         int skipBullet = _players[tt]['bullet'];
                         int skipMagic = _players[tt]['magic'];
                         int skipSoldiers = _players[tt]['soldiers'];
                         int skipWorkers = _players[tt]['workers'];
                         int skipMages = _players[tt]['mages'];
                         if(tt==me){
                           await room.reference.setData(
                               {
                                 'players':{
                                   me:{
                                     'brick':skipBrick+skipWorkers,
                                     'bullet':skipBullet+skipWorkers,
                                     'magic':skipMagic+skipMages,
                                   }
                                 },
                                 'state':turn==me?enemy:me
                               },merge: true
                           );
                         }
                         else{
                           await room.reference.setData(
                               {
                                 'players':{
                                   enemy:{
                                     'brick':skipBrick+skipWorkers,
                                     'bullet':skipBullet+skipWorkers,
                                     'magic':skipMagic+skipMages
                                   }
                                 },
                                 'state':turn==me?enemy:me
                               },merge: true
                           );
                         }
                       });
                      },
                    )
                  ];
                  List allCard = _cards.keys.toList();
                  List showCard = [];


                  int c1,c2,c3,c4;
                  var rng = new Random();
                  c1 = rng.nextInt(allCard.length);
                  showCard.add(allCard[c1]);
                  allCard.removeAt(c1);

                  c2 = rng.nextInt(allCard.length);
                  showCard.add(allCard[c2]);
                  allCard.removeAt(c2);

                  c3 = rng.nextInt(allCard.length);
                  showCard.add(allCard[c3]);
                  allCard.removeAt(c3);

                  c4 = rng.nextInt(allCard.length);
                  showCard.add(allCard[c4]);
                  allCard.removeAt(c4);


                  Widget myTowerWidget,enemyTowerWidget;
                  _cards.keys.forEach((element) {
                    String description = _cards[element]['desc'];
                    int costBrick = _cards[element]['cost']['brick'];
                    int costBullet = _cards[element]['cost']['bullet'];
                    int costMagic = _cards[element]['cost']['magic'];
                    if(
                      costBrick > myBrick || costBullet > myBullet || costMagic > myMagic
                    )
                      {

                        if (showCard.contains(element))
                        {
                          cardsWidget.add(
                             new  Stack(
                                children: [
                                  new Container(
                                      margin: EdgeInsets.all(5),
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider('https://previews.123rf.com/images/alisbalb/alisbalb1308/alisbalb130800067/21742960-ancient-playing-card-with-line-grunge-paper-abstract-background.jpg'),
                                            fit: BoxFit.fill,
                                          ),
                                      ),
                                      child: Container(
                                        height: 120,width: 100,
                                        child: Column(
                                          children: [
                                            Text(element.toString(),style: GoogleFonts.medievalSharp(color: Colors.deepOrange),),
                                            Divider(thickness: 2,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                        width: 15,height: 15,
                                                        child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/elasto-building/26/02-BUILDING-READY_building-brick-512.png'),),
                                                    Text( costBrick.toString()),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                        width: 15,height: 15,
                                                        child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/army-line/614/1281_-_Bullet-512.png')),
                                                    Text( costBullet.toString()),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Container(
                                                        width: 15,height: 15,
                                                        child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/stars-8/64/221_stars-magic-glitter-shimmer-satin-512.png')),
                                                    Text( costMagic.toString()),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.all(5),
                                                child: Text(description,style: GoogleFonts.medievalSharp(color: Colors.red,fontWeight: FontWeight.w900),),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                  ),
                                  Container(
                                    child: Icon(Icons.not_interested,color: Colors.red,),
                                  ),
                                ],
                              )
                          );
                        }
                      }
                    else
                      {
                        if (showCard.contains(element))
                        {
                          cardsWidget.add(
                            new Container(
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider('https://previews.123rf.com/images/alisbalb/alisbalb1308/alisbalb130800067/21742960-ancient-playing-card-with-line-grunge-paper-abstract-background.jpg'),
                                    fit: BoxFit.fill,
                                  )
                              ),
                              child: Draggable(
                                data: element.toString(),
                                child: Container(
                                    height: 120,width: 100,
                                    child: Column(
                                      children: [
                                        Text(element.toString(),style: GoogleFonts.medievalSharp(color: Colors.deepOrange),),
                                        Divider(thickness: 2,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                    width: 15,height: 15,
                                                    child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/elasto-building/26/02-BUILDING-READY_building-brick-512.png')),
                                                Text( costBrick.toString()),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    width: 15,height: 15,
                                                    child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/army-line/614/1281_-_Bullet-512.png')),
                                                Text( costBullet.toString()),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    width: 15,height: 15,
                                                    child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/stars-8/64/221_stars-magic-glitter-shimmer-satin-512.png')),
                                                Text( costMagic.toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(description,style: GoogleFonts.medievalSharp(color: Colors.green,fontWeight: FontWeight.w900),),
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                feedback: Material(
                                  child: Container(
                                      height: 120,width: 100,
                                      child: Column(
                                        children: [
                                          Text(element.toString(),style: GoogleFonts.medievalSharp(color: Colors.deepOrange),),
                                          Divider(thickness: 2,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  Container(
                                                      width: 15,height: 15,
                                                      child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/elasto-building/26/02-BUILDING-READY_building-brick-512.png')),
                                                  Text( costBrick.toString()),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      width: 15,height: 15,
                                                      child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/army-line/614/1281_-_Bullet-512.png')),
                                                  Text( costBullet.toString()),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                      width: 15,height: 15,
                                                      child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/stars-8/64/221_stars-magic-glitter-shimmer-satin-512.png')),
                                                  Text( costMagic.toString()),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(description,style: GoogleFonts.medievalSharp(color: Colors.brown),),
                                            ),
                                          ),
                                        ],
                                      )
                                  ),
                                ),
                                childWhenDragging: Container(
                                    height: 120,width: 100,
                                    child: Column(
                                      children: [
                                        Text(element.toString(),style: GoogleFonts.medievalSharp(color: Colors.deepOrange),),
                                        Divider(thickness: 2,),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                Container(
                                                    width: 15,height: 15,
                                                    child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/elasto-building/26/02-BUILDING-READY_building-brick-512.png')),
                                                Text( costBrick.toString()),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    width: 15,height: 15,
                                                    child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/army-line/614/1281_-_Bullet-512.png')),
                                                Text( costBullet.toString()),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                    width: 15,height: 15,
                                                    child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/stars-8/64/221_stars-magic-glitter-shimmer-satin-512.png')),
                                                Text( costMagic.toString()),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(description,style: GoogleFonts.medievalSharp(color: Colors.brown),),
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                onDragCompleted: () {

                                },
                              ),
                            ),
                          );
                        }
                      }



                  }
                  );

                  _players.keys.forEach((element) {
                    int hp = _players[element]['hp'];
                    int sh = _players[element]['shield'];
                    int br = _players[element]['brick'];
                    int bu = _players[element]['bullet'];
                    int mg = _players[element]['magic'];
                    int so = _players[element]['soldiers'];
                    int wo = _players[element]['workers'];
                    int mo = _players[element]['mages'];

                    if(element!=me)
                      {
                        enemy=element;
                        enemyHp = hp;
                      }
                    else{
                      myHp = hp;
                    }
                    if(element==me)
                      {
                        myTowerWidget = DragTarget(builder: (context, List<String> candidateData, rejectedData) {
                          return  Container(
                            width: MediaQuery.of(context).size.width*0.5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                Container(
                                  padding: EdgeInsets.all(20),
                                  child: Text('Your Castle',style: GoogleFonts.medievalSharp(color: Colors.green,fontWeight: FontWeight.w800),),
                                ),
                                Container(
                                  margin: EdgeInsets.all(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      hp==0?SizedBox():Container(
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                        ),
                                        height: double.parse(hp.toString()),
                                      ),
                                      sh==0?SizedBox():Container(
                                        width: 10,
                                        height: double.parse(sh.toString()),
                                        color: Colors.yellow,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/materia-flat-buildings-vol-3/24/017_122_castle_bastion_building_tower-512.png')),
                                        Text( hp.toString()),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn3.iconfinder.com/data/icons/role-playing-game-6/340/ability_skill_shield_game_wall_protection_castle-512.png')),
                                        Text( sh.toString()),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 40,),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/elasto-building/26/02-BUILDING-READY_building-brick-512.png')),
                                        Text( br.toString()),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/army-line/614/1281_-_Bullet-512.png')),
                                        Text( bu.toString()),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/stars-8/64/221_stars-magic-glitter-shimmer-satin-512.png')),
                                        Text( mg.toString()),
                                      ],
                                    ),
                                  ],
                                ),

                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/aami-web-internet/64/aami15-07-512.png')),
                                        Text( wo.toString()),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/military-3/500/military_3-512.png')),
                                        Text( so.toString()),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                            width: 25,height: 25,
                                            child: CachedNetworkImage(imageUrl: 'https://cdn1.iconfinder.com/data/icons/games-fourteen-black-and-white/128/character-person-wizard-mage-512.png')),
                                        Text( mo.toString()),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        },
                          onWillAccept: (data) {
                            return true;
                          },
                          onAccept: (data) async{
                            setState(() {
                              isDragged = true;
                            });
                            Map _usedCard = room.data['cards'][data];

                            Map _myResource = room.data['players'][me];
                            int myBullets = _myResource['bullet'];
                            int myBrick = _myResource['brick'];
                            int myMagic = _myResource['magic'];

                            int costbullet = _usedCard['cost']['bullet'];
                            int costbrick = _usedCard['cost']['brick'];
                            int costmagic = _usedCard['cost']['magic'];

                            if(
                            costbullet > myBullets || costbrick > myBrick || costmagic > myMagic
                            )
                            {
                              showDialog(
                                context: context,
                                child: AlertDialog(
                                 title: Text('Insufficient Resources!'),
                                )
                              );
                            }

                            else
                              {
                                int carddmg = _usedCard['effect']['dmg'];
                                int cardhp = _usedCard['effect']['hp'];
                                int cardsh = _usedCard['effect']['shield'];
                                int cardbullet = _usedCard['effect']['bullet'];
                                int cardbrick = _usedCard['effect']['brick'];
                                int cardmagic = _usedCard['effect']['magic'];
                                int cardworkers = _usedCard['effect']['workers'];
                                int cardsoldiers = _usedCard['effect']['soldiers'];
                                int cardmages = _usedCard['effect']['mages'];

                                int finalhp = hp+cardhp;
                                int finalsh = sh+cardsh;
                                int finalbr = br+cardbrick;
                                int finalbu = bu+cardbullet;
                                int finalmg = mg+cardmagic;
                                int finalso = so+cardsoldiers;
                                int finalwo = wo+cardworkers;
                                int finalmo = mo+cardmages;



                                if(finalsh>carddmg)
                                {
                                  finalsh = finalsh+carddmg;
                                }
                                else
                                {
                                  finalhp = finalhp+finalsh+carddmg;
                                  finalsh = 0;
                                }

                                if( finalhp < 0) finalhp = 0;
                                if( finalsh < 0) finalsh = 0;
                                if( finalbr < 0) finalbr = 0;
                                if( finalbu < 0) finalbu = 0;
                                if( finalmg < 0) finalmg = 0;
                                if( finalso < 0) finalso = 0;
                                if( finalwo < 0) finalwo = 0;
                                if( finalmo < 0) finalmo = 0;

                                await room.reference.setData(
                                    {
                                      'players':{
                                        element:{
                                          'hp':finalhp,
                                          'shield':finalsh,
                                          'brick':finalbr,
                                          'bullet':finalbu,
                                          'magic':finalmg,
                                          'workers':finalwo,
                                          'soldiers':finalso,
                                          'mages':finalmo,
                                        }
                                      },
                                      'log': FieldValue.arrayUnion([element+' : '+data])
                                    },merge: true
                                );

                                _players.keys.forEach((kk)async {
                                  int rhp = _players[kk]['hp'];
                                  int rsh = _players[kk]['shield'];
                                  int rbr = _players[kk]['brick'];
                                  int rbu = _players[kk]['bullet'];
                                  int rmg = _players[kk]['magic'];
                                  int rso = _players[kk]['soldiers'];
                                  int rwo = _players[kk]['workers'];
                                  int rmo = _players[kk]['mages'];
                                  if(kk==me){
                                    await room.reference.setData(
                                        {
                                          'players':{
                                            kk:{
                                              'brick':rbr+rwo-costbrick,
                                              'bullet':rbu+rso-costbullet,
                                              'magic':rmg+rmo-costmagic,
                                            }
                                          },
                                          'state':turn==me?enemy:me,
                                        },merge: true
                                    );
                                  }
                                  else{
                                    await room.reference.setData(
                                        {
                                          'players':{
                                            kk:{
                                              'brick':rbr+rwo,
                                              'bullet':rbu+rso,
                                              'magic':rmg+rmo,
                                            }
                                          },
                                          'state':turn==me?enemy:me
                                        },merge: true
                                    );
                                  }

                                }
                                );
                            }
                          },
                        );
                      }
                    else
                      enemyTowerWidget = DragTarget(builder: (context, List<String> candidateData, rejectedData) {
                        return  Container(

                          width: MediaQuery.of(context).size.width*0.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [

                              Container(
                                padding: EdgeInsets.all(20),
                                child: Text('${element.toString().split('@')[0]} \'s Castle',style: GoogleFonts.medievalSharp(color: Colors.red,fontWeight: FontWeight.w800),),
                              ),
                              Container(
                                margin: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    sh==0?SizedBox():Container(
                                      width: 10,
                                      height: double.parse(sh.toString()),
                                      color: Colors.yellow,
                                    ),
                                    hp==0?SizedBox():Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                                      ),
                                      height: double.parse(hp.toString()),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/materia-flat-buildings-vol-3/24/017_122_castle_bastion_building_tower-512.png')),
                                      Text( hp.toString()),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn3.iconfinder.com/data/icons/role-playing-game-6/340/ability_skill_shield_game_wall_protection_castle-512.png')),
                                      Text( sh.toString()),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 40,),
                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/elasto-building/26/02-BUILDING-READY_building-brick-512.png')),
                                      Text( br.toString()),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/army-line/614/1281_-_Bullet-512.png')),
                                      Text( bu.toString()),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/stars-8/64/221_stars-magic-glitter-shimmer-satin-512.png')),
                                      Text( mg.toString()),
                                    ],
                                  ),
                                ],
                              ),

                              Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn0.iconfinder.com/data/icons/aami-web-internet/64/aami15-07-512.png')),
                                      Text( wo.toString()),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn4.iconfinder.com/data/icons/military-3/500/military_3-512.png')),
                                      Text( so.toString()),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                          width: 25,height: 25,
                                          child: CachedNetworkImage(imageUrl: 'https://cdn1.iconfinder.com/data/icons/games-fourteen-black-and-white/128/character-person-wizard-mage-512.png')),
                                      Text( mo.toString()),
                                    ],
                                  ),
                                ],
                              ),
                              Divider(),
                            ],
                          ),
                        );
                      },
                        onWillAccept: (data) {
                          return true;
                        },
                        onAccept: (data) async{
                          setState(() {
                            isDragged = true;
                          });
                          Map _usedCard = room.data['cards'][data];

                          Map _myResource = room.data['players'][me];
                          int myBullets = _myResource['bullet'];
                          int myBrick = _myResource['brick'];
                          int myMagic = _myResource['magic'];

                          int costbullet = _usedCard['cost']['bullet'];
                          int costbrick = _usedCard['cost']['brick'];
                          int costmagic = _usedCard['cost']['magic'];

                          if(
                          costbullet > myBullets || costbrick > myBrick || costmagic > myMagic
                          )
                          {
                            showDialog(
                                context: context,
                                child: AlertDialog(
                                  title: Text('Insufficient Resources!'),
                                )
                            );
                          }

                          else
                          {
                            int carddmg = _usedCard['effect']['dmg'];
                            int cardhp = _usedCard['effect']['hp'];
                            int cardsh = _usedCard['effect']['shield'];
                            int cardbullet = _usedCard['effect']['bullet'];
                            int cardbrick = _usedCard['effect']['brick'];
                            int cardmagic = _usedCard['effect']['magic'];
                            int cardworkers = _usedCard['effect']['workers'];
                            int cardsoldiers = _usedCard['effect']['soldiers'];
                            int cardmages = _usedCard['effect']['mages'];

                            int finalhp = hp+cardhp;
                            int finalsh = sh+cardsh;
                            int finalbr = br+cardbrick;
                            int finalbu = bu+cardbullet;
                            int finalmg = mg+cardmagic;
                            int finalso = so+cardsoldiers;
                            int finalwo = wo+cardworkers;
                            int finalmo = mo+cardmages;



                            if(finalsh>carddmg)
                            {
                              finalsh = finalsh+carddmg;
                            }
                            else
                            {
                              finalhp = finalhp+finalsh+carddmg;
                              finalsh = 0;
                            }

                            if( finalhp < 0) finalhp = 0;
                            if( finalsh < 0) finalsh = 0;
                            if( finalbr < 0) finalbr = 0;
                            if( finalbu < 0) finalbu = 0;
                            if( finalmg < 0) finalmg = 0;
                            if( finalso < 0) finalso = 0;
                            if( finalwo < 0) finalwo = 0;
                            if( finalmo < 0) finalmo = 0;

                            await room.reference.setData(
                                {
                                  'players':{
                                    element:{
                                      'hp':finalhp,
                                      'shield':finalsh,
                                      'brick':finalbr,
                                      'bullet':finalbu,
                                      'magic':finalmg,
                                      'workers':finalwo,
                                      'soldiers':finalso,
                                      'mages':finalmo,
                                    }
                                  },
                                  'log': FieldValue.arrayUnion([element+' : '+data])
                                },merge: true
                            );

                            _players.keys.forEach((kk)async {
                              int rhp = _players[kk]['hp'];
                              int rsh = _players[kk]['shield'];
                              int rbr = _players[kk]['brick'];
                              int rbu = _players[kk]['bullet'];
                              int rmg = _players[kk]['magic'];
                              int rso = _players[kk]['soldiers'];
                              int rwo = _players[kk]['workers'];
                              int rmo = _players[kk]['mages'];
                              if(kk==me){
                                await room.reference.setData(
                                    {
                                      'players':{
                                        kk:{
                                          'brick':rbr+rwo-costbrick,
                                          'bullet':rbu+rso-costbullet,
                                          'magic':rmg+rmo-costmagic,
                                        }
                                      },
                                      'state':turn==me?enemy:me
                                    },merge: true
                                );
                              }
                              else{
                                await room.reference.setData(
                                    {
                                      'players':{
                                        kk:{
                                          'brick':rbr+rwo,
                                          'bullet':rbu+rso,
                                          'magic':rmg+rmo,
                                        }
                                      },
                                      'state':turn==me?enemy:me
                                    },merge: true
                                );
                              }

                            }
                            );
                          }
                        },
                      );
                  });


                  if(myHp==0||enemyHp==0)
                  {
                    if(myHp==0)
                    {
                      winner = enemy;
                    }
                    else
                    {
                      winner = me;
                    }
                  }
                  else if(myHp>=100||enemyHp>=100)
                  {
                    if(myHp>=100)
                    {
                      winner = me;
                    }
                    else
                    {
                      winner = enemy;
                    }
                  }



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

                  return   Container(
                    child: Column(
                      children: [
                        Container(
                          height: 40,
                          color: Colors.lightBlue.shade100,
                          child: Center(child: Text('Turn : '+turn,style: GoogleFonts.medievalSharp(color: Colors.blueGrey,fontWeight: FontWeight.w900),),),
                        ),
                        Expanded(
                          flex: 3,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: CachedNetworkImageProvider(
                                        'https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/i/99fa4d7d-f84a-448b-9b38-6a371e79a778/d58bzfk-83b671ef-f329-4551-9237-8a7d1ac5acff.png'
                                      )
                                    )
                                  ),
                                  child: winner!=null?
                                      Center(
                                        child:    Text('Winner is '+winner),)
                                      :Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      myTowerWidget,
                                      enemyTowerWidget,
                                    ],
                                  ),
                                ),
                               Container(
                                 margin: EdgeInsets.all(20),
                                 child: logShow,
                               )
                              ],
                            ),
                        ),
                        //Controller
                        Expanded(
                            flex: 1,
                            child:
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider('https://t4.ftcdn.net/jpg/03/33/94/35/360_F_333943569_aFQ1ieFUq5jo9Y9WxTs8DAUaGdB17cWX.jpg'),
                                        fit: BoxFit.fill
                                      ),
                                ),
                                  child:
                                  turn==me?
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: cardsWidget,
                                    ),
                                  )
                                :                            Container(
                                  child: Center(
                                    child: Text('Not Your Turn!'),
                                  ),
                                )
                        ),
                        )
                      ],
                    ),
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

