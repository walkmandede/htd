import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SimpleWebView extends StatefulWidget {
  @override
  _SimpleWebViewState createState() => _SimpleWebViewState();
}

class _SimpleWebViewState extends State<SimpleWebView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Simple WebView",
        debugShowCheckedModeBanner: false,
        home: GooglePage()
    );
  }
}

class GooglePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Container(
              child: Column(children: <Widget>[
                FlatButton(child: Text('DASAN Router'),
                  onPressed: () async{
                    const url = 'http://192.168.1.1';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },),
                // Expanded(
                //   child: Container(
                //     child: InAppWebView(
                //       initialUrl: "http://192.168.1.1/",
                //       initialHeaders: {},
                //       initialOptions: InAppWebViewGroupOptions(
                //           crossPlatform: InAppWebViewOptions(
                //             debuggingEnabled: true,
                //             javaScriptEnabled: true,
                //
                //           )
                //       ),
                //       onWebViewCreated: (InAppWebViewController controller) {
                //
                //       },
                //       onLoadStart: (InAppWebViewController controller, String url) {
                //
                //       },
                //       onLoadStop: (InAppWebViewController controller, String url) {
                //
                //       },
                //     ),
                //   ),
                // )
              ]
              )
          ),
        ),
      ),
    );
  }
}
