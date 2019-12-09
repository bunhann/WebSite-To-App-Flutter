import 'package:bunhann_app/restart_widget.dart';
import 'package:bunhann_app/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future main() async {

  await DotEnv().load('.env');

  //runApp(MyApp());

  runApp(new RestartWidget(
      child: MyApp()
  ));
}


const mainColor = MaterialColor(0xFF275ead, {
  50: Color(0xFF275ead),
  100: Color(0xFF275ead),
  200: Color(0xFF275ead),
  300: Color(0xFF275ead),
  400: Color(0xFF275ead),
  500: Color(0xFF275ead),
  600: Color(0xFF275ead),
  700: Color(0xFF275ead),
  800: Color(0xFF275ead),
  900: Color(0xFF275ead),
});

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final SystemUiOverlayStyle mySystemTheme = SystemUiOverlayStyle.light
        .copyWith(systemNavigationBarColor: Color(0xFF275ead));

    return MaterialApp(
      title: 'Bunhann Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: mainColor,
        primaryTextTheme: TextTheme(
          title: TextStyle(color: Colors.white),
        ),
      ),
      home: SplashPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
