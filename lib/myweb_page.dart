import 'dart:async';
import 'dart:io';

import 'package:bunhann_app/progress_indicator.dart';
import 'package:bunhann_app/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

class JobWebPage extends StatefulWidget {
  @override
  _JobWebPageState createState() => _JobWebPageState();
}

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

class _JobWebPageState extends State<JobWebPage> {
  bool loaded = false;

  String myUrl = DotEnv().env['APP_URL'];

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  DateTime currentBackPressTime;

  int _currentIndex = 0;

  StreamSubscription<WebViewStateChanged> _onStateChanged;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.run(() {
      try {
        InternetAddress.lookup('google.com').then((result) {
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            print('connected');
          } else {
            _showDialog(); // show dialog
          }
        }).catchError((error) {
          _showDialog(); // show dialog
        });
      } on SocketException catch (_) {
        _showDialog();
        print('not connected'); // show dialog
      }
    });
    _onStateChanged = flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) async {
      if (mounted) {

        if (state.url.startsWith('tel:') && state.type == WebViewState.abortLoad) {
          await flutterWebViewPlugin.stopLoading();
          if (await canLaunch(state.url)) {
            await launch(state.url);
          }
        }
        if (state.url.contains('facebook.com') || state.url.contains('twitter.com') || state.url.contains('youtube.com') || state.url.contains('linkedin.com') || state.url.startsWith('tel:') || state.url.startsWith('mailto:')) {
          await flutterWebViewPlugin.stopLoading();
          await launch(state.url);
        }
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Services"),
        elevation: 2.0,
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: Icon(Icons.exit_to_app),
              onTap: () {
                flutterWebViewPlugin.close();
                flutterWebViewPlugin.hide();// hide the webview widget
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              },
            ),
          ),
        ],
      ),
      body: WebviewScaffold(
        url: myUrl,
        withLocalStorage: true,
        hidden: true,
        initialChild: Center(
            child: InfiniteProgressIndicator(
                padding: EdgeInsets.symmetric(vertical: 16.0))),
        withOverviewMode: false,
        appCacheEnabled: true,
        debuggingEnabled: false,
        withJavascript: true,
        enableAppScheme: true,
        useWideViewPort: true,
        geolocationEnabled: true,
        allowFileURLs: true,
        withLocalUrl: true,
        primary: true,
        userAgent: kAndroidUserAgent,

        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          currentIndex: _currentIndex, // this will be set when a new tab is tapped
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text('Home'),
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.child_friendly),
              title: new Text('Jobs'),

            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.brightness_1),
                title: Text('Blog')
            )
          ],
        ),
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      flutterWebViewPlugin.reloadUrl(myUrl);
    } else if (index == 1) {
      flutterWebViewPlugin.reloadUrl("${myUrl}jobs/");

    } else if (index == 2) {
      flutterWebViewPlugin.reloadUrl("${myUrl}blog/");

    }
  }

  void _showDialog() {
    // dialog implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Internet needed!"),
        elevation: 2.0,
        content: Text("It looks like you are offline."),
        actions: <Widget>[
          FlatButton(
              child: Text("Retry!"),
              onPressed: () {
                RestartWidget.of(context).restartApp();
              })
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterWebViewPlugin.dispose();
  }
}
