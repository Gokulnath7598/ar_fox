import 'dart:io';
import 'dart:math';

import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:ar_flutter_plugin/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:vector_math/vector_math_64.dart';
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
              MaterialPageRoute(builder: (context) => LocalAndWebObjectsWidget()));
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



class LocalAndWebObjectsWidget extends StatefulWidget {
  LocalAndWebObjectsWidget({Key key}) : super(key: key);
  @override
  _LocalAndWebObjectsWidgetState createState() =>
      _LocalAndWebObjectsWidgetState();
}

class _LocalAndWebObjectsWidgetState extends State<LocalAndWebObjectsWidget> {
  ARSessionManager arSessionManager;
  ARObjectManager arObjectManager;
  //String localObjectReference;
  ARNode localObjectNode;
  //String webObjectReference;
  ARNode webObjectNode;
  ARNode fileSystemNode;
  HttpClient httpClient;

  @override
  void dispose() {
    super.dispose();
    arSessionManager.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Local & Web Objects'),
        ),
        body: Container(
            child: Stack(children: [
              ARView(
                onARViewCreated: onARViewCreated,
                planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
              ),
              Align(
                  alignment: FractionalOffset.bottomCenter,
                  child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    ElevatedButton(
                        onPressed: onWebObjectAtOriginButtonPressed,
                        child: Text("Add/Remove Web\nObject at Origin"))
                  ]))
            ])));
  }

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;

    this.arSessionManager.onInitialize(
      showAnimatedGuide: false,
      showFeaturePoints: false,
      showPlanes: false,
      showWorldOrigin: false,
      handleTaps: false,
    );
    this.arObjectManager.onInitialize();
  }

  Future<void> onWebObjectAtOriginButtonPressed() async {
    if (this.webObjectNode != null) {
      this.arObjectManager.removeNode(this.webObjectNode);
      this.webObjectNode = null;
    } else {
      var newNode = ARNode(
          type: NodeType.webGLB,
          uri:
          "https://github.com/KhronosGroup/glTF-Sample-Models/raw/master/2.0/Duck/glTF-Binary/Duck.glb",
          scale: Vector3(0.2, 0.2, 0.2),
      position: Vector3(0, 0, -2),);
      bool didAddWebNode = await this.arObjectManager.addNode(newNode);
      this.webObjectNode = (didAddWebNode) ? newNode : null;
    }
  }
}