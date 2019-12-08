import 'dart:async';
import 'package:bunhann_app/myweb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_splash/flutter_splash.dart';

class SplashPage extends StatelessWidget {

  loadWidget() async {
    return await new Future<Widget>.delayed(
        Duration(seconds: 3), () => MyWebPage());
  }

  @override
  Widget build(BuildContext context) {
    return new Splash(
      //navigateAfterSeconds: new MyWebPage(),
      navigateAfterFuture: loadWidget(),
      title: new Text(
        DotEnv().env['SPLASH_TEXT'],
        textScaleFactor: 1.0,
        style: new TextStyle(
            fontWeight: FontWeight.bold, fontSize: 25.0, color: Colors.white),
      ),
      imageBackground: NetworkImage(
          DotEnv().env['SPLASH_IMAGE_URL'],
          scale: 1),
      backgroundColor: Colors.blueGrey[200],
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 100.0,
      loaderColor: Colors.deepOrange,
    );
  }
}
