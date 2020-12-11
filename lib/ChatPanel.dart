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
import 'package:htd/ChatGroup.dart';
import 'package:htd/ChatManagment.dart';
import 'package:htd/ChatOperation.dart';
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

class ChatPanel extends StatelessWidget {
  const ChatPanel();

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getThemeData(context),
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            flexibleSpace: TabBar(
              indicatorColor: Colors.green,
              tabs: [
                Tab(
                  child: Text('All Chat',style: getTextStyle(context),),
                ),
                Tab(
                  child: Text('Management',style: getTextStyle(context),),
                ),
                Tab(
                  child: Text('Operation',style: getTextStyle(context),),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [ChatGroup(), ChatManagement(), ChatOperation()],
          ),
        ),
      ),
    );
  }
}

class ChatPanelForm extends StatefulWidget {
  const ChatPanelForm();

  @override
  _ChatPanelFormState createState() => _ChatPanelFormState();
}

class _ChatPanelFormState extends State<ChatPanelForm> {
  String showPage = 'all';
  TabController tbcntr = new TabController(initialIndex: 1);

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.restoreSystemUIOverlays();
    return TabBar(
      controller: tbcntr,
      tabs: [
        Text('A'),
        Text('B'),
        Text('C'),
      ],
    );
  }

  Widget pageShown() {
    switch (showPage) {
      case 'all':
        return ChatGroup();
      case 'management':
        return ChatManagement();
      case 'operation':
        return ChatOperation();
    }
  }
}
