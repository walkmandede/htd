import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:htd/YTP_IN_Detail.dart';
import 'package:htd/YTP_IN_Edit.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:math';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:htd/ChatGroup.dart';
import 'package:htd/pages/Calender.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:htd/main.dart';
import 'package:htd/pages/TimeSheet.dart';
import 'package:htd/pages/Staff.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:htd/pages/AllMap.dart';
import 'package:htd/pages/Profile.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:htd/pages/Login.dart';
import 'package:htd/pages/Inventory.dart';
import 'package:htd/globals.dart' as globals;
import 'package:geolocator/geolocator.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2020, 1, 1): ['New Year\'s Day'],
  DateTime(2020, 1, 6): ['Epiphany'],
  DateTime(2020, 2, 14): ['Valentine\'s Day'],
  DateTime(2020, 4, 21): ['Easter Sunday'],
  DateTime(2020, 4, 22): ['Easter Monday'],
};

class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Calendar Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Table Calendar Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Map<DateTime, List<dynamic>> _events={};
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  List<DocumentSnapshot> ytpSites = [];
  String viewPage = 'Calendar';
  List<DocumentSnapshot> doc;
  List<DocumentSnapshot> docMaintainYTP;
  var k;
  List<Widget> sitesCard = [];
  List<Widget> maintainCard = [];
  List<Widget> installCard = [];
  List<Card> sitesCardMaintainYTP = [];
  List dnsnList = [];
  int index;
  String showPage = 'all';
  bool isLoaded = false;


  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async{
    QuerySnapshot qs;
    QuerySnapshot qsMaintainYTP;
    Widget k;
    qs = await Firestore.instance
        .collection('YTP_Sites')
        .where('status',isEqualTo: 'Remaining')
        .getDocuments();
    doc = qs.documents;

    for (final _site in doc) {
      Timestamp installDate = _site.data['installationDate'];
      DateTime date = installDate.toDate();
      sitesCard.add(Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.green,width: 2.5),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: ExpansionTile(
          childrenPadding: EdgeInsets.all(5),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _site.data['customerID'],
                style:
                TextStyle(color: _site.data['type']!='Maintain'?Colors.black:Colors.blue, fontWeight: FontWeight.w600),
              ),
              Text(
                date.toString().substring(0, 10),
                style: TextStyle(
                  color: _site.data['status'] == 'Remaining'
                      ? Colors.redAccent
                      : Colors.green,
                ),
              ),
            ],
          ),
          children: [
            Text(
              _site.data['customerName'],
              style: TextStyle(fontSize: 15/MediaQuery.textScaleFactorOf(context), color: Colors.green),
            ),
            Text(
              _site.data['address'],
              style: TextStyle(fontSize: 15/MediaQuery.textScaleFactorOf(context), fontWeight: FontWeight.w400),
              maxLines: null,
            ),
            Text(
              _site.data['remark'],
              style: TextStyle(
                  color: Colors.red,
                  fontStyle: FontStyle.italic,
                  fontSize: 15/MediaQuery.textScaleFactorOf(context),
                  fontWeight: FontWeight.w600),
              maxLines: null,
            ),
            Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.green,
              ),
              child: Row(
                children: [
                  FlatButton(
                    child: Text(
                      'View',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YTP_IN_Detail(_site)));
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Process',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YTP_IN_Edit(_site)));
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ));
      if(_site.data['type']=='Install')
      {
        installCard.add(Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: ExpansionTile(
            childrenPadding: EdgeInsets.all(5),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _site.data['customerID'],
                  style:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
                ),
                Text(
                  date.toString().substring(0, 10),
                  style: TextStyle(
                    color: _site.data['status'] == 'Remaining'
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                ),
              ],
            ),
            children: [
              Text(
                _site.data['customerName'],
                style: GoogleFonts.carterOne(fontSize: 15/MediaQuery.textScaleFactorOf(context), color: Colors.blue),
              ),
              Text(
                _site.data['address'],
                style: TextStyle(fontSize: 15/MediaQuery.textScaleFactorOf(context), fontWeight: FontWeight.w400),
                maxLines: null,
              ),
              Text(
                _site.data['remark'],
                style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                    fontSize: 15/MediaQuery.textScaleFactorOf(context),
                    fontWeight: FontWeight.w600),
                maxLines: null,
              ),
              Container(
                margin: EdgeInsets.all(5),
                color: Colors.blue,
                child: Row(
                  children: [
                    FlatButton(
                      child: Text(
                        'View',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => YTP_IN_Detail(_site)));
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Process',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => YTP_IN_Edit(_site)));
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Finish',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async{
                        _site.reference.setData({
                          'status':'Finished'
                        },merge: true).then((value) => Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => MyApp(),)));
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'SSR',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async{
                        _site.reference.setData({
                          'ssr':true,
                        },merge: true).then((value) => Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => MyApp(),)));
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
      }
      else if(_site.data['type']=='Maintain')
      {
        maintainCard.add(Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: ExpansionTile(
            childrenPadding: EdgeInsets.all(5),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _site.data['ttNo'],
                  style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                ),
                Text(
                  date.toString().substring(0, 10),
                  style: TextStyle(
                    color: _site.data['status'] == 'Remaining'
                        ? Colors.redAccent
                        : Colors.green,
                  ),
                ),
              ],
            ),
            children: [
              Text(
                _site.data['customerName'],
                style: GoogleFonts.carterOne(fontSize: 15/MediaQuery.textScaleFactorOf(context), color: Colors.blue),
              ),
              Text(
                _site.data['address'],
                style: TextStyle(fontSize: 15/MediaQuery.textScaleFactorOf(context), fontWeight: FontWeight.w400),
                maxLines: null,
              ),
              Text(
                _site.data['remark'],
                style: TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                    fontSize: 15/MediaQuery.textScaleFactorOf(context),
                    fontWeight: FontWeight.w600),
                maxLines: null,
              ),
              Container(
                margin: EdgeInsets.all(5),
                color: Colors.blue,
                child: Row(
                  children: [
                    FlatButton(
                      child: Text(
                        'View',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => YTP_IN_Detail(_site)));
                      },
                    ),
                    FlatButton(
                      child: Text(
                        'Process',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => YTP_IN_Edit(_site)));
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
      }
    }
    QuerySnapshot dnsnQS =
    await Firestore.instance.collection('DNSN').getDocuments();
    for (final index in dnsnQS.documents) {
      dnsnList.add(index.documentID);
    }
    setState(() {
      isLoaded = true;
    });
    final _selectedDay = DateTime.now();
    SharedPreferences sp = await SharedPreferences.getInstance();
    QuerySnapshot myDs = await Firestore.instance.collection('YTP_Sites').getDocuments();
    setState(() {
      ytpSites = myDs.documents;
    });
    ytpSites.forEach((element) {
      Timestamp ts = element.data['installationDate'];
      DateTime ds = ts.toDate();
      DateTime t = new DateTime(ds.year,ds.month,ds.day);
      if(_events[t]==null)_events[t]=[element.documentID];
      else _events[t].add(element.documentID);
    });
    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    print('CALLBACK: _onDaySelected');
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  void _onCalendarCreated(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      backgroundColor: Colors.green.shade50,
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.green,
        items: [
          TabItem(icon: Icons.home, title: 'Site List'),
          TabItem(icon: Icons.calendar_today, title: 'Calendar'),
        ],
        initialActiveIndex: 1,//optional, default as 0
        onTap: (int i) {
          switch(i)
          {
            case 0 :  setState(() {
              viewPage='SiteList';
            }); break ;
            case 1 :  setState(() {
              viewPage='Calendar';
            }); break;
          }
        },
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent
            ),
          ),
          viewPage!='Calendar'?SizedBox():Flexible(
            child: Container(
              child: Column(
                children: [
                  _buildTableCalendar(),
                  // _buildTableCalendarWithBuilders(),
                  const SizedBox(height: 8.0),
                  const SizedBox(height: 8.0),
                  Expanded(child: _buildEventList()),
                ],
              ),
            ),
          ),
          viewPage!='SiteList'?SizedBox():
              Expanded(
                child:           SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FlatButton(
                                  onPressed: () => this.setState(() {
                                    showPage = 'all';
                                  }),
                                  child: Text(
                                    'All Sites',
                                    style: TextStyle(color: showPage=='all'?Colors.green:Colors.grey,fontSize: 20/MediaQuery.textScaleFactorOf(context))
                                  )),
                              FlatButton(
                                  onPressed: () => this.setState(() {
                                    showPage = 'installation';
                                  }),
                                  child: Text(
                                    'Install',
                                      style: TextStyle(color: showPage=='installation'?Colors.green:Colors.grey,fontSize: 20/MediaQuery.textScaleFactorOf(context))
                                  )),
                              FlatButton(
                                  onPressed: () => this.setState(() {
                                    showPage = 'maintain';
                                  }),
                                  child: Text(
                                    'Maintain',
                                      style: TextStyle(color: showPage=='maintain'?Colors.green:Colors.grey,fontSize: 20/MediaQuery.textScaleFactorOf(context))
                                  )),
                            ],
                          ),
                        ),
                        doc.isEmpty
                            ? Text(
                          'There is no data',
                        )
                            : Container(
                          child: Column(
                            children: showPage == 'installation'
                                ? installCard
                                : showPage == 'maintain'
                                ? maintainCard
                                : sitesCard,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

              )

        ],
      ),
    );
  }

  // Simple TableCalendar configuration (using Styles)
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      initialCalendarFormat: CalendarFormat.week,
      initialSelectedDay: DateTime.now(),
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.red[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle:
        TextStyle().copyWith(color: Colors.white, fontSize: 15/MediaQuery.textScaleFactorOf(context)),
        formatButtonDecoration: BoxDecoration(
          color: Colors.green[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.green,
              ),
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.green.shade200,
            ),
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }
          return children;
        },
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }
  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: events[0].toString()=='Leave'
            ? Colors.brown[500]
            : Colors.green[400],
      ),
      height: 20.0,
      width: 20.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
  Widget _buildEventList() {

    return ListView(
      children: _selectedEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.green
        ),
        margin:
        const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString(),style: TextStyle(color: Colors.white),),
          onTap: () async{

                DocumentSnapshot qs = await Firestore.instance.collection('YTP_Sites').document(event.toString()).get();
                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>YTP_IN_Detail(qs)));
          },
        ),
      ))
          .toList(),
    );
  }
}