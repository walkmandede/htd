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

class ChatManagement extends StatelessWidget {
  const ChatManagement();

  @override
  Widget build(BuildContext context) {
    TextEditingController msgCntrl = new TextEditingController();
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: ChatManagementForm(),
        resizeToAvoidBottomPadding: true,
      ),
    );
  }
}

class ChatManagementForm extends StatefulWidget {
  const ChatManagementForm();

  @override
  _ChatManagementFormState createState() => _ChatManagementFormState();
}

class _ChatManagementFormState extends State<ChatManagementForm> {
  CollectionReference groupCR;
  List<Widget> chatCards = [];
  QuerySnapshot gpQS;
  List<DocumentSnapshot> gpDS;
  CollectionReference whoCR;
  QuerySnapshot whoQS;
  List<DocumentSnapshot> whoDS;
  DocumentSnapshot whoPic;
  TextEditingController txtWhat = new TextEditingController();
  String userEmail;
  File chatImg;
  Map<String,DocumentSnapshot> staffMap = {};

  void initState() {
    getData();
    super.initState();
  }

  var fullImageName;

  Future<String> uploadImageToCloud(var imageFile, var name) async {
    var Rand1 = new Random().nextInt(999);
    var Rand2 = new Random().nextInt(999);
    var Rand3 = new Random().nextInt(999);
    fullImageName = name + DateTime.now().toString() + '$Rand1$Rand2$Rand3.jpg';
    final StorageReference refImg = FirebaseStorage.instance
        .ref()
        .child(DateTime.now().toString() + '/' + fullImageName);
    StorageUploadTask uploadTask = refImg.putFile(imageFile);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    return dowurl;
  }

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('currentUser');
    groupCR = Firestore.instance.collection('management_chat');
    gpQS = await groupCR.orderBy('when', descending: true).getDocuments();
    gpDS = gpQS.documents;
    whoCR = await Firestore.instance.collection('employee');
    whoQS = await whoCR.getDocuments();
    whoDS = whoQS.documents;
    whoDS.forEach((element) {
      staffMap.addEntries(
          [
            MapEntry(
                element.data['Email'],element),
          ]
      );
    });
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.restoreSystemUIOverlays();
    var _index = 1;
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.shade100,
      ),
      child: Center(
        child: Column(
          children: <Widget>[
            _buildMessagesList(),
            Divider(height: 10.0),
            _buildComposeMsgRow()
          ],
        ),
      ),
    );
  }

  Widget _buildComposeMsgRow() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blueGrey),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: TextField(
              textInputAction: TextInputAction.newline,
              maxLines: null,
              decoration: InputDecoration(
                focusedBorder: InputBorder.none,
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey)),
              ),
              style:
              GoogleFonts.carterOne(fontSize: 16, color: Colors.blueGrey),
              controller: txtWhat,
              onChanged: (value) {
                this.setState(() {});
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () async {
              var email = await SharedPreferences.getInstance();
              var pic = await Firestore.instance
                  .collection('employee')
                  .where('Email', isEqualTo: email.get('currentUser'))
                  .getDocuments();
              await galleryOpen().then((value) {
                this.setState(() {
                  chatImg = value;
                });
              }).then((value) => showDialog(
                  context: context,
                  child: SimpleDialog(
                    backgroundColor: Colors.white,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: Image.file(chatImg),
                      ),
                      FlatButton(
                        child: Text(
                          'Press Here To Send',
                        ),
                        onPressed: () async {
                          showDialog(
                              context: context,
                              child: AlertDialog(
                                title: Text('Saving'),
                              ));
                          Firestore.instance.collection('management_chat').add({
                            'who': email.get('currentUser'),
                            'whopic': pic.documents.first.data['Picture'],
                            'when': Timestamp.now(),
                            'what': 'sent a picture',
                            'whatpic': await uploadImageToCloud(
                                chatImg, email.get('currentUser')),
                          }).then((value) { Navigator.of(context,rootNavigator: true).pop(); Navigator.of(context,rootNavigator: true).pop();});
                        },
                      )
                    ],
                  )));
            },
          ),
          txtWhat.text == ""
              ? IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.black,
            ),
            onPressed: () {},
          )
              : IconButton(
            icon: Icon(
              Icons.send,
              color: Colors.blueAccent,
            ),
            onPressed: () async {
              var email = await SharedPreferences.getInstance();
              var pic = await Firestore.instance
                  .collection('employee')
                  .where('Email', isEqualTo: email.get('currentUser'))
                  .getDocuments();
              Firestore.instance.collection('management_chat').add({
                'who': email.get('currentUser'),
                'whopic': pic.documents.first.data['Picture'],
                'what': txtWhat.text,
                'when': Timestamp.now(),
              });
              txtWhat.clear();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Flexible(
      child: Scrollbar(
        child: StreamBuilder(
            stream: Firestore.instance
                .collection("management_chat")
                .orderBy('when', descending: true)
                .snapshots(),
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
                    final DocumentSnapshot doc = snapshot.data.documents[index];
                    Timestamp _when = doc.data['when'];
                    TextEditingController txtText = new TextEditingController(
                        text: doc.data['what'].toString());
                    var k;
                    Color statusColor = Colors.grey;
                    switch(staffMap[doc.data['who']].data['currentState']){
                      case 0: statusColor = Colors.green;break;
                      case 1: statusColor = Colors.grey;break;
                      case 2: statusColor = Colors.red;break;
                    }
                    return Card(
                      borderOnForeground: false,
                      elevation: 0,
                      color: Colors.transparent,
                      semanticContainer: false,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(color: Colors.transparent),
                        width: double.maxFinite,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      doc.data['whopic']),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Flexible(
                                    child: TextField(
                                      controller: txtText,
                                      readOnly: true,
                                      maxLines: null,
                                      onTap: () {
                                        if(doc.data['who']==userEmail){
                                          showCupertinoModalPopup(
                                            context: context,
                                            builder: (context) => CupertinoActionSheet(
                                              title: Text('What You Wanna Do?'),
                                              actions: [
                                                CupertinoActionSheetAction(
                                                  child: Text('Delete'),
                                                  onPressed: () async{
                                                    await doc.reference.delete();
                                                    Navigator.of(context,rootNavigator: true).pop();
                                                  },
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                      decoration: InputDecoration(
                                        labelText: doc.data['who'],
                                        labelStyle: TextStyle(color:statusColor,fontWeight: FontWeight.w500),
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                      ),
                                    )),
                              ],
                            ),
                            doc.data['whatpic'] == null
                                ? SizedBox()
                                : GestureDetector(
                              child: CachedNetworkImage(
                                imageUrl: doc.data['whatpic'],
                                height: 200,
                                fit: BoxFit.fitHeight,
                              ),
                              onTap: () {
                                showDialog(
                                    context: context,
                                    child: AlertDialog(
                                      title: CachedNetworkImage(
                                        imageUrl: doc.data['whatpic'],
                                      ),
                                    )
                                );
                              },
                              onLongPress: () async {
                                showCupertinoModalPopup(
                                  context: context,
                                  builder: (context) => CupertinoActionSheet(
                                    title: Text('What You Wanna Do?'),
                                    actions: [
                                      CupertinoActionSheetAction(
                                        child: Text('Save'),
                                        onPressed: () async{
                                          var imageId =
                                          await ImageDownloader.downloadImage(
                                              doc.data['whatpic'])
                                              .then((value) => showDialog(
                                              context: context,
                                              child: AlertDialog(
                                                title: Text('Saved!'),
                                              )));
                                          Navigator.of(context,rootNavigator: true).pop();
                                        },
                                      )
                                    ],
                                  ),
                                );

                              },
                            ),
                            Text(
                              _when.toDate().day.toString() +
                                  "." +
                                  _when.toDate().month.toString() +
                                  "." +
                                  _when.toDate().year.toString() +
                                  "  " +
                                  _when.toDate().hour.toString() +
                                  ":" +
                                  _when.toDate().minute.toString(),
                              style: TextStyle(
                                  color: Colors.blueAccent, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
