import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIN LOCK',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: BackgroundObserverPage(title: 'PIN LOCK'),
    );
  }
}

class BackgroundObserverPage extends StatefulWidget {
  final String title;
  BackgroundObserverPage({Key key, this.title}) : super(key: key);

  @override
  _BackgroundObserverPageState createState() => _BackgroundObserverPageState();
}

class _BackgroundObserverPageState extends State<BackgroundObserverPage> with WidgetsBindingObserver {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title),),
      body: Text("Home screen"),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch(state) {
      case AppLifecycleState.resumed:
        _resumed();
        break;
      case AppLifecycleState.paused:
        _paused();
        break;
      case AppLifecycleState.inactive:
        _inactive();
        break;
      default:
        break;
    }
  }

  final lastKnownStateKey = 'lastKnownStateKey';
  final backgroundedTimeKey = 'backgroundedTimeKey';

  Future _paused() async {
    final sp = await SharedPreferences.getInstance();
    sp.setInt(lastKnownStateKey, AppLifecycleState.paused.index);
  }

  Future _inactive() async {
    print('inactive');
    final sp = await SharedPreferences.getInstance();
    final prevState = sp.getInt(lastKnownStateKey);

    final prevStateIsNotPaused = prevState != null &&
        AppLifecycleState.values[prevState] != AppLifecycleState.paused;

    if( prevStateIsNotPaused ) {
      sp.setInt(backgroundedTimeKey, DateTime.now().millisecondsSinceEpoch);
    }

    sp.setInt(lastKnownStateKey, AppLifecycleState.inactive.index);
  }

  final pinLockMillis = 2000;
  Future _resumed() async {
    print('resumed');
    final sp = await SharedPreferences.getInstance();

    final bgTime = sp.getInt(backgroundedTimeKey) ?? 0;
    final allowedBackgroundTime = bgTime + pinLockMillis;
    final shouldShowPIN = DateTime.now().millisecondsSinceEpoch > allowedBackgroundTime;

    if(shouldShowPIN) {
      // show PIN screen
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PINScreen()),);
    }

    sp.remove(backgroundedTimeKey);
    sp.setInt(lastKnownStateKey, AppLifecycleState.resumed.index);
  }
}

class PINScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: Scaffold(
          appBar: AppBar(title: Text('PIN screen')),
            body: Align(
              alignment: Alignment.center,
              child: Text('Dummy PIN screen')
            )
        )
    );
  }

}
