import 'dart:async';
import 'dart:io';

import 'package:bunhann_app/progress_indicator.dart';
import 'package:bunhann_app/restart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

WebViewController controllerGlobal;

class MyWebPage extends StatefulWidget {
  @override
  _MyWebPageState createState() => _MyWebPageState();
}

class _MyWebPageState extends State<MyWebPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  bool loaded = false;

  final String myUrl=DotEnv().env['APP_URL'];

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
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bunhann Consultation Services"),
          centerTitle: true,
          actions: <Widget>[
            //NavigationControls(_controller.future),
          ],
        ),
        body: Stack(
          children: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return _buildWebView(context);
              },
            ),
            if(!loaded) ... [
              Center(child: InfiniteProgressIndicator(padding: EdgeInsets.symmetric(vertical: 16.0,)))
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildWebView(BuildContext context) {
    return WebView(
      initialUrl: myUrl,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
        controllerGlobal = webViewController;
      },
      debuggingEnabled: false,
      javascriptChannels: <JavascriptChannel>[
        _toasterJavascriptChannel(context),
      ].toSet(),
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith(myUrl)) {
          //print('blocking navigation to $request}');
          return NavigationDecision.navigate;
        } else {
          canLaunch(request.url).then((va) {
            launch(request.url);
          });
        }
        //print('allowing navigation to $request');
        return NavigationDecision.prevent;
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
        setState(() {
          loaded = true;
        });
      },
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  Future<bool> _exitApp(BuildContext context) async {
    if (await controllerGlobal.canGoBack()) {
      print("onwill goback");
      controllerGlobal.goBack();
      return Future.value(false);
    } else {

      SystemChannels.platform
          .invokeMethod('SystemNavigator.pop');
      Scaffold.of(context).showSnackBar(
        const SnackBar(content: Text("No back history item")),
      );
      return Future.value(false);
    }
  }

  void _showDialog() {
    // dialog implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Internet needed!"),
        content: Text("It looks like you are offline."),
        actions: <Widget>[FlatButton(child: Text("Retry!"), onPressed: () {
          RestartWidget.of(context).restartApp();
        })],
      ),
    );
  }

}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        controllerGlobal = controller;

        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        controller.goBack();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        controller.goForward();
                      } else {
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
