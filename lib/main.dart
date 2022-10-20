import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'debugoptionsexample.dart';
import 'placeafox.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await ArFlutterPlugin.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
    print('Running on: $_platformVersion');
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHome()
    );
  }
}

class MyHome extends StatelessWidget {
  const MyHome({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Fox'),
      ),
      body: ListView(children: [
        ListTile(onTap: (){
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const DebugOptionsWidget()));
        },title: const Text('Options'),subtitle: const Text('Enable options to see planes, coordinates, points'),
        ),
        ListTile(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PlaceAFox()),
          );
        },title: const Text('Place a Fox'),subtitle: const Text('Click on a plane/point to place the Fox'),
        )
      ]),
    );
  }
}
